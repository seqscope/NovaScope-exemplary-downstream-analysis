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
process_input_data_and_params $0

# (Seurat-only) Sanity check - make sure nf is defined
if [[ -z $nf ]]; then
    echo -e "Error: nf is not defined. Please define nf in the input_data_and_params file."
    exit 1
fi

# Examine the required input files
required_files=(
    "${model_dir}/${tranform_prefix}.fit_result.tsv.gz"
    "${model_dir}/${tranform_prefix}.posterior.count.tsv.gz"
    "${output_dir}/${prefix}.coordinate_minmax.tsv"
)

if [[ $train_model == "LDA" ]]; then
    required_files+=("${model_dir}/${train_prefix}.rgb.tsv")
fi

check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
# color map
ap_cmap_name="turbo"

# plot
ap_plot_horizontal_axis=x
ap_plot_um_per_pixel=1

fill_range=$(($ar/2+1))

# ===== ANALYSIS =====
# Color table.
if [[ -f "${model_dir}/${tranform_prefix}.rgb.tsv" ]]; then
    echo -e "Skip given color table already exists: ${model_dir}/${tranform_prefix}.rgb.tsv"
else
    if [[ $train_model == "LDA" ]]; then
        echo -e "For LDA. Use the color table from the training model."
        ln -s ${model_dir}/${train_prefix}.rgb.tsv ${model_dir}/${tranform_prefix}.rgb.tsv
    else 
        echo -e "For Seurat. Create the color table from the transformed data."
        ${python} ${ficture}/script/choose_color.py \
            --input ${model_dir}/${tranform_prefix}.fit_result.tsv.gz\
            --output ${model_dir}/${tranform_prefix} \
            --cmap_name $ap_cmap_name
    fi
fi

# Visualiation
while IFS=$'\t' read -r r_key r_val; do
    export "${r_key}"="${r_val}"
done < ${output_dir}/${prefix}.coordinate_minmax.tsv
echo -e "The coordinates ranges are: ${xmin}, ${xmax}; ${ymin}, ${ymax} !"

command time -v ${python} ${ficture}/script/plot_big.py \
    --input ${model_dir}/${tranform_prefix}.fit_result.tsv.gz \
    --output ${model_dir}/${tranform_prefix} \
    --fill_range $fill_range \
    --color_table ${model_dir}/${tranform_prefix}.rgb.tsv \
    --plot_um_per_pixel $ap_plot_um_per_pixel \
    --xmin $xmin \
    --xmax $xmax \
    --ymin $ymin \
    --ymax $ymax \
    --horizontal_axis $ap_plot_horizontal_axis \
    --plot_fit \
    --plot_discretized
