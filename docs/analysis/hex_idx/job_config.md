# Preparing the Input Configuration File

NEDA employs an input configuration file in **text** format to provide input/output paths and parameters.

For this input configuration file, we provide:

 - an [input configuration template](#input-configuration-template) below,
 - an example configuration files for LDA+FICTURE analysis: [input_config_lda.txt](https://github.com/seqscope/NovaScope-exemplary-downstream-analysis/blob/main/config_job/input_config_lda.txt),
 - an example configuration files for Seurat+FICTURE analysis: [input_config_seurat.txt](https://github.com/seqscope/NovaScope-exemplary-downstream-analysis/blob/main/config_job/input_config_seurat.txt).

## Essential and Auxiliary Parameters
[FICTURE](https://github.com/seqscope/ficture/) uses numerous parameters at each step to ensure flexibility. NEDA simplifies data analysis by only requiring **essential parameters** in the input configuration file. Although some steps may require **auxiliary parameters**, NEDA adopts FICTURE's recommended defaults.

If you wish to customize these defaults, refer to the `AUXILIARY PARAMS` section in the step scripts and the [FICTURE documentation](https://github.com/seqscope/ficture), but proceed with caution due to potential risks.

## An Input Configuration Template

```
#=========================
# Mandatory Fields
#=========================
## Input files
input_transcripts=/path/to/the/transcripts/file                     ## Path to the input spatial digital gene expression (SGE) matrix in FICTURE-compatible TSV format.
input_features=/path/to/the/feature/file                            ## Path to the input feature file.
input_xyrange=/path/to/the/xyrange                                  ## Path to the input meta file with minimum and maximum X Y coordinates.

## (Model-Specific) Input Hexagon-Indexed SGE matrix 
# Those two analytical strategies in NEDA require input hexagon-indexed SGE matrix in different formats.
# Choose your analytical strategy first, then define its required hexagon-indexed SGE matrix.
input_hexagon_sge_ficture=/path/to/the/hexagon/indexed/sge/ficture  ## (LDA-only) Path of hexagon-indexed SGE in the FICTURE-compatible TSV format.
input_hexagon_sge_10x_dir=/path/to/the/hexagon/indexed/sge/10x/dir  ## (Seurat-only) Directory of hexagon-indexed SGE in the 10x genomics format, which should have features.tsv.gz, barcodes.tsv.gz, and matrix.mtx.gz.

## Output 
output_dir=/path/to/the/output/directory/                           ## Directory for output files: LDA results will be saved in ${output_dir}/LDA, and Seurat results wil be in ${output_dir}/Seurat."
prefix=<prefix_of_output_files>                                     ## Prefix for output files. The output files will be named using both this prefix and the following parameters.

## Train model
train_model=<model_option>                                          ## Define the analytical strategy. Options: "LDA", "Seurat".

## Params
major_axis=<X_or_Y>                                                 ## Typically, the major axis is the axis with a greater length. Options: "X", "Y". For instance, it is Y in the minimal testrun dataset whereas X in the shallow and deep liver datasets.

solo_feature=<solo_feature>                                         ## Select the genome feature. Options: "gn": Gene; "gt": GeneFull. See details at https://github.com/alexdobin/STAR/blob/master/docs/STARsolo.md.
train_width=<train_width>                                           ## The side length of the hexagon (in micrometers), e.g., 18.
fit_width=<projection_width>                                        ## Projection width, suggest to use one the same as the train width, e.g., 18.
anchor_dist=<archor_distance>                                       ## Anchor point distance (in micrometers), e.g., 4.

## (Model-Specific) params
## - LDA
nfactor=<number_of_factors>                                         ## (LDA-only) Number of factors, e.g., 12. For 'Seurat+FICTURE' analysis, remove it when preparing the configuration file; nf will be defined after clustering.
train_n_epoch=<number_of_epoch>                                     ## (LDA-only) Epochs for LDA training, e.g., 3. For "Seurat+FICTURE" analysis, use "NA" or remove it.
## - Seurat
#nFeature_RNA_cutoff=<the_optimal_cutoff>                           ## (Seurat-only) After evaluating the performance of different cutoffs, define the optimal cutoff aiming at removing noises.
res_of_interest=<the_optimal_resolution>                            ## (Seurat-only) After examining clustering results across all resolution settings, identify the optimal resolution.

#=========================
# Optional Fields
#=========================
#threads=<number_of_cpus>                                           ## (Optional) A integer to indicate how many CPUs will be applied. If absent, 1 thread will be applied.
#seed=<an_integer>                                                  ## (Optional) A seed (integer, e.g., 2024030700) for reproducibility. This applies in the LDA factorization and choosing color maps. If omitted, a random seed will be utilized.
```