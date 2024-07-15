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
# * input
#   - input_xyrange: defined by the user 
transform_fit="${model_dir}/${tranform_prefix}.fit_result.tsv.gz"

# * (optional) input
train_rgb="${model_dir}/${train_prefix}.rgb.tsv"

# * output
transform_rgb="${model_dir}/${tranform_prefix}.rgb.tsv"

# * output prefix:
transform_prefix_w_dir="${model_dir}/${tranform_prefix}"

# ===== SANITY CHECK =====
# - (Seurat-only) make sure nfactor is defined
if [[ -z $nfactor ]]; then
    echo -e "Error: nfactor is not defined. Please define nfactor in the input_data_and_params file."
    exit 1
fi

# - Required files
required_files=(
    ${input_xyrange}
    ${transform_fit}
)

if [[ $train_model == "LDA" ]]; then
    required_files+=("${train_rgb}")
fi

check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
# color map
ap_cmap_name="turbo"

# plot
ap_plot_horizontal_axis=x
ap_plot_um_per_pixel=1

fill_range=$(($anchor_dist/2+1))

# ===== ANALYSIS =====
# Color table.
if [[ -f $transform_rgb ]]; then
    echo -e "Skip given color table already exists: ${transform_rgb}."
else
    if [[ $train_model == "LDA" ]]; then
        echo -e "For LDA. Use the color table from the training model."
        ln -s ${train_rgb} ${transform_rgb}
    else 
        echo -e "For Seurat. Create the color table from the transformed data."
        python ${ficture}/ficture/scripts/choose_color.py \
            --input ${transform_fit}\
            --output ${transform_prefix_w_dir} \
            --cmap_name ${ap_cmap_name} \
            --seed ${seed}
    fi
fi

# Visualiation
while IFS=$'\t' read -r r_key r_val; do
    export "${r_key}"="${r_val}"
done < ${input_xyrange}
echo -e "The coordinates ranges are: ${xmin}, ${xmax}; ${ymin}, ${ymax} !"

command time -v python ${ficture}/ficture/scripts/plot_base.py \
    --input ${transform_fit} \
    --output ${transform_prefix_w_dir} \
    --fill_range $fill_range \
    --color_table ${transform_rgb} \
    --plot_um_per_pixel ${ap_plot_um_per_pixel} \
    --xmin ${xmin} \
    --xmax ${xmax} \
    --ymin ${ymin} \
    --ymax ${ymax} \
    --plot_fit \
    --plot_discretized
