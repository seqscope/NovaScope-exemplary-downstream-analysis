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
# None

# ===== ANALYSIS =====
# Initialize variables to empty strings to avoid unbound variable errors due to set -u
X_min=${X_min-}
X_max=${X_max-}
Y_min=${Y_min-}
Y_max=${Y_max-}

# Define the command for Seurat analysis with the required arguments
cmd="Rscript ${neda}/scripts/seurat_analysis.R --input_dir ${model_dir} --output_dir ${model_dir} --unit_id ${prefix} --nFeature_RNA_cutoff $nFeature_RNA_cutoff "

[[ ${#X_min} -ge 1 ]] && cmd+=" --X_min $X_min"
[[ ${#X_max} -ge 1 ]] && cmd+=" --X_max $X_max"
[[ ${#Y_min} -ge 1 ]] && cmd+=" --Y_min $Y_min"
[[ ${#Y_max} -ge 1 ]] && cmd+=" --Y_max $Y_max"

# Execute Seurat analysis
echo -e "$cmd\n"
eval "$cmd"
