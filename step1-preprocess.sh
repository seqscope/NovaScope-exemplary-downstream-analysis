# ===== SET UP =====
set -ueo pipefail

# Processing the input_data_and_params.
if [ $# -ne 1 ]; then
    echo -e "Usage: $0 <path_to_file>"
    exit 1
fi

echo -e "#=====================\n#"
echo -e "# $(basename "$0") \n#"
echo -e "#=====================\n#"

neda=$(dirname "$0")
input_data_and_params="$1"

source $neda/scripts/process_input.sh

process_input_data_and_params $input_data_and_params

if [[ $execution_mode == "HPC" ]]; then
    module load Bioinformatics
    module load samtools
    module load python/3.9.12
fi

source ${py39_env}/bin/activate
py39=${py39_env}/bin/python

# Examine the required input files
required_files=(
    "${input_dir}/features.tsv.gz"
    "${input_dir}/barcodes.tsv.gz"
    "${input_dir}/matrix.mtx.gz"
)

check_files_exist "${required_files[@]}"

# ===== ANALYSIS =====
mkdir -p ${output_dir}
# Merge the feature, barcode, and matrix files
echo -e "\n#=== sub-step.1 Create the merged NGE ===#"

awk 'BEGIN{FS=OFS="\t"} NR==FNR{ft[$3]=$1 FS $2 ;next} ($1 in ft) {print $2 FS $3 FS $4 FS $5 FS ft[$1] FS $6 FS $7 FS $8 FS $9 FS $10 }' \
    <(zcat ${input_dir}/features.tsv.gz) \
    <(join -t $'\t' -1 1 -2 2 -o '2.1,1.2,1.3,1.4,1.5,2.3,2.4,2.5,2.6,2.7' \
        <(zcat ${input_dir}/barcodes.tsv.gz   | cut -f 2,4-8) \
        <(zcat ${input_dir}/matrix.mtx.gz     | tail -n +4 | sed 's/ /\t/g' )) | \
    sed -E 's/\t[[:alnum:]]+_/\t/' | \
    sort -S 10G -k1,1n -k3,3n|\
    sed '1 s/^/#lane\ttile\tX\tY\tgene_id\tgene\tgn\tgt\tspl\tunspl\tambig\n/' | \
    bgzip -c > ${output_dir}/${prefix}.merged.matrix.tsv.gz

tabix -0 -f -s1 -b3 -e3 ${output_dir}/${prefix}.merged.matrix.tsv.gz

# QC
echo -e "\n#=== sub-step.2 QC ===#"
echo -e "\n#=== * Prepare clean feature file ===#"
kept_gene_type=$(echo "protein_coding,lncRNA" | sed 's/,/\|/')
rm_gene_regex=$(echo "^Gm\d+|^mt-|^MT-" | sed 's/\^/\\t/g')

zcat ${input_dir}/features.tsv.gz | cut -f 1,2,4 | sed 's/,/\t/g' | sed '1 s/^/gene_id\tgene\tgn\tgt\tspl\tunspl\tambig\n/' | gzip -c > ${output_dir}/${prefix}.feature.tsv.gz

echo -e "gene_id\tgene\tgn\tgt\tspl\tunspl\tambig" > ${output_dir}/${prefix}.feature.clean.tsv
awk 'BEGIN{FS=OFS="\t"} NR==FNR {ft[$1]=$1; next} ($1 in ft && $4 + 0 > 50) {print $0 }' \
    <(zcat ${ref_geneinfo}  | grep -P "${kept_gene_type}" | cut -f 4 ) \
    <(zcat ${output_dir}/${prefix}.feature.tsv.gz)| \
    grep -vP "${rm_gene_regex}" >> ${output_dir}/${prefix}.feature.clean.tsv
gzip -f ${output_dir}/${prefix}.feature.clean.tsv

echo -e "\n#=== * Prepare a QC matrix file ===#"
command time -v ${py39} ${ficture}/script/filter_poly.py \
    --input ${output_dir}/${prefix}.merged.matrix.tsv.gz \
    --feature ${output_dir}/${prefix}.feature.clean.tsv.gz \
    --output ${output_dir}/${prefix}.QCed.matrix.tsv.gz \
    --output_boundary ${output_dir}/${prefix} \
    --filter_based_on ${sf} \
    --mu_scale 1000 \
    --radius 15 \
    --quartile 2 \
    --hex_n_move 2 \
    --remove_small_polygons 500 \

echo -e "\n#=== * Tabix the QCed matrix ===#"
zcat ${output_dir}/${prefix}.QCed.matrix.tsv.gz | bgzip -c > ${output_dir}/${prefix}.QCed.matrix.tsv.gz.tmp.gz
mv ${output_dir}/${prefix}.QCed.matrix.tsv.gz.tmp.gz ${output_dir}/${prefix}.QCed.matrix.tsv.gz
tabix -0 -f -s1 -b3 -e3 ${output_dir}/${prefix}.QCed.matrix.tsv.gz

echo -e "\n#=== * Create minibatch ===#"
command time -v ${py39} ${ficture}/script/make_spatial_minibatch.py \
    --input ${output_dir}/${prefix}.QCed.matrix.tsv.gz \
    --output ${output_dir}/${prefix}.batched.matrix.tsv \
    --mu_scale 1000 \
    --batch_size 500 \
    --batch_buff 30 \
    --major_axis X \

sort -S 10G -k2,2n -k3,3n ${output_dir}/${prefix}.batched.matrix.tsv | bgzip -c > ${output_dir}/${prefix}.batched.matrix.tsv.gz 
