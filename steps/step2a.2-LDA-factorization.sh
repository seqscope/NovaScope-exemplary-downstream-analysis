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
read_config_for_ST $1 $neda

# Define the input and output paths and files
# * input:
hexagons="${model_dir}/${hexagon_prefix}.tsv.gz"
# * output prefix:
train_prefix_w_dir=${model_dir}/${train_prefix}

# Examine the required input files
required_files=(
    "${hexagons}"
    "${feature_clean}"
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_lenth_epoch_id=2
ap_min_ct_per_unit=50
ap_min_ct_per_feature=50
ap_n_random_init=10

# ===== ANALYSIS =====
command time -v python ${ficture}/ficture/scripts/init_model_selection.py \
    --input ${hexagons} \
    --feature ${feature_clean} \
    --output ${train_prefix_w_dir} \
    --key ${solo_feature} \
    --nFactor ${nfactor} \
    --epoch ${train_n_epoch} \
    --epoch_id_length $ap_lenth_epoch_id \
    --min_ct_per_unit $ap_min_ct_per_unit \
    --min_ct_per_feature $ap_min_ct_per_feature \
    --thread $threads \
    --unit_attr X Y \
    --R $ap_n_random_init \
    --seed ${seed}