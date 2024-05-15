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

# (Seurat-only) Sanity check - make sure nfactor is defined
if [[ -z $nfactor ]]; then
    echo -e "Error: number of factors (nfactor) is not defined. Please define nfactor in the input_data_and_params file."
    exit 1
fi

# Define the input and output paths and files
# * input
transform_rgb="${model_dir}/${tranform_prefix}.rgb.tsv"
decode_ct="${model_dir}/${decode_prefix}.posterior.count.tsv.gz"
decode_pixel="${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz"
# * output
decode_de="${model_dir}/${decode_prefix}.bulk_chisq.tsv"
decode_pixel_png="${model_dir}/${decode_prefix}.pixel.png"

# Examine the required input files
required_files=(
    "${transform_rgb}"
    "${decode_ct}"
    "${decode_pixel}"
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
command time -v python ${ficture}/ficture/scripts/de_bulk.py \
    --input ${decode_ct} \
    --output ${decode_de} \
    --min_ct_per_feature $ap_min_ct_per_feature \
    --max_pval_output $ap_max_pval_output \
    --min_fold_output $ap_min_fold_output \
    --thread $threads

# 2) Create the high-resolution image of cell type factors for individual pixels.
command time -v python ${ficture}/ficture/scripts/plot_pixel_full.py \
    --input ${decode_pixel} \
    --output ${decode_pixel_png}  \
    --color_table ${transform_rgb} \
    --plot_um_per_pixel $ap_plot_um_per_pixel \
    --full

# 3) create an HTML file summarizing individual factors and marker genes. 
echo -e "\n#=== sub-step.4 DE Report ===#"
command time -v python ${ficture}/ficture/scripts/factor_report.py \
    --path ${model_dir} \
    --pref ${decode_prefix} \
    --color_table ${transform_rgb} \
    --hc_tree
