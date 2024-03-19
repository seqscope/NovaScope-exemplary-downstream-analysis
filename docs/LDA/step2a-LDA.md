# Latent Dirichlet Allocation (LDA) + FICTURE analytical strategy

## Step 2a. Infer Cell Type Factors using LDA.

To clarify the input and output filenames, we have utilized prefixes in this documentation. Below, we illustrate how these prefixes are automatically applied by the script. 

It is important to note that users do NOT need to manually define these prefixes; they are automatically defined by the script.

```
hexagon_prefix="${prefix}.hexagon.${sf}.d_${tw}"
train_prefix="${prefix}.${sf}.nF${nf}.d_${tw}.s_${ep}"
```

### step 2a.1 Create hexagonal SGE
Given a specified size of hexagons, segment the raw SGE matrix into hexagons and store them into a spatial gene expression (SGE) matrix in the format compatible with FICTURE.

Input: `${output_dir}/${prefix}.QCed.matrix.tsv.gz`, `${output_dir}/${prefix}.boundary.strict.geojson`

Output: `${model_dir}/${hexagon_prefix}.tsv.gz`

```
$neda_dir/steps/step2a.1-create-hexagons.sh $input_configfile
```

### step2a.2 LDA Factorization
An unsupervised learning of cell type factors using LDA.

Input: `${output_dir}/${prefix}.feature.clean.tsv.gz`, `${model_dir}/${hexagon_prefix}.tsv.gz`

Output: `${model_dir}/${train_prefix}.model.p`, `${model_dir}/${train_prefix}.fit_result.tsv.gz`, `${model_dir}/${train_prefix}.posterior.count.tsv.gz`

```
$neda_dir/steps/step2a.2-LDA-Factorization.sh $input_configfile
```

### step2a.3 LDA train report
This includes: generating a color table, identifying marker genes for each factor, and creating a report html file, which summarizes individual factors and marker genes.

Input: `${model_dir}/${train_prefix}.fit_result.tsv.gz`, `${model_dir}/${train_prefix}.posterior.count.tsv.gz`
Output: `${model_dir}/${train_prefix}.color.tsv`, `${model_dir}/${train_prefix}.bulk_chisq.tsv`, `${model_dir}/${train_prefix}.factor.info.html`

```
$neda_dir/steps/step2a.3-LDA-train-report.sh $input_configfile
```