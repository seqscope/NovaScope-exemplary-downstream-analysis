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

# (Seurat-only) Sanity check - make sure nf is defined
if [[ -z $nf ]]; then
    echo -e "Error: nf is not defined. Please define nf in the input_data_and_params file."
    exit 1
fi

# Examine the required input files
required_files=(
    "${output_dir}/${prefix}.coordinate_minmax.tsv"
    "${output_dir}/${prefix}.batched.matrix.tsv.gz "
    "${model_path}"
    "${model_dir}/${tranform_prefix}.fit_result.tsv.gz"
    "${model_dir}/${tranform_prefix}.rgb.tsv"
)

check_files_exist "${required_files[@]}"

# ===== ANALYSIS =====
# decode 
echo -e "\n#=== sub-step.1 Decode ===#"

if [[ -z $nr ]]; then
    echo -e "Error: nr is not defined. Please define nr in the input_data_and_params file."
    exit 1
fi

command time -v ${py39} ${ficture}/script/slda_decode.py  \
    --input ${output_dir}/${prefix}.batched.matrix.tsv.gz \
    --model ${model_path}\
    --anchor ${model_dir}/${tranform_prefix}.fit_result.tsv.gz\
    --output ${model_dir}/${decode_prefix} \
    --anchor_in_um \
    --neighbor_radius ${nr} \
    --mu_scale 1000 \
    --key ${sf} \
    --precision 0.25 \
    --lite_topk_output_pixel 3 \
    --lite_topk_output_anchor 3 \
    --thread $threads

while IFS=$'\t' read -r r_key r_val; do
    export "${r_key}"="${r_val}"
done < ${output_dir}/${prefix}.coordinate_minmax.tsv

offsetx=${xmin}
offsety=${ymin}
rangex=$( echo "(${xmax} - ${xmin} + 0.5)/1+1" | bc )
rangey=$( echo "(${ymax} - ${ymin} + 0.5)/1+1" | bc )

header="##K=12;TOPK=3\n##BLOCK_SIZE=1000;BLOCK_AXIS=X;INDEX_AXIS=Y\n##OFFSET_X=${offsetx};OFFSET_Y=${offsety};SIZE_X=${rangex};SIZE_Y=${rangey};SCALE=100\n#BLOCK\tX\tY\tK1\tK2\tK3\tP1\tP2\tP3"
(echo -e "${header}" && zcat ${model_dir}/${decode_prefix}.pixel.tsv.gz | \
    tail -n +2 | \
    perl -slane '$F[0]=int(($F[1]-$offx)/$bsize) * $bsize; $F[1]=int(($F[1]-$offx)*$scale); $F[1]=($F[1]>=0)?$F[1]:0; $F[2]=int(($F[2]-$offy)*$scale); $F[2]=($F[2]>=0)?$F[2]:0; print join("\t", @F);' -- -bsize=1000 -scale=100 -offx=${offsetx} -offy=${offsety} | \
    sort -S 10G -k1,1g -k2,2g ) | \
    bgzip -c > ${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz

tabix -f -s1 -b2 -e2 ${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz

# decode DE
echo -e "\n#=== sub-step.2 DE analysis ===#"
command time -v ${py39} ${ficture}/script/de_bulk.py \
    --input ${model_dir}/${decode_prefix}.posterior.count.tsv.gz \
    --output ${model_dir}/${decode_prefix}.bulk_chisq.tsv \
    --min_ct_per_feature 50  \
    --max_pval_output 0.001 \
    --min_fold_output 1.5 \
    --thread $threads

# decode pixel figure
deactivate 

source ${py310_env}/bin/activate
py310=${py310_env}/bin/python

echo -e "\n#=== sub-step.3 Plot pixel figure ===#"
command time -v ${py310} ${ficture}/script/plot_pixel_full.py \
    --input ${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz \
    --output ${model_dir}/${decode_prefix}.pixel.png  \
    --color_table ${model_dir}/${tranform_prefix}.rgb.tsv \
    --plot_um_per_pixel 0.5 \
    --full

# decode report
echo -e "\n#=== sub-step.4 DE Report ===#"
command time -v ${py310} ${ficture}/script/factor_report.py \
    --path ${model_dir} \
    --pref ${decode_prefix} \
    --color_table ${model_dir}/${tranform_prefix}.rgb.tsv \
    --hc_tree