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
# - transcripts: Defined by the user
# - feature_clean: Defined by the user
transcripts_tbi="${transcripts}.tbi"
# * output:
transcripts_filtered="${output_dir}/${prefix}.transcripts_filtered.tsv.gz"
# * output prefix:
filtered_boundary_prefix="${output_dir}/${prefix}"
# * temporary:
transcripts_filtered_tmp="${output_dir}/${prefix}.transcripts_filtered_tmp.tsv.gz"

# Examine the input data
required_files=(
    "${transcripts}"
    "${transcripts_tbi}"
    "${feature_clean}"
)
check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_kept_gene_types="protein_coding,lncRNA"
ap_removed_gene_types="^Gm\d+|^mt-|^MT-"

ap_mu_scale=1000
ap_radius=15
ap_quartile=2
ap_hex_n_move=2
ap_remove_small_polygons=500

# ===== ANALYSIS =====
# 1) Create SGE matrix in FICTURE format
echo -e "\n#=== 1)  Prepare a SGE matrix in FICTURE format===#"
command time -v python ${ficture}/script/filter_poly.py \
    --input ${transcripts} \
    --feature ${feature_clean} \
    --output ${transcripts_filtered} \
    --output_boundary ${filtered_boundary_prefix} \
    --filter_based_on ${solo_feature} \
    --mu_scale $ap_mu_scale \
    --radius $ap_radius \
    --quartile $ap_quartile \
    --hex_n_move $ap_hex_n_move \
    --remove_small_polygons $ap_remove_small_polygons \

# 2) Tabix the filtered matrix
echo -e "\n#=== 3) Tabix the filtered matrix ===#"
if [ $major_axis == "Y" ]; then
    tabix_column="-b4 -e4"
else
    tabix_column="-b3 -e3"
fi

zcat ${transcripts_filtered} | bgzip -c > ${transcripts_filtered_tmp}
mv ${transcripts_filtered_tmp} ${transcripts_filtered}
tabix -0 -f -s1 ${tabix_column} ${transcripts_filtered}

