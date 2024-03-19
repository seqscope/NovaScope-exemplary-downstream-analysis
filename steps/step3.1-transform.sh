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
    "${output_dir}/${prefix}.QCed.matrix.tsv.gz "
    "${model_path}"
)

if [[ $train_model == "LDA" ]]; then
    required_files+=("${model_dir}/${train_prefix}.rgb.tsv")
fi

check_files_exist "${required_files[@]}"

# ===== ANALYSIS =====
# Transform
if [ -z $p_move ] ; then
    echo -e "Error: p_move is not defined. Please check if your have pw and ar in the input_data_and_params file."
    exit 1
fi

command time -v ${python} ${ficture}/script/transform_univ.py  \
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
