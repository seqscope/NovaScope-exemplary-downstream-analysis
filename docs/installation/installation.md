## 1. Install the NovaScope-exemplary-downstream-analysis (NEDA)

Use `--recursive` to make sure both NEDA and its submodule are cloned. 

```bash
git clone --recursive git@github.com:seqscope/NovaScope-exemplary-downstream-analysis.git 
```

## 2. Install Software and Dependencies

### 2.1 Install Dependent Softwares

Ensure the installation of the below software to facilitate analysis. The versions listed below have been confirmed for compatibility with NovaScope-exemplary-downstream-analysis (NEDA) while alternative versions may also work with it.

High-performance computing (HPC) users can easily load these programs using the `module load` command. It's advisable to first check availability with `module available` or `module spider`.

* Samtools (v1.14)
* Python (v3.10) 
* R (v4.2)

### 2.2 Install FICTURE and Its Dependencies

#### 2.2.1 Install FICTURE

NEDA has included [FICTURE](https://github.com/seqscope/ficture/tree/protocol) as a submodule. We suggest the users to double check the `submodule/ficture` folder to make sure the FICTURE has been cloned successfully:

```bash
## define the path of NEDA 
neda_dir=/path/to/neda

## double-check the ficture directory
ls -hlt $neda_dir/submodules/ficture
```

#### 2.2.2 Create a Python Environment

Set up a Python environment for [FICTURE](https://github.com/seqscope/ficture/tree/protocol) as per the [requirement file](https://github.com/seqscope/ficture/blob/8ceb419618c1181bb673255427b53198c4887cfa/requirements.txt). The requirement file is included in the FICTURE repository.

First, ensure the requirements file is accessible:

```bash
## path to the requirement file in the FICTURE repository
ficture_reqfile=$neda_dir/submodules/ficture/requirements.txt

## verify the existence of the requirement file.
if [ -f "$ficture_reqfile" ]; then
    echo -e "The requirement file for FICTURE exists."
else
    echo -e "Error: The requirement file for FICTURE does not exist.\n"
    echo -e "Now downloading such requirement file..."
    curl -o $ficture_reqfile https://raw.githubusercontent.com/seqscope/ficture/8ceb419618c1181bb673255427b53198c4887cfa/requirements.txt
fi
```

Now, install the required packages. Below is an example of creating a new Python environment using `venv`. It's also possible to establish such environments through alternative methods, including `conda`, `virtualenv`, and `pyenv`.

```bash
## set the path to the Python virtual environment directory
pyenv_dir=/path/to/python/virtual/environment/directory
pyenv_name=name_of_python_venv

## create the Python virtual environment (need to be done only once)
mkdir -p ${pyenv_dir}
cd ${pyenv_dir}
python -m venv ${pyenv_name}

## activate the Python environment (every time you want to use the environment)
source ${pyenv_name}/bin/activate

## install the required packages (need to be done only once)
pip install -r $$ficture_reqfile
```

### 2.3 Install R Packages

To enable Seurat analysis, install the following required R packages:

* Seurat
* ggplot2
* patchwork
* dplyr
* tidyverse
* stringr
* cowplot
* optparse
* RColorBrewer

```R
## install all required packages in R
install.packages(c( "Seurat", "optparse", "patchwork", "dplyr", "tidyverse", "stringr", 
                    "ggplot2", "cowplot", "RColorBrewer"))
```