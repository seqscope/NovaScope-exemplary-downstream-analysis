# Step 3 Transform 

**Prefix**:

The `tranform_prefix` will be automatically defined by the script as below.
```bash
train_prefix="${prefix}.${solo_feature}.nf${nfactor}.d_${train_width}.s_${train_n_epoch}"
tranform_prefix="${train_prefix}.prj_${fit_width}.r_${anchor_dist}"
```

* See variables applied above in the [Job Configuration](./job_config.md).

## Step 3.1 Transform
Convert to a factor space using the provided model, which includes gene names and potentially Dirichlet parameters. The pixel-level data will be organized into hexagonal groups.

Input & Output
```bash
# Input:
$input_transcripts                                                      ## user-defined input SGE in FICTURE-compatible TSV format
${output_dir}/${train_model}/${train_prefix}.model_matrix.tsv.gz        ## a model matrix from LDA (step2a) or from Seurat (step2b)

# Output:
${output_dir}/${train_model}/${tranform_prefix}.fit_result.tsv.gz
${output_dir}/${train_model}/${tranform_prefix}.posterior.count.tsv.gz
```

Commands:
```bash
$neda_dir/steps/step3.1-transform.sh $input_configfile
```

## Step 3.2 Transform Visualization
For LDA, this step simply creates a symbolic link from the color table created at [step 2a.3](step2a-LDA.md/#step-2a3-summarize-lda-factorization) and uses it to visualize the transformed data.

For Seurat, this step creates a color table and visualize the transformed data.

Input & Output
```bash
# Input:
${output_dir}/${train_model}/${train_prefix}.color.tsv                  ## (LDA-only) use the existing color table if available
${output_dir}/${train_model}/${tranform_prefix}.fit_result.tsv.gz
$input_xyrange                                                          ## user-defined input min max coordinates for SGE

# Output:
${output_dir}/${train_model}/${tranform_prefix}.rgb.tsv
${output_dir}/${train_model}/${tranform_prefix}.top.png
${output_dir}/${train_model}/${tranform_prefix}.png
```

Commands:
```bash
$neda_dir/steps/step3.2-transform-visualization.sh $input_configfile
```