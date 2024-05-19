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

# - (Seurat-only) Sanity check - make sure nfactor is defined
if [[ -z $nfactor ]]; then
    echo -e "Error: nfactor is not defined. Please define nfactor in the input_data_and_params file."
    exit 1
fi

# Define the input and output paths and files
# * input:
transcripts_filtered="${output_dir}/${prefix}.transcripts_filtered.tsv.gz"
# model_path: defined in the read_hexagon_index_config function
# * output prefix:
transform_prefix_w_dir="${model_dir}/${tranform_prefix}"

# Examine the required input files
required_files=(
    "${transcripts_filtered}"
    "${model_path}"
)

if [[ $train_model == "LDA" ]]; then
    required_files+=("${model_dir}/${train_prefix}.rgb.tsv")
fi

check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_mu_scale=1000
ap_precision=2
ap_min_ct_per_unit=20

# projection n_move (proj_n_move):
# It will be automatically calculated using proj_n_move=$((fit_width / anchor_dist)), where the fit_width is the projection width and anchor_dist is the anchor point distance. 
# For example, in the example input_data_and_params files, fit_width=18 and anchor_dist=4, so proj_n_move=4.
if [ -z $proj_n_move ] ; then
    echo -e "Error: proj_n_move is not defined. Please check if your have fit_width and anchor_dist in the input_data_and_params file."
    exit 1
fi

# ===== ANALYSIS =====
# Transform
command time -v python ${ficture}/ficture/scripts/transform_univ.py  \
    --input ${transcripts_filtered} \
    --model ${model_path}  \
    --output ${transform_prefix_w_dir} \
    --key ${solo_feature} \
    --hex_width ${fit_width}  \
    --n_move ${proj_n_move}   \
    --min_ct_per_unit ${ap_min_ct_per_unit} \
    --mu_scale ${ap_mu_scale} \
    --thread ${threads} \
    --precision ${ap_precision}  \
    --major_axis ${major_axis}
