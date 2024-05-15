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
read_hexagon_index_config $1

# Define the input and output paths and files
# * input:
train_fit="${model_dir}/${train_prefix}.fit_result.tsv.gz"
train_ct="${model_dir}/${train_prefix}.posterior.count.tsv.gz"
# * output:
train_de="${model_dir}/${train_prefix}.bulk_chisq.tsv"
train_rgb="${model_dir}/${train_prefix}.rgb.tsv"
# * output prefix:
train_prefix_w_dir=${model_dir}/${train_prefix}

# Examine the required input files
required_files=(
    "${train_fit}"
    "${train_ct}"
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
# color map
ap_cmap_name="turbo"

# marker genes
ap_min_ct_per_feature=50
ap_max_pval_output=0.001
ap_min_fold_output=1.5

# ===== ANALYSIS =====
# Choose color
command time -v python ${ficture}/script/choose_color.py \
    --input ${train_fit}\
    --output ${train_prefix_w_dir} \
    --cmap_name $ap_cmap_name \
    --seed ${seed}

# Create bulk_chisq file with marker genes for each factor,
command time -v python ${ficture}/script/de_bulk.py \
    --input ${train_ct} \
    --output ${train_de} \
    --min_ct_per_feature $ap_min_ct_per_feature \
    --max_pval_output $ap_max_pval_output \
    --min_fold_output $ap_min_fold_output \
    --thread $threads

# Create a report html file
command time -v python ${ficture}/script/factor_report.py \
    --path ${model_dir} \
    --pref ${train_prefix} \
    --color_table ${train_rgb} \
    --hc_tree
