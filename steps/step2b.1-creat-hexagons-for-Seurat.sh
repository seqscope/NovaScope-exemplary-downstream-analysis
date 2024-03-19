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
    "${output_dir}/${prefix}.merged.matrix.tsv.gz "
    "${output_dir}/${prefix}.feature.tsv.gz"
)
check_files_exist "${required_files[@]}"

# ===== ANALYSIS =====
mkdir -p ${model_dir}

# Create hexagonal SGE that compatible with Seurat
command time -v ${py39} ${ficture}/script/make_sge_by_hexagon.py \
    --input ${output_dir}/${prefix}.merged.matrix.tsv.gz \
    --feature ${output_dir}/${prefix}.feature.tsv.gz \
    --output_path ${model_dir} \
    --mu_scale 1000 \
    --major_axis X \
    --key ${sf}   \
    --precision 2  \
    --hex_width ${tw}  \
    --n_move 1 \
    --min_ct_per_unit 10  \
    --transfer_gene_prefix

# Test different cutoffs for nFeature_RNA
echo -e "\n#=== sub-step 2. Testing nFeature_RNA cutoffs ===#" 
Rscript ${neda}/scripts/seurat_analysis.R \
    --input_dir ${model_dir} \
    --output_dir ${model_dir} \
    --unit_id ${prefix} \
    --test_mode