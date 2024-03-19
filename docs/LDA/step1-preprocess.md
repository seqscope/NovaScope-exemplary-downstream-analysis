# Latent Dirichlet Allocation (LDA) + FICTURE analytical strategy

Please make sure set up the working environment before each Step (see below).
```
## Load modules if applicable.
module load Bioinformatics
module load samtools

## If you are using a conda environment, replace the following lines with the appropriate commands to activate the environment.
py_env="<path_to_python_env>"                       ## Replace <path_to_python_env> with the path to the python environment
source ${py_env}/bin/activate
python=${py_env}/bin/python

neda_dir="<path_to_the_NEDA_repository>"            ## Replace <path_to_the_NEDA_repository> with the path to the NovaScope-exemplary-downstream-analysis repository

input_configfile="<path_to_input_data_and_params>"  ## Replace <path_to_input_data_and_params> with the path to the input_data_and_params file, e.g., ${neda_dir}/input_data_and_params/input_data_and_params_lda.txt
```

## Step 1. Preprocessing

### Step 1.1 convert the SGE matrix to a merged format

input:  `${input_dir}/features.tsv.gz`, `${input_dir}/barcodes.tsv.gz`, `${input_dir}/matrix.mtx.gz`

output: `${output_dir}/${prefix}.merged.matrix.tsv.gz`

```
$neda_dir/steps/step1.1-convert-SGE.sh $input_configfile
```

### Step 1.2 QC
Prepare a QCed feature and SGE matrix in a merged format, filtered by gene types and density.

input: `${input_dir}/features.tsv.gz`, `${input_dir}/barcodes.tsv.gz`, `${input_dir}/matrix.mtx.gz`, `${output_dir}/${prefix}.merged.matrix.tsv.gz`

output: `${output_dir}/${prefix}.feature.clean.tsv.gz`, `${output_dir}/${prefix}.QCed.matrix.tsv.gz,` `${output_dir}/${prefix}.boundary.strict.geojson`, `${output_dir}/${prefix}.coordinate_minmax.tsv`

```
$neda_dir/steps/step1.2-filter-feature-and-SGE.sh $input_configfile
```

### Step 1.3 Create minimatch
Reformat the input file by assigning minibatch label, and by reordering the data based on the major axis so that they are locally contiguous.

input: `${output_dir}/${prefix}.QCed.matrix.tsv.gz`

output: `${output_dir}/${prefix}.batched.matrix.tsv.gz`

```
$neda_dir/steps/step1.3-create-minibatch.sh $input_configfile
```

