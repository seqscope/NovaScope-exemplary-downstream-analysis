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

# Examine the required input files
required_files=(
    "${model_dir}/${train_prefix}.fit_result.tsv.gz"
    "${model_dir}/${train_prefix}.posterior.count.tsv.gz"
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
    --input ${model_dir}/${train_prefix}.fit_result.tsv.gz \
    --output ${model_dir}/${train_prefix} \
    --cmap_name $ap_cmap_name \
    --seed ${seed}

# Create bulk_chisq file with marker genes for each factor,
command time -v python ${ficture}/script/de_bulk.py \
    --input ${model_dir}/${train_prefix}.posterior.count.tsv.gz \
    --output ${model_dir}/${train_prefix}.bulk_chisq.tsv \
    --min_ct_per_feature $ap_min_ct_per_feature \
    --max_pval_output $ap_max_pval_output \
    --min_fold_output $ap_min_fold_output \
    --thread $threads

# Create a report html file
command time -v python ${ficture}/script/factor_report.py \
    --path ${model_dir} \
    --pref ${train_prefix} \
    --color_table ${model_dir}/${train_prefix}.rgb.tsv \
    --hc_tree
