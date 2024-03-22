# Preparing the Input Configuration File

The input configuration file, which is a **text** file, serves as the input for parameters and dataset paths. We provide an example configuration file for [LDA+FICTURE analysis](https://github.com/seqscope/NovaScope-exemplary-downstream-analysis/blob/main/input_data_and_params/input_data_and_params_lda.txt) and [Seurat+FICTURE analysis](https://github.com/seqscope/NovaScope-exemplary-downstream-analysis/blob/main/input_data_and_params/input_data_and_params_seurat.txt), separately. 

Below only include FICTURE's **essential parameters**, while certain steps might need **auxiliary parameters**. In such cases, NEDA employs FICTURE's recommended defaults for these extra settings, wherever applicable. Should you wish to customize these auxiliary parameters beyond the defaults, please proceed with caution as it involves risk. For detailed information on modifying auxiliary parameters, kindly refer to the `AUXILIARY PARAMS` section in the script for each respective step and original publication of [FICTURE](https://github.com/seqscope/ficture/tree/protocol).

```
## Environment Paths
py_env=<path_to_the_python_environment>                             ## path to Python environment 
ficture=<path_to_the_ficture_repository>        				    ## path to FICTURE repository
ref_geneinfo=<path_to_the_reference_dataset>                        ## path to the reference file, please make sure

## Input/Output 
input_dir=<path_to_the_input_directory>                             ## Directory for input files
output_dir=<path_to_the_output_directory>                           ## Directory for output files: LDA results saved in ${output_dir}/LDA, and Seurat results in ${output_dir}/Seurat."
prefix=<prefix_of_output_files>                                     ## Prefix for output files. The output files will be named using both this prefix and the following analytical parameters.

## Analytical Parameters
train_model=<model_option>                                          ## Define the analytical strategy. Options: "LDA", "Seurat".

sf=<solo_feature>                                                   ## Feature selection, e.g., "gn", which is short for "gene".
tw=<train_width>                                                    ## The side length of the hexagon (in micrometers), e.g., 18.
nf=<number_of_factors>                                              ## (LDA-only) Number of factors, e.g., 12. For the 'Seurat + FICTURE' analysis, remove this line when preparing the configuration file; nf is defined after clustering.
ep=<number_of_epoch>                                                ## (LDA-only) Epochs for LDA training, e.g., 3. For "Seurat+FICTURE" analysis, use "NA".
pw=<projection_width>                                               ## Projection width, suggest to use one the same as the train width, e.g., 18.
ar=<archor_distance>                                                ## Anchor point distance (in micrometers), e.g., 4.

seed=<an_integer>                                                   ## (Optional) A seed (integer, e.g., 2024030700) for reproducibility. This applies in the LDA factorization and choosing color maps. If omitted, a random seed will be utilized.

major_axis=<X_or_Y>                                                 ## Generally, we defined the one with greater length as the major axis. Options: "X", "Y".
```


