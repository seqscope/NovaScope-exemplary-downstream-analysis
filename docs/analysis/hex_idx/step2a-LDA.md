# Step 2a. Infer Cell Type Factors using Latent Dirichlet Allocation (LDA).
This example illustrates inferring cell type factors using Latent Dirichlet Allocation (LDA). 

**Prefix**:

We use prefixes to clarify input and output filenames in this documentation. These prefixes are automatically defined by the script; users do **NOT** need to define them manually.

```bash
train_prefix="${prefix}.${solo_feature}.nf${nfactor}.d_${train_width}.s_${train_n_epoch}"
```

* Variable details for the prefixes are in the [Job Configuration](./job_config.md).

## Step 2a.2 LDA Factorization
An unsupervised learning of cell type factors using LDA.

Input & Output:
```bash
# Input:
$input_features                                      ## user-defined input features in TSV format
$input_hexagon_sge_ficture                           ## user-defined input hexagon-indexed SGE matrix in FICTURE-compatible format

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
$neda_dir/steps/step2a.1-LDA-factorization.sh $input_configfile
```

## Step 2a.3 Creating Marker Gene Reports
This step includes: generating a color table, identifying marker genes for each factor, and creating a report html file summarizing individual factors and marker genes.

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
$neda_dir/steps/step2a.2-LDA-factorization-report.sh $input_configfile
```