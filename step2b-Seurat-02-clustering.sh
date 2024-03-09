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
    module load R/4.2.0
fi

# Examine the required input files
required_files=(
    "${model_dir}/matrix.mtx.gz"
    "${model_dir}/barcodes.tsv.gz"
    "${model_dir}/features.tsv.gz"
)
check_files_exist "${required_files[@]}"

# ===== ANALYSIS =====
# Review the density plots from the `step2b-Seurat-01-hexagon.sh` and select a threshold for nFeature_RNA while specifying the ranges for x and y. 
# Add those variables to the input_data_and_params file or below.
# Regarding to the thresholds for nFeature_RNA, we applied a cutoff of nFeature_RNA_cutoff=500 for deep sequencing data, and nFeature_RNA_cutoff=100 for shallow sequencing data, .

# Example:
# In this case, the Y_max is not applied. 
# nFeature_RNA_cutoff=100
# X_min=2.5e+06
# X_max=1e+07
# Y_min=1e+06

echo -e "\n#=== sub-step 3. Clustering ===#"

cmd="Rscript ${neda}/scripts/seurat_analysis.R --input_dir ${model_dir} --output_dir ${model_dir} --unit_id ${prefix} --nFeature_RNA_cutoff $nFeature_RNA_cutoff"

[[ -n "$X_min" ]] && cmd+=" --X_min $X_min"
[[ -n "$X_max" ]] && cmd+=" --X_max $X_max"
[[ -n "$Y_min" ]] && cmd+=" --Y_min $Y_min"
[[ -n "$Y_max" ]] && cmd+=" --Y_max $Y_max"

echo -e "$cmd\n"
eval $cmd