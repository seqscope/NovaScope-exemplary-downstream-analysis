#================================================================================================
#
#  PURPOSE: This script demonstrates an example of using LDA and FICTURE for analyzing spatial transcriptomics data from NovaScope.
#
##================================================================================================

# step0. Load the required modules and activate the python environment.
module load Bioinformatics
module load samtools
module load R/4.2.0

# If you are using a conda environment, replace the following lines with the appropriate commands to activate the environment.
py_env="<path_to_python_env>"                       ## Replace <path_to_python_env> with the path to the python environment
source ${py_env}/bin/activate
python=${py_env}/bin/python

neda_dir="<path_to_the_NEDA_repository>"            ## Replace <path_to_the_NEDA_repository> with the path to the NovaScope-exemplary-downstream-analysis repository

input_configfile="<path_to_input_data_and_params>"  ## Replace <path_to_input_data_and_params> with the path to the input_data_and_params file, e.g., ${neda_dir}/input_data_and_params/input_data_and_params_lda.txt

#================================================================================================

# Step 1. Preprocessing

# step 1.1 convert the SGE matrix to a merged format
# input:  ${input_dir}/features.tsv.gz, ${input_dir}/barcodes.tsv.gz, ${input_dir}/matrix.mtx.gz
# output: ${output_dir}/${prefix}.merged.matrix.tsv.gz
$neda_dir/steps/step1.1-convert-SGE.sh $input_configfile

# step 1.2 Prepare a QCed feature and SGE matrix in a merged format, filtered by gene types and density.
# input: ${input_dir}/features.tsv.gz, ${input_dir}/barcodes.tsv.gz, ${input_dir}/matrix.mtx.gz, ${output_dir}/${prefix}.merged.matrix.tsv.gz
# output: ${output_dir}/${prefix}.feature.clean.tsv.gz, ${output_dir}/${prefix}.QCed.matrix.tsv.gz, ${output_dir}/${prefix}.boundary.strict.geojson, ${output_dir}/${prefix}.coordinate_minmax.tsv
$neda_dir/steps/step1.2-filter-feature-and-SGE.sh $input_configfile

# step 1.3 Reformat the input file by assigning minibatch label, and by reordering the data based on the major axis so that they are locally contiguous.
# input: ${output_dir}/${prefix}.QCed.matrix.tsv.gz
# output: ${output_dir}/${prefix}.batched.matrix.tsv.gz
$neda_dir/steps/step1.3-create-minibatch.sh $input_configfile

#================================================================================================

# Step 2a. Unsupervised Inference of Cell Type Factors using LDA.
# This example illustrates the LDA method. If you prefer to use Seurat, please refer to main_Seurat.sh.

# Prefix:
# hexagon_prefix="${prefix}.hexagon.${sf}.d_${tw}"
# train_prefix="${prefix}.${sf}.nF${nf}.d_${tw}.s_${ep}"

# step 2a.1 Create hexagonal SGE
# Given a specified size of hexagons, segment the raw SGE matrix into hexagons and store them into a spatial gene expression (SGE) matrix in the format compatible with FICTURE.
# input: ${output_dir}/${prefix}.QCed.matrix.tsv.gz, ${output_dir}/${prefix}.boundary.strict.geojson
# output: ${model_dir}/${hexagon_prefix}.tsv.gz
$neda_dir/steps/step2a.1-create-hexagons.sh $input_configfile

# step2a.2 LDA Factorization
# An unsupervised learning of cell type factors using LDA.
# input: ${output_dir}/${prefix}.feature.clean.tsv.gz, ${model_dir}/${hexagon_prefix}.tsv.gz
# output: ${model_dir}/${train_prefix}.model.p, ${model_dir}/${train_prefix}.fit_result.tsv.gz, ${model_dir}/${train_prefix}.posterior.count.tsv.gz
$neda_dir/steps/step2a.2-LDA-Factorization.sh $input_configfile

# step2a.3 LDA train report
# This includes: generating a color table, identifying marker genes for each factor, and creating a report html file, which summarizes individual factors and marker genes.
# input: ${model_dir}/${train_prefix}.fit_result.tsv.gz, ${model_dir}/${train_prefix}.posterior.count.tsv.gz
# output: ${model_dir}/${train_prefix}.color.tsv, ${model_dir}/${train_prefix}.bulk_chisq.tsv, ${model_dir}/${train_prefix}.factor.info.html
$neda_dir/steps/step2a.3-LDA-train-report.sh $input_configfile
#================================================================================================

# step 3 Transform 
# Prefix:
# tranform_prefix="${train_prefix}.prj_${pw}.r_${ar}"

# step 3.1 Transform
# Convert to a factor space using the provided model, which includes gene names and potentially Dirichlet parameters. The pixel-level data will be organized into (potentially overlapping) hexagonal groups.
# input: ${output_dir}/${prefix}.QCed.matrix.tsv.gz, ${model_dir}/${train_prefix}.model.p
# output: ${model_dir}/${tranform_prefix}.fit_result.tsv.gz, ${model_dir}/${tranform_prefix}.posterior.count.tsv.gz
$neda_dir/steps/step3.1-transform.sh $input_configfile

# step 3.2 transform visualization
# For LDA, use the color table from the training model. This color table will also be used in step4.
# input: ${model_dir}/${tranform_prefix}.fit_result.tsv.gz, ${model_dir}/${tranform_prefix}.posterior.count.tsv.gz, ${output_dir}/${prefix}.coordinate_minmax.tsv
# output: ${model_dir}/${tranform_prefix}.rgb.tsv, ${model_dir}/${tranform_prefix}.top.png
$neda_dir/steps/step3.2-transform-visualization.sh $input_configfile
#================================================================================================

# Step 4 Pixel-level Decoding
# decode_prefix="${train_prefix}.decode.prj_${pw}.r_${ar}_${nr}"

# step 4.1 pixel-level decoding. Decoding the model matrix on individual pixels, which returns a tab-delimited file of the posterior count of factors on individual pixels.
# input: ${output_dir}/${prefix}.coordinate_minmax.tsv, ${output_dir}/${prefix}.batched.matrix.tsv.gz, ${output_dir}/${prefix}.QCed.matrix.tsv.gz, ${model_dir}/${tranform_prefix}.model.p, ${model_dir}/${tranform_prefix}.fit_result.tsv.gz
# output: ${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz
$neda_dir/steps/step4.1-pixel-level-decode.sh $input_configfile

# step 4.2 Pixel-level decoding visualization and report. 
# This includes: identifying marker genes that are associated with each factor/cluster, generating a report html file that summarizes individual factors and marker genes, and creating a high-resolution image of cell type factors for individual pixels.
# input: ${model_dir}/${decode_prefix}.posterior.count.tsv.gz, ${model_dir}/${tranform_prefix}.rgb.tsv, 
# output: ${model_dir}/${decode_prefix}.bulk_chisq.tsv, ${model_dir}/${decode_prefix}.factor.info.html, ${model_dir}/${decode_prefix}.pixel.png 
$neda_dir/steps/step4.2-pixel-level-visualization-and-report.sh $input_configfile