# Automated Molecular Docking Pipeline with AutoDock Vina (Smina) using Snakemake

## This project provides a reproducible, automated workflow for **Protein-Small Molecule Docking**

The pipeline is designed to:
1.  **Prepare Data:** Convert raw PDB files to PDBQT format (adding hydrogens and partial charges) using OpenBabel.
2.  **Dock:** Perform rigid-receptor docking using Smina with **Autoboxing** (or manual) features.
3.  **Analyze:** Parse logs to extract binding energies and calculate RMSD values relative to a crystal structure reference from smina.log.
4.  **Visualize:** Automatically generate "Plots" (Energy vs. RMSD) and launch interactive PyMOL sessions vis visualize rule.


The workflow was benchmarked using **Streptavidin-Biotin** provided as example pdb data files under sminasnakemake/data, this workflow is configuration-driven and can be adapted
to other targets via the config.yml file and input files.

## Project Structure

```text

│
├── sminasnakemake/   
│   ├── Snakefile                   # The workflow rules (DAG)
│   ├── config.yaml                 # Configuration (Run parameters & Paths)
│   ├── README.md                   # This file
|   ├── env                         # Conda environment(s)
│   └── scripts/                    # Helper scripts
│       ├── plot_simple.py          # Python plotting script (RMSD vs Affinity)
```

## Dependencies and Installatioon

To run the workflow it is recommended to utilize a **conda environment** with the dependencies below. The following packages are necessary and can be installed via:

```text
conda create -n smina_env -c conda-forge \
    snakemake \
    smina \
    openbabel \
    pandas \
    matplotlib \
    seaborn \
    pymol-open-source
```

or, utilizing the environment.yml under sminasnakemake/env by the following:

```text
snakemake --use-conda
```

Activate the environment before use via:

```text
conda activate <env_name>
```

## Configuration

Parameters for the workflow can be found withing the config.yml file along with data input and output filepaths.


## Running the wrokflow

To run the snakemake from anywhere, activate the conda environment and run the following bash command with modified filepaths to snakefile, directory and configfile:

```text
snakemake \
--snakefile "/Path/To/Snakefile" \
--directory "/Path/To/InputandOutput" \
--configfile "/Path/To/config.yaml" \
--cores 4
```

"visualize" can be added to run an additional rule opening Plot, smina.log and PyMol input and output:


```text
snakemake \
--snakefile "/Path/To/Snakefile" \
--directory "/Path/To/InputandOutput" \
--configfile "/Path/To/config.yaml" \
--cores 4 \
visualize
```



