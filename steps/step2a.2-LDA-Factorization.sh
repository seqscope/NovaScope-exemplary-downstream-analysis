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

# Examine the required input files
required_files=(
    "${model_dir}/${hexagon_prefix}.tsv.gz"
    "${output_dir}/${prefix}.feature.clean.tsv.gz"
)
check_files_exist "${required_files[@]}"

# ===== ANALYSIS =====
command time -v ${python} ${ficture}/script/lda_univ.py \
    --epoch ${ep} \
    --epoch_id_length 2 \
    --feature ${output_dir}/${prefix}.feature.clean.tsv.gz \
    --key ${sf} \
    --input ${model_dir}/${hexagon_prefix}.tsv.gz \
    --output_pref ${model_dir}/${train_prefix} \
    --nFactor ${nf} \
    --min_ct_per_unit 50 \
    --min_ct_per_feature 50 \
    --thread $threads \
    --unit_attr X Y \
    --overwrite \
    --seed ${seed}
