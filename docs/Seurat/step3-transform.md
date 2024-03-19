# Latent Dirichlet Allocation (LDA) + FICTURE analytical strategy

## step 3 Transform 
The `tranform_prefix` will be automatically defined by the script as below.

```
tranform_prefix="${train_prefix}.prj_${pw}.r_${ar}"
```

### step 3.1 Transform
Convert to a factor space using the provided model, which includes gene names and potentially Dirichlet parameters. The pixel-level data will be organized into (potentially overlapping) hexagonal groups.

Input: `${output_dir}/${prefix}.QCed.matrix.tsv.gz`, `${model_dir}/${train_prefix}.model.tsv.gz`

Output: `${model_dir}/${tranform_prefix}.fit_result.tsv.gz`, `${model_dir}/${tranform_prefix}.posterior.count.tsv.gz`
```
$neda_dir/steps/step3.1-transform.sh $input_configfile
```

### step 3.2 transform visualization
For LDA, use the color table from the training model. This color table will also be used in Step4.

Input: `${model_dir}/${tranform_prefix}.fit_result.tsv.gz`, `${model_dir}/${tranform_prefix}.posterior.count.tsv.gz`, `${output_dir}/${prefix}.coordinate_minmax.tsv`

Output: `${model_dir}/${tranform_prefix}.rgb.tsv`, `${model_dir}/${tranform_prefix}.top.png`

```
$neda_dir/steps/step3.2-transform-visualization.sh $input_configfile
```