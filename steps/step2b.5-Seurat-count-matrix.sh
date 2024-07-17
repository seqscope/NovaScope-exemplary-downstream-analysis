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
read_config_for_neda $1 $neda

# ===== INPUT/OUTPUT =====
# * input:
hex_sge_mtx="${input_hexagon_sge_10x_dir}/matrix.mtx.gz"
hex_sge_bcd="${input_hexagon_sge_10x_dir}/barcodes.tsv.gz"
hex_sge_ftr="${input_hexagon_sge_10x_dir}/features.tsv.gz"
seurat_cluster_meta="${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv"      # from step2b.3-Seurat-clustering.sh

# * output:
ct_mtx="${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_clusterbyres${res_of_interest}.tsv.gz"
#    - renamed_model    # assigned after nf is read from the count matrix file

# ===== SANITY CHECK =====
required_files=(
    "${hex_sge_mtx}"
    "${hex_sge_bcd}"
    "${hex_sge_ftr}"
    "${seurat_cluster_meta}"
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
    --dge_path ${input_hexagon_sge_10x_dir} \
    --output ${ct_mtx} \
    --key ${solo_feature} \
    --cluster "SCT_snn_res.${res_of_interest}" \
    --x_col 2 \
    --y_col 3 

# 2) Examines the count matrix file is valid, and obtain the number of factors (nfactor) from the count matrix file.
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


# Update the nfactor to input_data_and_params file. You can also manually update it, if you prefer. 
echo -e "Updated number of factor: $new_nf"

if grep -q '^nfactor=' "$1"; then
    sed -i "s/^nfactor=.*/nfactor=$new_nf/" "$1"
else
    echo "== Update nfactor =="
    echo -e "nfactor=$new_nf\n" >> "$1"
fi

# Create a symbolic link to the count matrix file, simplifying its location by subsequent steps.
renamed_model="${model_dir}/${prefix}.${solo_feature}.nf${new_nf}.d_${train_width}.s_${train_n_epoch}.model_matrix.tsv.gz"
echo -e "A symbolic link of the model file from Seurat: $renamed_model"

if [[ -f "${renamed_model}" ]]; then
    echo -e "Model file ${renamed_model} already exists..."
else
    echo -e "Linking the model file to ${renamed_model}..."
    ln -s ${ct_mtx} ${renamed_model}
fi

