# ===== SET UP =====
set -ueo pipefail

if [ $# -ne 1 ]; then
    echo -e "Usage: $0 <input_data_and_params>"
    exit 1
fi

echo -e "#=====================\n#"
echo -e "# $(basename "$0") \n#"
echo -e "#=====================\n#"

# # Read input config
neda=$(dirname $(dirname "$0"))
source $neda/scripts/process_input.sh
process_input_data_and_params $0

# Examine the input data
required_files=(
    "${input_dir}/features.tsv.gz"
    "${input_dir}/barcodes.tsv.gz"
    "${input_dir}/matrix.mtx.gz"
    "${output_dir}/${prefix}.merged.matrix.tsv.gz"
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_kept_gene_types="protein_coding,lncRNA"
ap_removed_gene_types="^Gm\d+|^mt-|^MT-"

ap_mu_scale=1000
ap_radius=15
ap_quartile=2
ap_hex_n_move=2
ap_remove_small_polygons=500

# ===== ANALYSIS =====
# 1) Create a QCed feature file via filtering gene types and density
echo -e "\n#=== 1) Prepare a clean feature file ===#"

# Convert the feature file to a tab-delimited format. This will be used as input to prepare a QCed feature file.
zcat ${input_dir}/features.tsv.gz | cut -f 1,2,4 | sed 's/,/\t/g' | sed '1 s/^/gene_id\tgene\tgn\tgt\tspl\tunspl\tambig\n/' | gzip -c > ${output_dir}/${prefix}.feature.tsv.gz

# Define which gene types to keep and which gene names to remove
kept_gene_type=$(echo "$ap_kept_gene_types" | sed 's/,/\|/') 
rm_gene_regex=$(echo "$ap_kept_gene_types" | sed 's/\^/\\t/g')

# Define the header of the QCed feature file
echo -e "gene_id\tgene\tgn\tgt\tspl\tunspl\tambig" > ${output_dir}/${prefix}.feature.clean.tsv

# Filter the feature file by gene types and density
# Here density threshold is set to GeneFull > 50, which is a default setting in the FICTURE pipeline.
awk 'BEGIN{FS=OFS="\t"} NR==FNR {ft[$1]=$1; next} ($1 in ft && $4 + 0 > 50) {print $0 }' \
    <(zcat ${ref_geneinfo}  | grep -P "${kept_gene_type}" | cut -f 4 ) \
    <(zcat ${output_dir}/${prefix}.feature.tsv.gz)| \
    grep -vP "${rm_gene_regex}" >> ${output_dir}/${prefix}.feature.clean.tsv

gzip -f ${output_dir}/${prefix}.feature.clean.tsv

# 2) Create SGE matrix in FICTURE format
echo -e "\n#=== 2)  Prepare a SGE matrix in FICTURE format===#"
command time -v ${python} ${ficture}/script/filter_poly.py \
    --input ${output_dir}/${prefix}.merged.matrix.tsv.gz \
    --feature ${output_dir}/${prefix}.feature.clean.tsv.gz \
    --output ${output_dir}/${prefix}.QCed.matrix.tsv.gz \
    --output_boundary ${output_dir}/${prefix} \
    --filter_based_on ${sf} \
    --mu_scale $ap_mu_scale \
    --radius $ap_radius \
    --quartile $ap_quartile \
    --hex_n_move $ap_hex_n_move \
    --remove_small_polygons $ap_remove_small_polygons \

# 3) Tabix the QCed matrix
echo -e "\n#=== 3) Tabix the QCed matrix ===#"
zcat ${output_dir}/${prefix}.QCed.matrix.tsv.gz | bgzip -c > ${output_dir}/${prefix}.QCed.matrix.tsv.gz.tmp.gz
mv ${output_dir}/${prefix}.QCed.matrix.tsv.gz.tmp.gz ${output_dir}/${prefix}.QCed.matrix.tsv.gz

if [ $major_axis == "Y" ]; then
    tabix_column="-b4 -e4"
else
    tabix_column="-b3 -e3"
fi

tabix -0 -f -s1 ${tabix_column} ${output_dir}/${prefix}.QCed.matrix.tsv.gz

