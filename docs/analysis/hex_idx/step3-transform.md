# Step 3 Transform 

**Prefix**:

The `tranform_prefix` will be automatically defined by the script as below.
```bash
tranform_prefix="${train_prefix}.prj_${pw}.r_${ar}"
```
* See variables applied above in the [Job Configuration](./job_config.md).

## Step 3.1 Transform
Convert to a factor space using the provided model, which includes gene names and potentially Dirichlet parameters. The pixel-level data will be organized into (potentially overlapping) hexagonal groups. Please note that the format of the model file varies between LDA (`*.model.p`) and Seurat(`*.model.tsv.gz`).

Input & Output
```bash
# Input:
${output_dir}/${prefix}.transcripts_filtered.tsv.gz
${output_dir}/${train_model}/${train_prefix}.model.tsv.gz               # Only if the train model is defined as "Seurat"
${output_dir}/${train_model}/${train_prefix}.model.p                    # Only if the train model is defined as "LDA"

# Output:
${output_dir}/${train_model}/${tranform_prefix}.fit_result.tsv.gz
${output_dir}/${train_model}/${tranform_prefix}.posterior.count.tsv.gz
```

Command:
```bash
$neda_dir/steps/step3.1-transform.sh $input_configfile
```

## Step 3.2 Transform Visualization
For LDA, simply create a symbolic link from the color table created at [step 2a.3](step2a-LDA.md/#step-2a3-summarize-lda-factorization) and use it to visualize the transformed data.

For Seurat, this step creates a color table and visualize the transformed data. 

Input & Output
```bash
# Input:
${output_dir}/${train_model}/${train_prefix}.color.tsv                  # Only if the train model is defined as "LDA"
${output_dir}/${train_model}/${tranform_prefix}.fit_result.tsv.gz
${output_dir}/${prefix}.coordinate_minmax.tsv

# Output:
${output_dir}/${train_model}/${tranform_prefix}.rgb.tsv
${output_dir}/${train_model}/${tranform_prefix}.top.png
```

Command:
```bash
$neda_dir/steps/step3.2-transform-visualization.sh $input_configfile
```