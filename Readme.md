# Venus: Illumina qc and assembly companion pipeline for [MARS](https://github.com/eclarke/mars)

Snakemake-based pipeline for quality control reporting and assembly (both _de novo_ and reference-based) from an Illumina run.

_Warning: very much in active development._

## Setup

### Requirements:

- conda
- python3

### Installation

```bash
conda create -n venus python=3
conda activate venus
git clone https://github.com/eclarke/venus
cd venus
pip install .
```

### Getting started

For the impatient:

```bash
# activate venus environment
conda activate venus
# change into your project directory
cd my_project
# create a default config file at `config.yml`
venus init
# edit config file as desired
nano config.yml
# edit the samplesheet as desired in the format sample_label,r1_fp,r2_fp
nano samplesheet.csv
# qc your samples
venus run config.yml qc_all
# assemble your samples
venus run config.yml assemble_all
```
