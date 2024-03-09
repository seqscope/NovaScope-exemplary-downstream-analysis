#!/usr/bin/bash
# ===== SET UP =====
set -ueo pipefail

# Processing the input_data_and_params.
if [ $# -ne 1 ]; then
    echo -e "Usage: $0 <path_to_file>"
    exit 1
fi

echo -e "#=====================\n#"
echo -e "# $(basename "$0") \n#"
echo -e "#=====================\n#"

neda=$(dirname "$0")
input_data_and_params="$1"

source $neda/scripts/process_input.sh

process_input_data_and_params $input_data_and_params

if [[ $execution_mode == "HPC" ]]; then
    module load Bioinformatics
    module load samtools
    module load python/3.9.12
fi

source ${py39_env}/bin/activate
py39=${py39_env}/bin/python

# (Seurat-only) Sanity check - make sure nf is defined
if [[ -z $nf ]]; then
    echo -e "Error: nf is not defined. Please define nf in the input_data_and_params file."
    exit 1
fi

# Examine the required input files
required_files=(
    "${output_dir}/${prefix}.QCed.matrix.tsv.gz "
    "${output_dir}/${prefix}.coordinate_minmax.tsv"
    "${model_path}"
)

if [[ $train_model == "LDA" ]]; then
    required_files+=("${model_dir}/${train_prefix}.rgb.tsv")        # requires rgb from train
fi

check_files_exist "${required_files[@]}"

# ===== ANALYSIS =====
# Transform
echo -e "\n#=== sub-step.1 Transform ===#"

if [ -z $p_move ] ; then
    echo -e "Error: p_move is not defined. Please check if your have pw and ar in the input_data_and_params file."
    exit 1
fi

command time -v ${py39} ${ficture}/script/transform_univ.py  \
    --key ${sf} \
    --input ${output_dir}/${prefix}.QCed.matrix.tsv.gz \
    --model ${model_path}  \
    --output_pref ${model_dir}/${tranform_prefix} \
    --hex_width ${pw}  \
    --n_move ${p_move}   \
    --min_ct_per_unit 20 \
    --mu_scale 1000 \
    --thread $threads \
    --precision 2  \
    --major_axis X

# If needed, create the color table.
echo -e "\n#=== sub-step.2 Choose color ===#"

if [[ -f "${model_dir}/${tranform_prefix}.rgb.tsv" ]]; then
    echo -e "Skip given color table already exists: ${model_dir}/${tranform_prefix}.rgb.tsv"
else
    if [[ $train_model == "LDA" ]]; then
        echo -e "For LDA. Use the color table from the training model."
        ln -s ${model_dir}/${train_prefix}.rgb.tsv ${model_dir}/${tranform_prefix}.rgb.tsv
    else 
        echo -e "For Seurat. Create the color table from the transformed data."
        ${py39} ${ficture}/script/choose_color.py \
            --input ${model_dir}/${tranform_prefix}.fit_result.tsv.gz\
            --output ${model_dir}/${tranform_prefix} \
            --cmap_name turbo
    fi
fi

# Tranform top figure
echo -e "\n#=== sub-step.3 Plot top figure ===#"

while IFS=$'\t' read -r r_key r_val; do
    export "${r_key}"="${r_val}"
done < ${output_dir}/${prefix}.coordinate_minmax.tsv

echo -e "The coordinates ranges are: ${xmin}, ${xmax}; ${ymin}, ${ymax} !"

command time -v ${py39} ${ficture}/script/plot_big.py \
    --input ${model_dir}/${tranform_prefix}.fit_result.tsv.gz \
    --output ${model_dir}/${tranform_prefix} \
    --fill_range 3 \
    --color_table ${model_dir}/${tranform_prefix}.rgb.tsv \
    --plot_um_per_pixel 1 \
    --xmin $xmin \
    --xmax $xmax \
    --ymin $ymin \
    --ymax $ymax \
    --horizontal_axis x \
    --plot_fit \
    --plot_discretized