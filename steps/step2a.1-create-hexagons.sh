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

# ===== ANALYSIS =====
mkdir -p ${model_dir}

# 1) Create hexagonal files 
command time -v ${python} ${ficture}/script/make_dge_univ.py \
    --key ${sf} \
    --input ${output_dir}/${prefix}.QCed.matrix.tsv.gz \
    --output ${model_dir}/${hexagon_prefix}.tsv \
    --hex_width ${tw} \
    --n_move 2 \
    --mu_scale 1000 \
    --precision 2 \
    --major_axis X \
    --min_density_per_unit 0.3 \
    --boundary ${output_dir}/${prefix}.boundary.strict.geojson

# 2) Sort based on the major axis
sort -S 10G -k1,1n ${model_dir}/${hexagon_prefix}.tsv | gzip -c > ${model_dir}/${hexagon_prefix}.tsv.gz 
