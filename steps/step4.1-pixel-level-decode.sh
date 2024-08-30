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
read_config_for_neda $1 $neda

# (Seurat-only) Sanity check - make sure nfactor is defined
if [[ -z $nfactor ]]; then
    echo -e "Error: number of factors (nfactor) is not defined. Please define nfactor in the input_data_and_params file."
    exit 1
fi

# ===== INPUT/OUTPUT =====
# * input
#    - input_xyrange: defined by the user; naming convention: "*.coordinate_minmax.tsv"  
minibatches="${output_dir}/${prefix}.batched.matrix.tsv.gz"         
transform_fit="${model_dir}/${tranform_prefix}.fit_result.tsv.gz"

# * output
decode_pixel="${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz"

# * output prefix:
decode_prefix_w_dir="${model_dir}/${decode_prefix}"

# * temporary
decode_pixel_unsorted="${model_dir}/${decode_prefix}.pixel.tsv.gz"

# ===== SANITY CHECK =====
required_files=(
    "${input_xyrange}"
    "${minibatches}"
    "${model_path}"
    "${transform_fit}"
)

check_files_exist "${required_files[@]}"

# ===== AUXILIARY PARAMS =====
ap_mu_scale=1000
ap_precision=0.25
ap_lite_topk_output_pixel=3
ap_lite_topk_output_anchor=3

# neighbor_radius (neighbor_radius):
# By default, neighbor_radius=anchor_dist+1.
if [[ -z $neighbor_radius ]]; then
    echo -e "Error: neighbor_radius (neighbor_radius) is missing. By default, neighbor_radius=anchor_dist+1. Please make sure anchor_dist is defined in the input_data_and_params file."
    exit 1
fi

# ===== ANALYSIS =====
# Pixel-level Decoding
echo -e "Decoding pixel-level data..."
command time -v python ${ficture}/ficture/scripts/slda_decode.py  \
    --input ${minibatches} \
    --model ${model_path}\
    --anchor ${transform_fit}\
    --output ${decode_prefix_w_dir} \
    --anchor_in_um \
    --neighbor_radius ${neighbor_radius} \
    --mu_scale ${ap_mu_scale} \
    --key ${solo_feature} \
    --precision ${ap_precision} \
    --lite_topk_output_pixel ${ap_lite_topk_output_pixel} \
    --lite_topk_output_anchor ${ap_lite_topk_output_anchor} \
    --thread ${threads}

# Sort and compress the decoded pixel-level data
echo -e "Sorting and compressing the decoded pixel-level data..."

# 1) read xy range
while IFS=$'\t' read -r r_key r_val; do
    export "${r_key}"="${r_val}"
done < "${input_xyrange}"

offsetx="${xmin}"
offsety="${ymin}"
rangex=$( echo "(${xmax} - ${xmin} + 0.5)/1+1" | bc )   
rangey=$( echo "(${ymax} - ${ymin} + 0.5)/1+1" | bc )   

# 2) define the block and sort axis
declare -A axis2col
axis2col["X"]=2
axis2col["Y"]=3

if [[ ${major_axis} == "Y" ]]; then
    block_axis="X"
    offblock="${offsetx}"
else
    block_axis="Y"
    offblock="${offsety}"
fi

blockidx0=$( echo "${axis2col[${block_axis}]} - 1" | bc )   # perl is 0-based
sortidx=${axis2col[${major_axis}]}

header="##K=${nfactor};TOPK=3\n##BLOCK_SIZE=1000;BLOCK_AXIS=${block_axis};INDEX_AXIS=${major_axis}\n##OFFSET_X=${offsetx};OFFSET_Y=${offsety};SIZE_X=${rangex};SIZE_Y=${rangey};SCALE=100\n#BLOCK\tX\tY\tK1\tK2\tK3\tP1\tP2\tP3"
(echo -e "${header}" && zcat "${decode_pixel_unsorted}" | \
    tail -n +2 | \
    perl -slane '$F[0]=int(($F[$bidx]-$offb)/$bsize) * $bsize; $F[1]=int(($F[1]-$offx)*$scale); $F[1]=($F[1]>=0)?$F[1]:0; $F[2]=int(($F[2]-$offy)*$scale); $F[2]=($F[2]>=0)?$F[2]:0; print join("\t", @F);' -- -bsize=1000 -scale=100 -offx="${offsetx}" -offy="${offsety}" -bidx="${blockidx0}" -offb="${offblock}" | \
    sort -S 10G -k1,1g -k"${sortidx},${sortidx}g") | \
    bgzip -c > "${decode_pixel}"

tabix -f -s1 -b"${sortidx}" -e"${sortidx}" ${decode_pixel}

