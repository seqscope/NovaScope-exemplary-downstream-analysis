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

# Define the input and output paths and files
# * input:
transcripts_filtered="${output_dir}/${prefix}.transcripts_filtered.matrix.tsv.gz"
transcripts_filtered_tbi="${output_dir}/${prefix}.transcripts_filtered.matrix.tsv.gz.tbi"
strict_boundary="${output_dir}/${prefix}.boundary.strict.geojson"
# * output:
hexagons="${model_dir}/${hexagon_prefix}.tsv.gz"
# * temporary:
hexagons_tsv="${model_dir}/${hexagon_prefix}.tsv"

# Examine the required input files
required_files=(
    ${transcripts_filtered}
    ${transcripts_filtered_tbi}
    ${strict_boundary}
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
command time -v python ${ficture}/script/make_dge_univ.py \
    --key ${sf} \
    --input ${transcripts_filtered} \
    --output ${hexagons_tsv} \
    --hex_width ${tw} \
    --n_move $ap_n_move \
    --mu_scale $ap_mu_scale \
    --precision $ap_n_move \
    --major_axis ${major_axis} \
    --min_density_per_unit $ap_min_density_per_unit \
    --boundary ${strict_boundary}

# 2) Sort by the hexagon IDs
sort -S 10G -k1,1n ${hexagons_tsv}  | gzip -c > ${hexagons}
