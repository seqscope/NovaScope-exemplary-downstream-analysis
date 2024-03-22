## 1. Download the NovaScope-exemplary-downstream-analysis (NEDA) repository

```
git clone git@github.com:seqscope/NovaScope-exemplary-downstream-analysis.git 
```

## 2. Install Softwares and Dependencies

### 2.1 Install Dependent Softwares:

Ensure the installation of the below software to facilitate analysis. The versions listed below have been confirmed for compatibility with NEDA while alternative versions may also work with it.

High-performance computing (HPC) users can easily load these programs using the `module load` command. It's advisable to first check availability with `module available` or `module spider`.

* Samtools (v1.14)
* Python (v3.10) 
* R (v4.2)
* FICTURE 

To install FICTURE, run:

```
git clone git@github.com:seqscope/ficture.git
```

### 2.2 Create a Python Environment:

Set up a Python environment for FICTURE as per the [requirement file](https://github.com/seqscope/ficture/blob/8ceb419618c1181bb673255427b53198c4887cfa/requirements.txt).

Here is an example of creating a Python environment using `venv`. It's also possible to establish such environments through alternative methods, including `conda`, `virtualenv`, and `pyenv`.

```
## set the path to the python virtual environment directory
pyenv_dir=/path/to/python/virtual/environment/directory
pyenv_name=name_of_python_venv

## create the python virtual environment (need to be done only once)
mkdir -p ${pyenv_dir}
cd ${pyenv_dir}
python -m venv ${pyenv_name}

## activate the python environment (every time you want to use the environment)
source ${pyenv_name}/bin/activate

## download the package list required by FICTURE (need to be done only once)
curl -o requirements.txt https://raw.githubusercontent.com/seqscope/ficture/8ceb419618c1181bb673255427b53198c4887cfa/requirements.txt

## install the required packages (need to be done only once)
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

```

```