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
    "${model_dir}/matrix.mtx.gz"
    "${model_dir}/barcodes.tsv.gz"
    "${model_dir}/features.tsv.gz"
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
# None

# ===== ANALYSIS =====
# 1) convert metadata to a count matrix
# The x_col and y_col specify which column in the hexagon ID file to use as the x and y coordinates.
echo -e "\nresolution: $res_of_interest\n"

cnt_mat="${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_clusterbyres${res_of_interest}.tsv.gz"
command time -v ${python} ${neda}/scripts/seurat_cluster_to_count_matrix_for_categorical.py\
    --input_csv ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv  \
    --dge_path ${model_dir} \
    --output ${cnt_mat} \
    --key ${sf} \
    --cluster "SCT_snn_res.${res_of_interest}" \
    --x_col 2 \
    --y_col 3 

# 2) Examines the count matrix file is valid, and obtain the number of factors (nf) from the count matrix file.
echo -e "count matrix file: $cnt_mat"

if [[ ! -f "$cnt_mat" ]]; then
    echo -e "Error: File not found: $cnt_mat" 
    exit 1
elif [[ ! -s "$cnt_mat" ]]; then
    echo -e "Error: File is empty: $cnt_mat" 
    exit 1
else
    new_nf=$(zcat "$cnt_mat" | head -1 | awk -F '\t' '{print NF-1}')
fi

# Update the nf to input_data_and_params file. You can also manually update it, if you prefer. 
echo -e "New nf: $new_nf"
if grep -q '^nf=' "$input_data_and_params"; then
    sed -i "s/^nf=.*/nf=$new_nf/" "$input_data_and_params"
else
    echo "== Update nf =="
    echo "nf=$new_nf" >> "$input_data_and_params"
fi

# Create a symbolic link to the count matrix file, simplifying its location by subsequent steps.
model_path="${model_dir}/${prefix}.${sf}.nF${new_nf}.d_${tw}.s_${ep}.model.tsv.gz"
echo -e "model file: $model_path"

if [[ -f "${model_path}" ]]; then
    echo -e "Model file ${model_path} already exists"
else
    echo -e "Linking the model file to ${model_path}"
    ln -s "${cnt_mat}" "${model_path}"
fi

