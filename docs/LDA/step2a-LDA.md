# Latent Dirichlet Allocation (LDA) + FICTURE analytical strategy

## Step 2a. Infer Cell Type Factors using Latent Dirichlet Allocation (LDA).
This example illustrates infering cell type factors using Latent Dirichlet Allocation (LDA). 

Since this step, the output files will be stored at `${model_dir}`, which is defined as `${output_dir}/${train_model}`.

**Prefix**:

To clarify the input and output filenames, we utilize prefixes in this documentation. Below, we illustrate how these prefixes are defined. Users do **NOT** need to manually define these prefixes; they are automatically defined by the script.

```
hexagon_prefix="${prefix}.hexagon.${sf}.d_${tw}"
train_prefix="${prefix}.${sf}.nF${nf}.d_${tw}.s_${ep}"
```

### step 2a.1 Create hexagonal spatial gene expression (SGE) matrix
Given a specified size of hexagons, segment the raw spatial gene expression (SGE) matrix into hexagonal SGE.

Input & Output
```
# Input:
${output_dir}/${prefix}.QCed.matrix.tsv.gz
${output_dir}/${prefix}.boundary.strict.geojson

# Output: 
${model_dir}/${hexagon_prefix}.tsv.gz
```

Command:
```
$neda_dir/steps/step2a.1-create-hexagons.sh $input_configfile
```

### step 2a.2 LDA Factorization
An unsupervised learning of cell type factors using LDA.

Input & Output:
```
# Input:
${output_dir}/${prefix}.feature.clean.tsv.gz
${model_dir}/${hexagon_prefix}.tsv.gz

# Output: 
${model_dir}/${train_prefix}.model.p
${model_dir}/${train_prefix}.fit_result.tsv.gz
${model_dir}/${train_prefix}.posterior.count.tsv.gz
```

Command:
```
$neda_dir/steps/step2a.2-LDA-factorization.sh $input_configfile
```

### step 2a.3 LDA factorization report
This step includes: generating a color table, identifying marker genes for each factor, and creating a report html file, which summarizes individual factors and marker genes.

Input & Output:
```
# Input:
${model_dir}/${train_prefix}.fit_result.tsv.gz
${model_dir}/${train_prefix}.posterior.count.tsv.gz

# Output: 
${model_dir}/${train_prefix}.color.tsv
${model_dir}/${train_prefix}.bulk_chisq.tsv
${model_dir}/${train_prefix}.factor.info.html
```

Command:
```
$neda_dir/steps/step2a.3-LDA-factorization-report.sh $input_configfile
```