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

