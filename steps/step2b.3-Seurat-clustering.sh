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
# * input:
hex_sge_mtx="${input_hexagon_sge_10x_dir}/matrix.mtx.gz"
hex_sge_bcd="${input_hexagon_sge_10x_dir}/barcodes.tsv.gz"
hex_sge_ftr="${input_hexagon_sge_10x_dir}/features.tsv.gz"
# * output:
#   - Only requires dirs

# ===== SANITY CHECK =====
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
echo -e "\nnFeature_RNA_cutoff: $nFeature_RNA_cutoff\n"

cmd="Rscript ${neda}/scripts/seurat_analysis.R --input_dir ${input_hexagon_sge_10x_dir} --output_dir ${model_dir} --unit_id ${prefix} --nFeature_RNA_cutoff $nFeature_RNA_cutoff "

[[ ${#X_min} -ge 1 ]] && cmd+=" --X_min $X_min"
[[ ${#X_max} -ge 1 ]] && cmd+=" --X_max $X_max"
[[ ${#Y_min} -ge 1 ]] && cmd+=" --Y_min $Y_min"
[[ ${#Y_max} -ge 1 ]] && cmd+=" --Y_max $Y_max"

# Execute Seurat analysis
echo -e "$cmd\n"
eval "$cmd"
