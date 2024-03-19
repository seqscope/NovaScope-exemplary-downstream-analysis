# Seurat + FICTURE analytical strategy

## Step 4 Pixel-level Decoding

The `decode_prefix` will be automatically defined by the script as below.

```
decode_prefix="${train_prefix}.decode.prj_${pw}.r_${ar}_${nr}"
```

### step 4.1 pixel-level decoding. Decoding the model matrix on individual pixels, which returns a tab-delimited file of the posterior count of factors on individual pixels.
Input: 
* `${output_dir}/${prefix}.coordinate_minmax.tsv`
* `${output_dir}/${prefix}.batched.matrix.tsv.gz`
* `${output_dir}/${prefix}.QCed.matrix.tsv.gz`
* `${model_dir}/${tranform_prefix}.model.tsv.gz`
* `${model_dir}/${tranform_prefix}.fit_result.tsv.gz`

Output: 
* `${model_dir}/${decode_prefix}.pixel.sorted.tsv.gz`

```
$neda_dir/steps/step4.1-pixel-level-decode.sh $input_configfile
```

### step 4.2 Pixel-level decoding visualization and report. 
This includes: identifying marker genes that are associated with each factor/cluster, generating a report html file that summarizes individual factors and marker genes, and creating a high-resolution image of cell type factors for individual pixels.

Input: 
* `${model_dir}/${decode_prefix}.posterior.count.tsv.gz`, 
* `${model_dir}/${tranform_prefix}.rgb.tsv`

Output: 
* `${model_dir}/${decode_prefix}.bulk_chisq.tsv`, 
* `${model_dir}/${decode_prefix}.factor.info.html`, 
* `${model_dir}/${decode_prefix}.pixel.png`

```
$neda_dir/steps/step4.2-pixel-level-visualization-and-report.sh $input_configfile
```