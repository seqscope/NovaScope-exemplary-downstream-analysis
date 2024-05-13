# ===== SET UP =====
#set -ueo pipefail

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
sge_bcd="${input_dir}/barcodes.tsv.gz"
sge_ftr="${input_dir}/features.tsv.gz"
sge_mtx="${input_dir}/matrix.mtx.gz"
seurat_cluster_meta="${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv"

# * output:
ct_mtx="${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_clusterbyres${res_of_interest}.tsv.gz"
renamed_model="${model_dir}/${prefix}.${sf}.nF${new_nf}.d_${tw}.s_${ep}.model.tsv.gz"
# * temporary:

# Examine the input files
required_files=(
    $sge_bcd
    $sge_ftr
    $sge_mtx
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
# None

# ===== ANALYSIS =====
# 1) convert metadata to a count matrix
# The x_col and y_col specify which column in the hexagon ID file to use as the x and y coordinates.
echo -e "\nresolution: $res_of_interest\n"

command time -v python ${neda}/scripts/seurat_cluster_to_count_matrix_for_categorical.py\
    --input_csv ${seurat_cluster_meta} \
    --dge_path ${model_dir} \
    --output ${ct_mtx} \
    --key ${sf} \
    --cluster "SCT_snn_res.${res_of_interest}" \
    --x_col 2 \
    --y_col 3 

# 2) Examines the count matrix file is valid, and obtain the number of factors (nf) from the count matrix file.
echo -e "count matrix file: $ct_mtx"

if [[ ! -f "$ct_mtx" ]]; then
    echo -e "Error: File not found: $ct_mtx" 
    exit 1
elif [[ ! -s "$ct_mtx" ]]; then
    echo -e "Error: File is empty: $ct_mtx" 
    exit 1
else
    new_nf=$(zcat "$ct_mtx" | head -1 | awk -F '\t' '{print NF-1}')
fi

# Update the nf to input_data_and_params file. You can also manually update it, if you prefer. 
echo -e "Updated number of factor: $new_nf"

if grep -q '^nf=' "$1"; then
    sed -i "s/^nf=.*/nf=$new_nf/" "$1"
else
    echo "== Update nf =="
    echo -e "nf=$new_nf\n" >> "$1"
fi

# Create a symbolic link to the count matrix file, simplifying its location by subsequent steps.
echo -e "A symbolic link of the model file from Seurat: $renamed_model"

if [[ -f "${renamed_model}" ]]; then
    echo -e "Model file ${renamed_model} already exists..."
else
    echo -e "Linking the model file to ${renamed_model}..."
    ln -s ${ct_mtx} ${renamed_model}
fi

