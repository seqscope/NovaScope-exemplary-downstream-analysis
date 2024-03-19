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
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
# None

# ===== ANALYSIS =====
mkdir -p ${output_dir}

if [ $major_axis == "Y" ]; then
    sort_column="-k4,4n"
    tabix_column="-b4 -e4"
else
    sort_column="-k3,3n"
    tabix_column="-b3 -e3"
fi

awk 'BEGIN{FS=OFS="\t"} NR==FNR{ft[$3]=$1 FS $2 ;next} ($1 in ft) {print $2 FS $3 FS $4 FS $5 FS ft[$1] FS $6 FS $7 FS $8 FS $9 FS $10 }' \
    <(zcat ${input_dir}/features.tsv.gz) \
    <(join -t $'\t' -1 1 -2 2 -o '2.1,1.2,1.3,1.4,1.5,2.3,2.4,2.5,2.6,2.7' \
        <(zcat ${input_dir}/barcodes.tsv.gz   | cut -f 2,4-8) \
        <(zcat ${input_dir}/matrix.mtx.gz     | tail -n +4 | sed 's/ /\t/g' )) | \
    sed -E 's/\t[[:alnum:]]+_/\t/' | \
    sort -S 10G -k1,1n $sort_column|\
    sed '1 s/^/#lane\ttile\tX\tY\tgene_id\tgene\tgn\tgt\tspl\tunspl\tambig\n/' | \
    bgzip -c > ${output_dir}/${prefix}.merged.matrix.tsv.gz


tabix -0 -f -s1 $tabix_column ${output_dir}/${prefix}.merged.matrix.tsv.gz

