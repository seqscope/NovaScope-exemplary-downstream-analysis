## 1. Download the NovaScope-exemplary-downstream-analysis (NEDA) repository

```
git clone git@github.com:seqscope/NovaScope-exemplary-downstream-analysis.git 

cd NovaScope-exemplary-downstream-analysis
neda_dir=$(realpath ./)                         # 
```

## 2. Install Softwares and Dependencies

### 2.1 Install Softwares:

Ensure the installation of the below software to facilitate analysis. The versions listed below have been confirmed for compatibility with NEDA while alternative versions may also work with it.

* Samtools (v1.14)
* Python (versions 3.10) 
* R (v4.2)
* FICTURE (Install via `git clone git@github.com:seqscope/ficture.git`)

### 2.2 Create a Python Environment:

Set up a Python environment for FICTURE as per the [guidelines](https://github.com/seqscope/ficture/blob/8ceb419618c1181bb673255427b53198c4887cfa/requirements.txt).

```
cd $neda_dir                                # Replace $neda_dir with the path to build your pyenv
pyenv_name=<name_of_python_environment>     # Replace <name_of_python_environment> with any name
python -m venv $pyenv_name
source $pyenv_name/bin/activate

curl -o requirements.txt https://raw.githubusercontent.com/seqscope/ficture/8ceb419618c1181bb673255427b53198c4887cfa/requirements.txt
pip install -r ./requirements.txt
```

### 2.3 Install R Packages:

To enable Seurat analysis, install the following required R packages:

* Seurat
* ggplot2
* patchwork
* dplyr
* tidyverse
* stringr
* cowplot
* optparse
* grDevices
* RColorBrewer

## 3. Reference Data

The downstream analysis also requires gene info reference. Please download the one matching your input file's species [here](https://github.com/seqscope/ficture/tree/protocol/info).
