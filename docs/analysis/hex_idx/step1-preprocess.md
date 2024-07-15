# Step 1. Preprocessing

## Set Up Computing Environment

Please make sure set up the computing environment before **each** step. 

```bash
## Load modules, if applicable.
## For non-HPC user, use `export` to set the paths for following softwares, e.g., `export samtools=<path_to_samtools>`.
module load Bioinformatics                          ## In this example, samtools is part of the Bioinformatics module system, requiring the Bioinformatics module to be loaded before accessing the specific program.
module load samtools
module load R/4.2.0                                 ## only required for Seurat+FICTURE analysis

## Activate Python environment
## If your Python environment was not set up using venv, replace the following lines with the appropriate commands to activate the environment.
py_env="<path_to_python_env>"                       ## replace <path_to_python_env> with the path to the python environment
source ${py_env}/bin/activate
export python=${py_env}/bin/python

## Define NEDA
neda_dir="<path_to_the_NEDA_repository>"            ## replace <path_to_the_NEDA_repository> with the path to the NovaScope-exemplary-downstream-analysis repository

## Specify the input configure file
input_configfile="<path_to_input_data_and_params>"  ## replace <path_to_input_data_and_params> with the path to the config_job file, e.g., ${neda_dir}/config_job/input_config_lda.txt
```

## Step 1 Creating Minimatch
Assigning minibatch label, and reordering the data based on the major axis so that they are locally contiguous. This output file will be applied in the step of projecting the factors into the pixel-level dataset using FICTURE.

Input & Output
```bash
#Input: 
$input_transcripts                                   ## user-defined input SGE in FICTURE-compatible format

#Output: 
${output_dir}/${prefix}.batched.matrix.tsv.gz
```

Commands:
```bash
$neda_dir/steps/step1-create-minibatch.sh $input_configfile
```