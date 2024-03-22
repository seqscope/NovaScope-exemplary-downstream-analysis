# Preparing the input Configuration File

The input configuration file serves as the input for parameters and dataset paths. It should include: environment paths, input and output directory paths, output prefix, and analytical parameters.

We provided an example configuration file for [LDA+FICTURE analysis](https://github.com/seqscope/NovaScope-exemplary-downstream-analysis/blob/main/input_data_and_params/input_data_and_params_lda.txt) and [Seurat+FICTURE analysis](https://github.com/seqscope/NovaScope-exemplary-downstream-analysis/blob/main/input_data_and_params/input_data_and_params_seurat.txt), separately. 

Below only include FICTURE's essential parameters, while certain steps might need **auxiliary parameters**. In such cases, NEDA employs FICTURE's recommended defaults for these extra settings, wherever applicable. Should you wish to customize these auxiliary parameters beyond the defaults, please proceed with caution as it involves risk. For detailed information on modifying auxiliary parameters, kindly refer to the `AUXILIARY PARAMS` section found in the script for each respective step. For each auxiliary parameter, please consult the original publication of [FICTURE](https://www.biorxiv.org/content/10.1101/2023.11.04.565621v2).

```
## Environment Paths
py_env=<path_to_the_python_environment>                             ## Python environment path
ficture=<path_to_the_ficture_repository>        				    ## Path to FICTURE repository
ref_geneinfo=<path_to_the_reference_dataset>                        ## Path to the reference gene info dataset

## Input/Output 
input_dir=<path_to_the_input_directory>                             ## Directory for input files
output_dir=<path_to_the_output_directory>                           ## Directory for output files. The LDA-based results will be saved in "${output_dir}/LDA" while the Seurat-based results will be stored at "${output_dir}/Seurat"
prefix=<prefix_of_output_files>                                     ## Prefix for output files. The output files will be named using both this prefix and the following analytical parameters.

## analytical parameters
train_model=<model_option>                                          ## Define the analytical strategy. Options: "LDA", "Seurat".

sf=<solo_feature>                                                   ## Feature selection, e.g., "gn", which is short for "gene".
tw=<train_width>                                                    ## The side length of the hexagon (in micrometers), e.g., 18.
nf=<number_of_factors>                                              ## (LDA-only) Number of factors, e.g., 12. For "Seurat + FICTURE" analysis, eliminate this line at the preparation stage, as the nf will later be defined by the outcomes of the clustering process.
ep=<number_of_epoch>                                                ## (LDA-only) Epochs for LDA training, e.g., 3. For "Seurat+FICTURE" analysis, use "NA".
pw=<projection_width>                                               ## Projection width, suggest to use one the same as the train width, e.g., 18.
ar=<archor_distance>                                                ## Anchor point distance (in micrometers), e.g., 4.

seed=<an_integer>                                                   ## A seed for reproducibility, e.g., 2024030700. This will be used in the LDA training and choosing colors for factors/cluster.

major_axis=<X_or_Y>                                                 ## Generally, we defined the one with greater length as the major axis. Options: "X", "Y".
```


