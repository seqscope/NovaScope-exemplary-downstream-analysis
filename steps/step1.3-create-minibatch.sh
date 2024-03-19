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
    "${output_dir}/${prefix}.QCed.matrix.tsv.gz"
)
check_files_exist "${required_files[@]}"

# ===== ANALYSIS =====
# 1) Reformat the input file by assigning minibatch label,
command time -v ${python} ${ficture}/script/make_spatial_minibatch.py \
    --input ${output_dir}/${prefix}.QCed.matrix.tsv.gz \
    --output ${output_dir}/${prefix}.batched.matrix.tsv \
    --mu_scale 1000 \
    --batch_size 500 \
    --batch_buff 30 \
    --major_axis X \

# 2) Reorder the data based on the major axis so that they are locally contiguous.
sort -S 10G -k2,2n -k3,3n ${output_dir}/${prefix}.batched.matrix.tsv | bgzip -c > ${output_dir}/${prefix}.batched.matrix.tsv.gz 

