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
read_hexagon_index_config $1

# Define the input and output paths and files
# * input:
hex_sge_mtx="${hexagon_sge_dir}/matrix.mtx.gz"
hex_sge_bcd="${hexagon_sge_dir}/barcodes.tsv.gz"
hex_sge_ftr="${hexagon_sge_dir}/features.tsv.gz"
# * output:
# Only requires dirs

# Examine the required input files
required_files=(
    "${hex_sge_mtx}"
    "${hex_sge_bcd}"
    "${hex_sge_ftr}"
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_mu_scale=1000
ap_n_move=1                 # To create non-overlapping hexagons, set ap_n_move=1
ap_precision=2
ap_min_ct_per_unit=10

# ===== ANALYSIS =====
mkdir -p ${model_dir}


# Test different cutoffs for nFeature_RNA
echo -e "\n#=== sub-step 2. Testing nFeature_RNA cutoffs ===#" 
Rscript ${neda}/scripts/seurat_analysis.R \
    --input_dir ${model_dir} \
    --output_dir ${model_dir} \
    --unit_id ${prefix} \
    --test_mode