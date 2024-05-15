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
# Defined by the user
# * output:
# Only requires dirs

# Examine the required input files
required_files=(
    ${transcripts}
    ${feature}
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_mu_scale=1000
ap_n_move=1                 # To create non-overlapping hexagons, set ap_n_move=1
ap_precision=2
ap_min_ct_per_unit=10

# ===== ANALYSIS =====
mkdir -p ${model_dir}

# Create hexagonal SGE that compatible with Seurat
command time -v python ${ficture}/script/make_sge_by_hexagon.py \
    --input ${transcripts} \
    --feature ${feature} \
    --output_path ${model_dir} \
    --mu_scale $ap_mu_scale \
    --major_axis ${major_axis} \
    --key ${sf}   \
    --precision $ap_precision  \
    --hex_width ${tw}  \
    --n_move $ap_n_move \
    --min_ct_per_unit $ap_min_ct_per_unit  \
    --transfer_gene_prefix

# Test different cutoffs for nFeature_RNA
echo -e "\n#=== sub-step 2. Testing nFeature_RNA cutoffs ===#" 
Rscript ${neda}/scripts/seurat_analysis.R \
    --input_dir ${model_dir} \
    --output_dir ${model_dir} \
    --unit_id ${prefix} \
    --test_mode