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

# Examine the required input files
required_files=(
    "${model_dir}/matrix.mtx.gz"
    "${model_dir}/barcodes.tsv.gz"
    "${model_dir}/features.tsv.gz"
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
cmd="Rscript ${neda}/scripts/seurat_analysis.R --input_dir ${model_dir} --output_dir ${model_dir} --unit_id ${prefix} --nFeature_RNA_cutoff $nFeature_RNA_cutoff"

[[ ${#X_min} -ge 1 ]] && cmd+=" --X_min $X_min"
[[ ${#X_max} -ge 1 ]] && cmd+=" --X_max $X_max"
[[ ${#Y_min} -ge 1 ]] && cmd+=" --Y_min $Y_min"
[[ ${#Y_max} -ge 1 ]] && cmd+=" --Y_max $Y_max"

# Execute Seurat analysis
echo -e "$cmd\n"
eval "$cmd"
