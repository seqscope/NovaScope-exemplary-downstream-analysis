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
sge_bcd="${sge_dir}/barcodes.tsv.gz"
sge_ftr="${sge_dir}/features.tsv.gz"
sge_mtx="${sge_dir}/matrix.mtx.gz"
transcripts="${work_dir}/${prefix}.transcripts.matrix.tsv.gz"

# * output:
feature="${work_dir}/${prefix}.feature.tsv.gz"
feature_clean="${work_dir}/${prefix}.feature.clean.tsv.gz"
transcripts_filtered="${work_dir}/${prefix}.transcripts_filtered.matrix.tsv.gz"
# * output prefix:
filtered_boundary_prefix="${work_dir}/${prefix}"
# * temporary:
feature_clean_tmp="${work_dir}/${prefix}.feature.clean.tsv"
transcripts_filtered_tmp="${work_dir}/${prefix}.transcripts_filtered_tmp.matrix.tsv.gz"

# Examine the input data
# if `input_transcripts` is defined and not empty and the file exists
if [[ -n "$input_transcripts" ]] && [[ -f "$input_transcripts" ]]; then 
    echo "input_transcripts is defined and points to an existing file."

required_files=(
    ${sge_bcd}
    ${sge_ftr}
    ${sge_mtx}
    ${transcripts}
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
# 1) Create a QCed feature file via filtering gene types and density
echo -e "\n#=== 1) Prepare a clean feature file ===#"

# Convert the feature file to a tab-delimited format. This will be used as input to prepare a QCed feature file.
zcat ${sge_ftr} | cut -f 1,2,4 | sed 's/,/\t/g' | sed '1 s/^/gene_id\tgene\tgn\tgt\tspl\tunspl\tambig\n/' | gzip -c > ${feature}

# Define which gene types to keep and which gene names to remove
kept_gene_type=$(echo "$ap_kept_gene_types" | sed 's/,/\|/') 
rm_gene_regex=$(echo "$ap_removed_gene_types" | sed 's/\^/\\t/g')

# Define the header of the QCed feature file
echo -e "gene_id\tgene\tgn\tgt\tspl\tunspl\tambig" > ${feature_clean_tmp}

# Filter the feature file by gene types and density
# Here density threshold is set to GeneFull > 50, which is a default setting in the FICTURE pipeline.
awk 'BEGIN{FS=OFS="\t"} NR==FNR {ft[$1]=$1; next} ($1 in ft && $4 + 0 > 50) {print $0 }' \
    <(zcat ${ref_geneinfo}  | grep -P "${kept_gene_type}" | cut -f 4 ) \
    <(zcat ${feature})| \
    grep -vP "${rm_gene_regex}" >> ${feature_clean_tmp}

gzip -f ${feature_clean_tmp}

# 2) Create SGE matrix in FICTURE format
echo -e "\n#=== 2)  Prepare a SGE matrix in FICTURE format===#"
command time -v python ${ficture}/script/filter_poly.py \
    --input ${transcripts} \
    --feature ${feature_clean} \
    --output ${transcripts_filtered} \
    --output_boundary ${filtered_boundary_prefix} \
    --filter_based_on ${sf} \
    --mu_scale $ap_mu_scale \
    --radius $ap_radius \
    --quartile $ap_quartile \
    --hex_n_move $ap_hex_n_move \
    --remove_small_polygons $ap_remove_small_polygons \

# 3) Tabix the filtered matrix
echo -e "\n#=== 3) Tabix the filtered matrix ===#"
if [ $major_axis == "Y" ]; then
    tabix_column="-b4 -e4"
else
    tabix_column="-b3 -e3"
fi

zcat ${transcripts_filtered} | bgzip -c > ${transcripts_filtered_tmp}
mv ${transcripts_filtered_tmp} ${transcripts_filtered}
tabix -0 -f -s1 ${tabix_column} ${transcripts_filtered}

