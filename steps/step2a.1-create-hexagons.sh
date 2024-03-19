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
    "${output_dir}/${prefix}.QCed.matrix.tsv.gz"
    "${output_dir}/${prefix}.QCed.matrix.tsv.gz.tbi"
    "${output_dir}/${prefix}.boundary.strict.geojson"
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_mu_scale=1000
ap_n_move=2
ap_precision=2
ap_min_density_per_unit=0.3

# ===== ANALYSIS =====
mkdir -p ${model_dir}

# 1) Create hexagonal files 
command time -v ${python} ${ficture}/script/make_dge_univ.py \
    --key ${sf} \
    --input ${output_dir}/${prefix}.QCed.matrix.tsv.gz \
    --output ${model_dir}/${hexagon_prefix}.tsv \
    --hex_width ${tw} \
    --n_move $ap_n_move \
    --mu_scale $ap_mu_scale \
    --precision $ap_n_move \
    --major_axis ${major_axis} \
    --min_density_per_unit $ap_min_density_per_unit \
    --boundary ${output_dir}/${prefix}.boundary.strict.geojson

# 2) Sort by the hexagon IDs
sort -S 10G -k1,1n ${model_dir}/${hexagon_prefix}.tsv | gzip -c > ${model_dir}/${hexagon_prefix}.tsv.gz 
