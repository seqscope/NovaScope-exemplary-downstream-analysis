# Step 2a. Infer Cell Type Factors using Latent Dirichlet Allocation (LDA).
This example illustrates infering cell type factors using Latent Dirichlet Allocation (LDA). 

**Prefix**:

To clarify the input and output filenames, we utilize prefixes in this documentation. Below, we illustrate how these prefixes are defined. Those prefixes are automatically defined by the script; users do **NOT** need to manually define them. 

```bash
hexagon_prefix="${prefix}.hexagon.${sf}.d_${tw}"
train_prefix="${prefix}.${sf}.nF${nf}.d_${tw}.s_${ep}"
```

* Details on variables used in above prefixes are in the [Job Configuration](./job_config.md).

## Step 2a.1 Create Hexagonal Spatial Gene Expression (SGE) matrix
Given a specified size of hexagons, segment the raw spatial gene expression (SGE) matrix into hexagonal SGE.

Input & Output
```bash
# Input:
${output_dir}/${prefix}.transcripts_filtered.tsv.gz
${output_dir}/${prefix}.boundary.strict.geojson

# Output: 
${output_dir}/${train_model}/${hexagon_prefix}.tsv.gz
```

Commands:
```bash
$neda_dir/steps/step2a.1-create-hexagons.sh $input_configfile
```

## Step 2a.2 LDA Factorization
An unsupervised learning of cell type factors using LDA.

Input & Output:
```bash
# Input:
${output_dir}/${prefix}.feature.clean.tsv.gz
${output_dir}/${train_model}/${hexagon_prefix}.tsv.gz

# Output: 
${output_dir}/${train_model}/${train_prefix}.model.p
${output_dir}/${train_model}/${train_prefix}.model_matrix.tsv.gz
${output_dir}/${train_model}/${train_prefix}.fit_result.tsv.gz
${output_dir}/${train_model}/${train_prefix}.posterior.count.tsv.gz
${output_dir}/${train_model}/${train_prefix}.coherence.tsv
${output_dir}/${train_model}/${train_prefix}.model_selection_candidates.p
```

Commands:
```bash
$neda_dir/steps/step2a.2-LDA-factorization.sh $input_configfile
```

## Step 2a.3 Creating Marker Gene Reports
This step includes: generating a color table, identifying marker genes for each factor, and creating a report html file, which summarizes individual factors and marker genes.

Input & Output:
```bash
# Input:
${output_dir}/${train_model}/${train_prefix}.fit_result.tsv.gz
${output_dir}/${train_model}/${train_prefix}.posterior.count.tsv.gz

# Output: 
${output_dir}/${train_model}/${train_prefix}.color.tsv
${output_dir}/${train_model}/${train_prefix}.bulk_chisq.tsv
${output_dir}/${train_model}/${train_prefix}.factor.info.html
```

Commands:
```bash
$neda_dir/steps/step2a.3-LDA-factorization-report.sh $input_configfile
```