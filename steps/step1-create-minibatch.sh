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
read_config_for_neda $1 $neda

# ===== INPUT/OUTPUT =====
# * input:
#   - input transcripts: Defined by the user

# * output:
minibatches="${output_dir}/${prefix}.batched.matrix.tsv.gz"

# * temporary:
minibatches_tmp="${output_dir}/${prefix}.batched.matrix.tsv"

# ===== SANITY CHECK =====
required_files=(
    "${input_transcripts}"
)

check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_mu_scale=1000
ap_batch_size=500
ap_batch_buff=30

# ===== ANALYSIS =====
# 1) Reformat the input file by assigning minibatch label,
command time -v python ${ficture}/ficture/scripts/make_spatial_minibatch.py \
    --input ${input_transcripts} \
    --output ${minibatches_tmp} \
    --mu_scale ${ap_mu_scale} \
    --batch_size ${ap_batch_size} \
    --batch_buff ${ap_batch_buff} \
    --major_axis ${major_axis} 

# 2) Reorder the data based on the major axis so that they are locally contiguous.
# Determine the sort column based on the major_axis value
if [ $major_axis == "Y" ]; then
    sort_column="-k4,4n"
else
    sort_column="-k3,3n"
fi

sort -S 10G -k2,2n ${sort_column} ${minibatches_tmp} | bgzip -c > ${minibatches}

