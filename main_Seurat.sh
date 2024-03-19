#================================================================================================
#
#  PURPOSE: This script demonstrates an example of using Seurat and FICTURE for analyzing spatial transcriptomics data from NovaScope.
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

input_configfile="<path_to_input_data_and_params>"  ## Replace <path_to_input_data_and_params> with the path to the input_data_and_params file, e.g., ${neda_dir}/input_data_and_params/input_data_and_params_seurat.txt

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

# Step 2b. Infer cell type factors using Seurat
# This example illustrates infering cell type factors using Seurat. If you prefer to use LDA, please refer to main_LDA.sh.
# This process contains two stops, which require manual evaluation. One stop is at step 2b.2 and the other at step 2b.4.

# Prefix:
# hexagon_prefix="${prefix}.hexagon.${sf}.d_${tw}"
# train_prefix="${prefix}.${sf}.nF${nf}.d_${tw}.s_${ep}"    ## the nf will be determined in step2b.5

# step 2b.1 Create hexagonal SGE and test different cutoffs for nFeature_RNA
# This step will creates hexagonal SGE that is compatible with Seurat. It also examine the distribution of Ncount and Nfeature and tests filtering the SGE using different nFeature_RNA cutoffs, including 50,100,200,300,400,500,750,1000.
# input: ${output_dir}/${prefix}.merged.matrix.tsv.gz, ${output_dir}/${prefix}.feature.tsv.gz
# output: ${model_dir}/features.tsv.gz, ${model_dir}/barcodes.tsv.gz, ${model_dir}/matrix.mtx.gz, 
#         ${model_dir}/Ncount_Nfeature_vln.png, ${model_dir}/nFeature_RNA_dist.png,
#         ${model_dir}/nFeature_RNA_cutoff100.png, ${model_dir}/nFeature_RNA_cutoff200.png, ${model_dir}/nFeature_RNA_cutoff300.png, ${model_dir}/nFeature_RNA_cutoff400.png, ${model_dir}/nFeature_RNA_cutoff500.png, ${model_dir}/nFeature_RNA_cutoff50.png, ${model_dir}/nFeature_RNA_cutoff750.png,
$neda_dir/steps/step2b.1-creat-hexagons-for-Seurat.sh $input_configfile

# step 2b.2 Manually select the cutoff for nFeature_RNA and the ranges for X and Y.
# Review the density plots from the `step2b-Seurat-01-hexagon.sh` and select a threshold for nFeature_RNA while specifying the ranges for x and y. 
# Add those variables to the input_data_and_params file.
# Regarding to the thresholds for nFeature_RNA, we applied a cutoff of nFeature_RNA_cutoff=500 for deep sequencing data, and nFeature_RNA_cutoff=100 for shallow sequencing data.
# Example:
# In this case, the Y_max is not applied. 
# nFeature_RNA_cutoff=100
# X_min=2.5e+06
# X_max=1e+07
# Y_min=1e+06

# step 2b.3 Seurat clustering analysis
# The Seurat_analysis.R script, by default, evaluates clustering at various resolutions, specifically 0.25, 0.5, 0.75, 1, 1.25, 1.5, and 1.75. 
# For each resolution level, it creates both a Dimensionality Reduction and Spatial plot to illustrate the clusters using a UMAP manifold and their spatial positioning, as well as a Differential Expression (DE) file listing the marker genes for every cluster. 
# Additionally, the script generates a metadata file containing information on the cluster assignment for each cell, and an RDS file that stores the complete Seurat object with all the compiled data.# input: ${model_dir}/features.tsv.gz, ${model_dir}/barcodes.tsv.gz, ${model_dir}/matrix.mtx.gz
# Input: ${model_dir}/features.tsv.gz, ${model_dir}/barcodes.tsv.gz, ${model_dir}/matrix.mtx.gz
# output: ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv,  ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_SCT.RDS
#         ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res0.25_DE.csv, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res0.25_DimSpatial.png, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res0.5_DE.csv, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res0.5_DimSpatial.png, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res0.75_DE.csv, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res0.75_DimSpatial.png, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res1.25_DE.csv, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res1.25_DimSpatial.png, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res1.5_DE.csv, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res1.5_DimSpatial.png, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res1.75_DE.csv, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res1.75_DimSpatial.png, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res1_DE.csv, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_res1_DimSpatial.png
$neda_dir/steps/step2b.3-Seurat-clustering.sh $input_configfile

# step 2b.4 Manually select the resolution for clustering
# Examine the Dimensionality Reduction and Spatial plots from the previous step and choose a resolution to continue with. Then, save this chosen resolution into the input_data_and_params file as the res_of_interest variable.
# Example:
# res_of_interest=1

# step 2b.5 Prepare a count matrix with the selected resolution.
# Transform the metadata into a count matrix to serve as the model matrix for the subsequent step. 
# Additionally, this process determines the number of clusters present at the chosen resolution and assigns this count to the nf variable in the input_data_and_params file.
# input: ${model_dir}/features.tsv.gz, ${model_dir}/barcodes.tsv.gz, ${model_dir}/matrix.mtx.gz, ${model_dir}/${prefix}_cutoff${nFeature_RNA_cutoff}_metadata.csv
# output: ${model_dir}/${train_prefix}.model.tsv.gz
$neda_dir/steps/step2b.5-Seurat-count-matrix.sh $input_configfile

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

# Prefix:
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