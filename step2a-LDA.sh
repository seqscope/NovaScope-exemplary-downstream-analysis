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
    "${output_dir}/${prefix}.QCed.matrix.tsv.gz"
    "${output_dir}/${prefix}.QCed.matrix.tsv.gz.tbi"
    "${output_dir}/${prefix}.feature.clean.tsv.gz"
    "${output_dir}/${prefix}.boundary.strict.geojson"
)
check_files_exist "${required_files[@]}"

# ===== ANALYSIS =====
mkdir -p ${model_dir}

# Create hexagonal files
echo -e "\n#=== sub-step 1. Creating Hexagons ===#"

command time -v ${py39} ${ficture}/script/make_dge_univ.py \
    --key ${sf} \
    --input ${output_dir}/${prefix}.QCed.matrix.tsv.gz \
    --output ${model_dir}/${hexagon_prefix}.tsv \
    --hex_width ${tw} \
    --n_move 2 \
    --mu_scale 1000 \
    --precision 2 \
    --major_axis X \
    --min_density_per_unit 0.3 \
    --boundary ${output_dir}/${prefix}.boundary.strict.geojson

sort -S 10G -k1,1n ${model_dir}/${hexagon_prefix}.tsv | gzip -c > ${model_dir}/${hexagon_prefix}.tsv.gz 

# LDA Factorization
echo -e "\n#=== sub-step 2. LDA Factorization ===#"
command time -v ${py39} ${ficture}/script/lda_univ.py \
    --epoch ${ep} \
    --epoch_id_length 2 \
    --feature ${output_dir}/${prefix}.feature.clean.tsv.gz \
    --key ${sf} \
    --input ${model_dir}/${hexagon_prefix}.tsv.gz \
    --output_pref ${model_dir}/${train_prefix} \
    --nFactor ${nf} \
    --min_ct_per_unit 50 \
    --min_ct_per_feature 50 \
    --thread $threads \
    --unit_attr X Y \
    --overwrite \
    --seed ${seed}

# Choose color
echo -e "\n#=== sub-step 3. Generate a color table ===#"

command time -v ${py39} ${ficture}/script/choose_color.py \
    --input ${model_dir}/${train_prefix}.fit_result.tsv.gz \
    --output ${model_dir}/${train_prefix} \
    --cmap_name turbo

# Examine DE 
echo -e "\n#=== sub-step 4. Generate a DE ===#"
command time -v ${py39} ${ficture}/script/de_bulk.py \
    --input ${model_dir}/${train_prefix}.posterior.count.tsv.gz \
    --output ${model_dir}/${train_prefix}.bulk_chisq.tsv \
    --min_ct_per_feature 50 \
    --max_pval_output 0.001 \
    --min_fold_output 1.5 \
    --thread $threads

# Create a report html file
deactivate
source $py310_env/bin/activate

echo -e "\n#=== sub-step 5. Generate a HTML report file ===#"
command time -v $py310_env/bin/python ${ficture}/script/factor_report.py \
    --path ${model_dir} \
    --pref ${train_prefix} \
    --color_table ${model_dir}/${train_prefix}.rgb.tsv \
    --hc_tree
