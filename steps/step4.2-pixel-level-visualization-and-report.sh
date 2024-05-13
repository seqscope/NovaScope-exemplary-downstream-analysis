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

# (Seurat-only) Sanity check - make sure nf is defined
if [[ -z $nf ]]; then
    echo -e "Error: number of factors (nf) is not defined. Please define nf in the input_data_and_params file."
    exit 1
fi

# Examine the required input files
required_files=(
    "${model_dir}/${tranform_prefix}.rgb.tsv"
    "${model_dir}/${decode_prefix}.posterior.count.tsv.gz"
    "${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz"
)

check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
# marker genes
ap_min_ct_per_feature=50
ap_max_pval_output=0.001
ap_min_fold_output=1.5

# plot
ap_plot_um_per_pixel=0.5

# ===== ANALYSIS =====
# 1) Identify marker genes for each factor/cluster.
command time -v python ${ficture}/script/de_bulk.py \
    --input ${model_dir}/${decode_prefix}.posterior.count.tsv.gz \
    --output ${model_dir}/${decode_prefix}.bulk_chisq.tsv \
    --min_ct_per_feature $ap_min_ct_per_feature \
    --max_pval_output $ap_max_pval_output \
    --min_fold_output $ap_min_fold_output \
    --thread $threads

# 2) Create the high-resolution image of cell type factors for individual pixels.
command time -v python ${ficture}/script/plot_pixel_full.py \
    --input ${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz \
    --output ${model_dir}/${decode_prefix}.pixel.png  \
    --color_table ${model_dir}/${tranform_prefix}.rgb.tsv \
    --plot_um_per_pixel $ap_plot_um_per_pixel \
    --full

# 3) create an HTML file summarizing individual factors and marker genes. 
echo -e "\n#=== sub-step.4 DE Report ===#"
command time -v python ${ficture}/script/factor_report.py \
    --path ${model_dir} \
    --pref ${decode_prefix} \
    --color_table ${model_dir}/${tranform_prefix}.rgb.tsv \
    --hc_tree
