# Step 4 Pixel-level Decoding

**Prefix**:

The decode_prefix will be automatically defined as below.
```bash
train_prefix="${prefix}.${solo_feature}.nf${nfactor}.d_${train_width}.s_${train_n_epoch}"
decode_prefix="${train_prefix}.decode.prj_${fit_width}.r_${anchor_dist}_${neighbor_radius}"
```

* `neighbor_radius`: represents the radius (um) of each anchor point's territory. By default, `neighbor_radius = anchor_dist + 1`.
* Other variables applied above are in the [Job Configuration](./job_config.md).


## Step 4.1 pixel-level Decoding. 
Decode the model matrix on individual pixels, which returns a tab-delimited file of the posterior count of factors on individual pixels.

Input & Output
```bash
# Input:
$input_xyrange                                                          ## user-defined input meta file for coordinates corresponding to the input SGE matrix
${output_dir}/${prefix}.batched.matrix.tsv.gz                           ## pixel minibatches from step1
${output_dir}/${train_model}/${train_prefix}.model_matrix.tsv.gz        ## a model matrix from LDA (step2a) or from Seurat (step2b)
${output_dir}/${train_model}/${tranform_prefix}.fit_result.tsv.gz       ## transform data from step3

# Output: 
${output_dir}/${train_model}/${decode_prefix}.pixel.sorted.tsv.gz
```

Commands:
```bash
$neda_dir/steps/step4.1-pixel-level-decode.sh $input_configfile
```

## Step 4.2 Visualizing Pixel-Level Decoding and Generating Marker Gene Reports
Identify marker genes for each cluster, and generate a report html file that summarizes individual factors and marker genes. In addition, this step creates a high-resolution image of cell type factors for individual pixels using the color table generated at [step 3.2](step3-transform.md/#step-32-transform-visualization).

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

Commands:
```bash
$neda_dir/steps/step4.2-pixel-level-visualization-and-report.sh $input_configfile
```