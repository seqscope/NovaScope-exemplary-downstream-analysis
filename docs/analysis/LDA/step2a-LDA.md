# Latent Dirichlet Allocation (LDA) + FICTURE analytical strategy

## Step 2a. Infer Cell Type Factors using Latent Dirichlet Allocation (LDA).
This example illustrates infering cell type factors using Latent Dirichlet Allocation (LDA). 

**Prefix**:

To clarify the input and output filenames, we utilize prefixes in this documentation. Below, we illustrate how these prefixes are defined. Those prefixes are automatically defined by the script; users do **NOT** need to manually define them. 

```
hexagon_prefix="${prefix}.hexagon.${sf}.d_${tw}"
train_prefix="${prefix}.${sf}.nF${nf}.d_${tw}.s_${ep}"
```

* Details on variables used in above prefixes are in the [Job Configuration](../../prep_input/job_config.md).

### Step 2a.1 Create Hexagonal Spatial Gene Expression (SGE) matrix
Given a specified size of hexagons, segment the raw spatial gene expression (SGE) matrix into hexagonal SGE.

Input & Output
```
# Input:
${output_dir}/${prefix}.QCed.matrix.tsv.gz
${output_dir}/${prefix}.boundary.strict.geojson

# Output: 
${output_dir}/${train_model}/${hexagon_prefix}.tsv.gz
```

Command:
```bash
$neda_dir/steps/step2a.1-create-hexagons.sh $input_configfile
```

### Step 2a.2 LDA Factorization
An unsupervised learning of cell type factors using LDA.

Input & Output:
```
# Input:
${output_dir}/${prefix}.feature.clean.tsv.gz
${output_dir}/${train_model}/${hexagon_prefix}.tsv.gz

# Output: 
${output_dir}/${train_model}/${train_prefix}.model.p
${output_dir}/${train_model}/${train_prefix}.fit_result.tsv.gz
${output_dir}/${train_model}/${train_prefix}.posterior.count.tsv.gz
```

Command:
```bash
$neda_dir/steps/step2a.2-LDA-factorization.sh $input_configfile
```

### Step 2a.3 Creating Marker Gene Reports
This step includes: generating a color table, identifying marker genes for each factor, and creating a report html file, which summarizes individual factors and marker genes.

Input & Output:
```
# Input:
${output_dir}/${train_model}/${train_prefix}.fit_result.tsv.gz
${output_dir}/${train_model}/${train_prefix}.posterior.count.tsv.gz

# Output: 
${output_dir}/${train_model}/${train_prefix}.color.tsv
${output_dir}/${train_model}/${train_prefix}.bulk_chisq.tsv
${output_dir}/${train_model}/${train_prefix}.factor.info.html
```

Command:
```bash
$neda_dir/steps/step2a.3-LDA-factorization-report.sh $input_configfile
```