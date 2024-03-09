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
    module load Bioinformatics
    module load samtools
    module load python/3.9.12
fi

source ${py39_env}/bin/activate
py39=${py39_env}/bin/python

# Examine the required input files
required_files=(
    "${model_dir}/matrix.mtx.gz"
    "${model_dir}/barcodes.tsv.gz"
    "${model_dir}/features.tsv.gz"
)
check_files_exist "${required_files[@]}"

# ===== ANALYSIS =====
# Review the Dim and Spatial plots from the `step2b-Seurat-02-clustering.sh` and select a resolution for to proceed.
# Add those variables to the input_data_and_params file or below.

# Example:
# nFeature_RNA_cutoff=100
# res_of_interest=1  

# convert metadata to a count matrix
echo -e "\n#=== sub-step 4. Create model file ===#"

echo -e "\nresolution: $res_of_interest\n"

command time -v ${py39} ${neda}/scripts/seurat_cluster_to_count_matrix_for_categorical.py\
    --input_csv ${output_dir}/Seurat/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv  \
    --dge_path ${output_dir}/Seurat \
    --output ${output_dir}/Seurat/${prefix}_cutoff${nFeature_RNA_cutoff}_clusterbyres${res_of_interest}.tsv.gz \
    --key ${sf} \
    --cluster SCT_snn_res.${res_of_interest} \
    --x_col 2 \
    --y_col 3 

# link the model file
new_nf=$(zcat ${output_dir}/Seurat/${prefix}_cutoff${nFeature_RNA_cutoff}_clusterbyres${res_of_interest}.tsv.gz |head -1 | awk -F '\t' '{print NF-1}')

model_path=${model_dir}/${prefix}.${sf}.nF${new_nf}.d_${tw}.s_${ep}.model.tsv.gz
# link the model file if it does not exist
if [ ! -f ${model_path} ]; then
    ln -s ${output_dir}/Seurat/${prefix}_cutoff${nFeature_RNA_cutoff}_clusterbyres${res_of_interest}.tsv.gz ${model_path}
fi

# You can manually update nf in the input_data_and_params file or use below 
if grep -q '^nf=' "$input_data_and_params"; then
    sed -i "s/^nf=.*/nf=$new_nf/" "$input_data_and_params"
else
    echo "== Update nf =="
    echo "nf=$new_nf" >> "$input_data_and_params"
fi