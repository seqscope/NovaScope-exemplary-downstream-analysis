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
process_input_data_and_params $1

# (Seurat-only) Sanity check - make sure nf is defined
if [[ -z $nf ]]; then
    echo -e "Error: number of factors (nf) is not defined. Please define nf in the input_data_and_params file."
    exit 1
fi

# Examine the required input files
required_files=(
    "${output_dir}/${prefix}.coordinate_minmax.tsv"
    "${output_dir}/${prefix}.batched.matrix.tsv.gz "
    "${model_path}"
    "${model_dir}/${tranform_prefix}.fit_result.tsv.gz"
)

check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_mu_scale=1000
ap_precision=0.25
ap_lite_topk_output_pixel=3
ap_lite_topk_output_anchor=3

# neighbor_radius (nr):
# By default, nr=ar+1.
if [[ -z $nr ]]; then
    echo -e "Error: neighbor_radius (nr) is missing. By default, nr=ar+1. Please make sure ar is defined in the input_data_and_params file."
    exit 1
fi

# ===== ANALYSIS =====

# Pixel-level Decoding
command time -v python ${ficture}/script/slda_decode.py  \
    --input ${output_dir}/${prefix}.batched.matrix.tsv.gz \
    --model ${model_path}\
    --anchor ${model_dir}/${tranform_prefix}.fit_result.tsv.gz\
    --output ${model_dir}/${decode_prefix} \
    --anchor_in_um \
    --neighbor_radius ${nr} \
    --mu_scale ${ap_mu_scale} \
    --key ${sf} \
    --precision $ap_precision \
    --lite_topk_output_pixel $ap_lite_topk_output_pixel \
    --lite_topk_output_anchor $ap_lite_topk_output_anchor \
    --thread $threads

# Determine the sort/tabix column based on the major_axis value
if[ ${major_axis} == "Y" ]; then
    sort_column="-k3,3g"
    tabix_column="-b3 -e3"
else
    sort_column="-k2,2g"
    tabix_column="-b2 -e2"
fi

# Sort based on major axis
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
    sort -S 10G -k1,1g $sort_column ) | \
    bgzip -c > ${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz

tabix -f -s1 $tabix_column ${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz

