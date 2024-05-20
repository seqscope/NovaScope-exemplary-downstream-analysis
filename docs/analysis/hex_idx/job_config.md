# Preparing the Input Configuration File

Given the amount of the paths and parameters, NEDA employs a **text** file as an input configuration file, which contains parameters and dataset paths. We offer separate example configuration files for [LDA+FICTURE analysis](https://github.com/seqscope/NovaScope-exemplary-downstream-analysis/blob/main/config_job/input_config_lda.txt) and [Seurat+FICTURE analysis](https://github.com/seqscope/NovaScope-exemplary-downstream-analysis/blob/main/config_job/input_config_seurat.txt). 

Below only include [FICTURE](https://github.com/seqscope/ficture/tree/protocol)'s **essential parameters**, while certain steps might need **auxiliary parameters**. In such cases, NEDA employs FICTURE's recommended defaults for these extra settings, wherever applicable. Should you wish to customize these auxiliary parameters beyond the defaults, please proceed with caution as it involves risk. For detailed information on modifying auxiliary parameters, kindly refer to the `AUXILIARY PARAMS` section in the script for each respective step and the guidance of [FICTURE](https://github.com/seqscope/ficture/tree/protocol).

```
#=========================
# Mandatory Fields
#=========================
## Input files
transcripts=/path/to/the/transcripts/file                           ## Path to the FICTURE-compatible spatial digital gene expression matrix (SGE), whose naming convention in NovaScope is *.transcripts.tsv.gz.
feature_clean=/path/to/the/clean/feature/file                       ## NovaScope name convention is *.feature.clean.tsv.gz
major_axis=<X_or_Y>                                                 ## Typically, the major axis is the axis with a greater length. Options: "X", "Y". For instance, in the minimal test run dataset, the major axis is Y, whereas it is X in the shallow and deep liver datasets.

## Input file Only required for Seurat+FICTURE analysis
hexagon_sge_dir=/path/to/the/hexagon/indexed/sge/directory          ## (Seurat-only) Specify the directory with hexagon-indexed SGE, i.e., SGE with pixels segmented into hexagonal units, in the 10x genome format. This directory should have the following three files: features.tsv.gz, barcodes.tsv.gz, and matrix.mtx.gz.

## Output 
output_dir=/path/to/the/output/directory/                           ## Directory for output files: LDA results will be saved in ${output_dir}/LDA, and Seurat results wil be in ${output_dir}/Seurat."
prefix=<prefix_of_output_files>                                     ## Prefix for output files. The output files will be named using both this prefix and the following analytical parameters.

## Analysis model
train_model=<model_option>                                          ## Define the analytical strategy. Options: "LDA", "Seurat".

## Analysis param
solo_feature=<solo_feature>                                         ## The soloFeatures selection. Options: "gn": Gene; "gt": GeneFull. See details at https://github.com/alexdobin/STAR/blob/master/docs/STARsolo.md.
train_width=<train_width>                                           ## The side length of the hexagon (in micrometers), e.g., 18.
fit_width=<projection_width>                                        ## Projection width, suggest to use one the same as the train width, e.g., 18.
anchor_dist=<archor_distance>                                       ## Anchor point distance (in micrometers), e.g., 4.

## Analysis strategy-specific params
nfactor=<number_of_factors>                                         ## (LDA-only) Number of factors, e.g., 12. For the 'Seurat + FICTURE' analysis, remove it when preparing the configuration file; nf will be defined after clustering.
train_n_epoch=<number_of_epoch>                                     ## (LDA-only) Epochs for LDA training, e.g., 3. For "Seurat+FICTURE" analysis, use "NA" or remove it.
res_of_interest=1                                                   ## (Seurat-only) After examining the clustering results across all resolution settings, identify the optimal results for FICTURE projection by specifying the resolution for these results here.

#=========================
# Optional Fields
#=========================
#threads=<number_of_cpus>                                           ## (Optional) A integer to indicate how many CPUs will be applied. If absent, 1 thread will be applied.
#seed=<an_integer>                                                  ## (Optional) A seed (integer, e.g., 2024030700) for reproducibility. This applies in the LDA factorization and choosing color maps. If omitted, a random seed will be utilized.

```


