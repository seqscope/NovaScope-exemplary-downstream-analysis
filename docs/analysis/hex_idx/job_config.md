# Preparing the Input Configuration File

Given the amount of the paths and parameters, NEDA use an input configuration file, which is a **text** file, serves as the input for parameters and dataset paths. We provide an example configuration file for [LDA+FICTURE analysis](https://github.com/seqscope/NovaScope-exemplary-downstream-analysis/blob/main/input_data_and_params/input_data_and_params_lda.txt) and [Seurat+FICTURE analysis](https://github.com/seqscope/NovaScope-exemplary-downstream-analysis/blob/main/input_data_and_params/input_data_and_params_seurat.txt), separately. 

Below only include FICTURE's **essential parameters**, while certain steps might need **auxiliary parameters**. In such cases, NEDA employs FICTURE's recommended defaults for these extra settings, wherever applicable. Should you wish to customize these auxiliary parameters beyond the defaults, please proceed with caution as it involves risk. For detailed information on modifying auxiliary parameters, kindly refer to the `AUXILIARY PARAMS` section in the script for each respective step and the guidance of [FICTURE](https://github.com/seqscope/ficture/tree/protocol).

```
#=========================
# Mandatory Fields
#=========================
# input files
transcripts=/path/to/the/transcripts/file                           ## Path to the FICTURE-compatible SGE file, whose naming convention in NovaScope is *.transcripts.tsv.gz.
feature_clean=/path/to/the/clean/feature/file                       ## NovaScope name convention is *.feature.clean.tsv.gz
major_axis=<X_or_Y>                                                 ## Typically, we identify the major axis as the one with the greater length. The options are "X" and "Y". For instance, in the minimal test run dataset, the major axis is Y, whereas it is X in the shallow liver dataset.
hexagon_sge_dir=/path/to/the/hexagon/indexed/sge/directory          ## The SGE that segmented pixels into hexagonal units in the 10x genome format.

## Input/Output 
output_dir=/path/to/the/output/directory/                           ## Directory for output files: LDA results saved in ${output_dir}/LDA, and Seurat results in ${output_dir}/Seurat."
prefix=<prefix_of_output_files>                                     ## Prefix for output files. The output files will be named using both this prefix and the following analytical parameters.

## analysis model
train_model=<model_option>                                          ## Define the analytical strategy. Options: "LDA", "Seurat".

# analysis param
solo_feature=<solo_feature>                                         ## The soloFeatures selection. Options: "gn": Gene; "gt": GeneFull. See details at https://github.com/alexdobin/STAR/blob/master/docs/STARsolo.md.
train_width=<train_width>                                           ## The side length of the hexagon (in micrometers), e.g., 18.
nfactor=<number_of_factors>                                         ## (LDA-only) Number of factors, e.g., 12. For the 'Seurat + FICTURE' analysis, remove this line when preparing the configuration file; nf is defined after clustering.
train_n_epoch=<number_of_epoch>                                     ## (LDA-only) Epochs for LDA training, e.g., 3. For "Seurat+FICTURE" analysis, use "NA".
fit_width=<projection_width>                                        ## Projection width, suggest to use one the same as the train width, e.g., 18.
anchor_dist=<archor_distance>                                       ## Anchor point distance (in micrometers), e.g., 4.

#=========================
# Optional Fields
#=========================
threads=<number_of_cpus>                                            ## (Optional) A integer to indicate how many CPUs will be applied. If absent, 1 thread will be applied.
#seed=<an_integer>                                                   ## (Optional) A seed (integer, e.g., 2024030700) for reproducibility. This applies in the LDA factorization and choosing color maps. If omitted, a random seed will be utilized.

```


