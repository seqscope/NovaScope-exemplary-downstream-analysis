# Step 4 Pixel-level Decoding

**Prefix**:

The decode_prefix will be automatically defined as below.
```bash
decode_prefix="${train_prefix}.decode.prj_${pw}.r_${ar}_${nr}"
```

* `nr`: represents neighbor_radius. By default, `nr=ar+1`.
* Other variables applied above are in the [Job Configuration](./job_config.md).


## Step 4.1 pixel-level Decoding. 
Decoding the model matrix on individual pixels, which returns a tab-delimited file of the posterior count of factors on individual pixels.

Input & Output
```bash
# Input:
${output_dir}/${prefix}.coordinate_minmax.tsv
${output_dir}/${prefix}.batched.matrix.tsv.gz
${output_dir}/${prefix}.transcripts_filtered.tsv.gz
${output_dir}/${train_model}/${train_prefix}.model.tsv.gz               # Only if the train model is defined as "Seurat"
${output_dir}/${train_model}/${train_prefix}.model.p                    # Only if the train model is defined as "LDA"
${output_dir}/${train_model}/${tranform_prefix}.fit_result.tsv.gz

# Output: 
${output_dir}/${train_model}/${decode_prefix}.pixel.sorted.tsv.gz
```

Command:
```bash
$neda_dir/steps/step4.1-pixel-level-decode.sh $input_configfile
```

## Step 4.2 Visualizing Pixel-Level Decoding and Generating Marker Gene Reports
Identifying marker genes for each cluster, and generating a report html file that summarizes individual factors and marker genes. In addition, this step creates a high-resolution image of cell type factors for individual pixels using the color table generated at [step 3.2](step3-transform.md/#step-32-transform-visualization).

Input & Output
```bash
# Input:
${output_dir}/${train_model}/${decode_prefix}.posterior.count.tsv.gz
${output_dir}/${train_model}/${tranform_prefix}.rgb.tsv

# Output: 
${output_dir}/${train_model}/${decode_prefix}.bulk_chisq.tsv
${output_dir}/${train_model}/${decode_prefix}.factor.info.html
${output_dir}/${train_model}/${decode_prefix}.pixel.png
```

Command:
```bash
$neda_dir/steps/step4.2-pixel-level-visualization-and-report.sh $input_configfile
```