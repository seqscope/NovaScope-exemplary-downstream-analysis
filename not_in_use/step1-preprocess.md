# Initialize Computing Environment and Data Preprocessing

## Set Up Computing Environment

Please make sure set up the computing environment before each step. 

```bash
## Load modules, if applicable.
## For non-HPC user, use `export` to set the paths for following softwares, e.g., `export samtools=<path_to_samtools>`.
module load Bioinformatics                          ## In this example, samtools is part of the Bioinformatics module system, requiring the Bioinformatics module to be loaded before accessing the specific program.
module load samtools

module load R/4.2.0e                                ## R is only required for Seurat+FICTURE analysis.

## If your Python environment was not set up using venv, replace the following lines with the appropriate commands to activate the environment.
py_env="<path_to_python_env>"                       ## replace <path_to_python_env> with the path to the python environment
source ${py_env}/bin/activate
export python=${py_env}/bin/python

neda_dir="<path_to_the_NEDA_repository>"            ## replace <path_to_the_NEDA_repository> with the path to the NovaScope-exemplary-downstream-analysis repository

input_configfile="<path_to_input_data_and_params>"  ## replace <path_to_input_data_and_params> with the path to the input_data_and_params file, e.g., ${neda_dir}/input_data_and_params/input_data_and_params_lda.txt
```

## Step 1. Preprocessing

### Step 1.1 Convert Spatial Digital Gene Expression (SGE) Matrix into a FICTURE-compatible Format

This step converts the spatial digital gene expression (SGE) matrix to FICTURE format, where each row contains, X/Y coordinates, gene name, identifier, and observed count.

Input & Output
```
# Input:
${input_dir}/features.tsv.gz
${input_dir}/barcodes.tsv.gz
${input_dir}/matrix.mtx.gz

#Output:
${output_dir}/${prefix}.transcripts.tsv.gz
```

Command:
```bash
$neda_dir/steps/step1.1-convert-SGE.sh $input_configfile
```

### Step 1.2 Filtering
Prepare a quality-controlled (QCed) feature file and SGE matrix into a FICTURE-compatible format, filtered by gene types and density. This also creates a strict boundary file based on the density of transcripts.

Input & Output
```
# Input: 
${input_dir}/features.tsv.gz
${input_dir}/barcodes.tsv.gz
${input_dir}/matrix.mtx.gz
${output_dir}/${prefix}.transcripts.tsv.gz

#Output: 
${output_dir}/${prefix}.feature.clean.tsv.gz
${output_dir}/${prefix}.transcripts_filtered.tsv.gz
${output_dir}/${prefix}.boundary.strict.geojson
${output_dir}/${prefix}.coordinate_minmax.tsv
```

Command:
```bash
$neda_dir/steps/step1.2-filter-feature-and-SGE.sh $input_configfile
```

### Step 1.3 Create Minimatch
Reformat the input file by assigning minibatch label, and by reordering the data based on the major axis so that they are locally contiguous.

Input & Output
```
#Input: 
${output_dir}/${prefix}.transcripts_filtered.tsv.gz

#Output: 
${output_dir}/${prefix}.batched.matrix.tsv.gz
```

Command:
```bash
$neda_dir/steps/step1.3-create-minibatch.sh $input_configfile
```

