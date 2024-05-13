# ===== SET UP =====
set -ueo pipefail

if [ $# -ne 1 ]; then
    echo -e "Usage: $0 <input_data_and_params>"
    exit 1
fi

echo -e "#=====================\n#"
echo -e "# $(basename "$0") \n#"
echo -e "#=====================\n#"

# Read input config
neda=$(dirname $(dirname "$0"))
source $neda/scripts/process_input.sh
process_config_job $1

# Define the input and output paths and files
# * input:
transcripts_filtered="${output_dir}/${prefix}.transcripts_filtered.matrix.tsv.gz"
# * output:
minibatches="${output_dir}/${prefix}.batched.matrix.tsv.gz"
# * temporary:
minibatches_tsv="${output_dir}/${prefix}.batched.matrix.tsv"

# Examine the input data
required_files=(
    ${transcripts_filtered}
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_mu_scale=1000
ap_batch_size=500
ap_batch_buff=30

# ===== ANALYSIS =====
# 1) Reformat the input file by assigning minibatch label,
command time -v python ${ficture}/script/make_spatial_minibatch.py \
    --input ${transcripts_filtered} \
    --output ${minibatches_tsv} \
    --mu_scale $ap_mu_scale \
    --batch_size $ap_batch_size \
    --batch_buff $ap_batch_buff \
    --major_axis $major_axis 

# 2) Reorder the data based on the major axis so that they are locally contiguous.
# Determine the sort column based on the major_axis value
if [ $major_axis == "Y" ]; then
    sort_column="-k4,4n"
else
    sort_column="-k3,3n"
fi

sort -S 10G -k2,2n $sort_column ${minibatches_tsv} | bgzip -c > ${minibatches}

