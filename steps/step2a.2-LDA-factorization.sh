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
hexagons="${model_dir}/${hexagon_prefix}.tsv.gz"
ftr_tab_clean="${output_dir}/${prefix}.feature.clean.tsv.gz"
# * output prefix:
train_prefix_w_dir=${model_dir}/${train_prefix}

# Examine the required input files
required_files=(
    ${hexagons}
    ${ftr_tab_clean}
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_lenth_epoch_id=2
ap_min_ct_per_unit=50
ap_min_ct_per_feature=50

# ===== ANALYSIS =====
command time -v python ${ficture}/script/lda_univ.py \
    --epoch ${ep} \
    --epoch_id_length $ap_lenth_epoch_id \
    --feature ${ftr_tab_clean} \
    --key ${sf} \
    --input ${hexagons} \
    --output_pref ${train_prefix_w_dir} \
    --nFactor ${nf} \
    --min_ct_per_unit $ap_min_ct_per_unit \
    --min_ct_per_feature $ap_min_ct_per_feature \
    --thread $threads \
    --unit_attr X Y \
    --overwrite \
    --seed ${seed}
