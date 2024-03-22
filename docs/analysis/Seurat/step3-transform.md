# Seurat + FICTURE analytical strategy

## Step 3 Transform 

**Prefix**:

The `tranform_prefix` will be automatically defined by the script as below.
```
tranform_prefix="${train_prefix}.prj_${pw}.r_${ar}"
```

### Step 3.1 Transform
Convert to a factor space using the provided model, which includes gene names and potentially Dirichlet parameters. The pixel-level data will be organized into (potentially overlapping) hexagonal groups.

Input & Output
```
#Input:
${output_dir}/${prefix}.QCed.matrix.tsv.gz
${model_dir}/${train_prefix}.model.tsv.gz               # The format of the model file varies between LDA and Seurat.

#Output:
${model_dir}/${tranform_prefix}.fit_result.tsv.gz
${model_dir}/${tranform_prefix}.posterior.count.tsv.gz
```

Command:
```
$neda_dir/steps/step3.1-transform.sh $input_configfile
```

### Step 3.2 transform visualization
For Seurat, create a color table and visualize the transformed data. 

Input & Output
```
# Input:
${model_dir}/${tranform_prefix}.fit_result.tsv.gz
${model_dir}/${tranform_prefix}.posterior.count.tsv.gz
${output_dir}/${prefix}.coordinate_minmax.tsv

#Output:
${model_dir}/${tranform_prefix}.rgb.tsv
${model_dir}/${tranform_prefix}.top.png

```

Command:
```
$neda_dir/steps/step3.2-transform-visualization.sh $input_configfile
```