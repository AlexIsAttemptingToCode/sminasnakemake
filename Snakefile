#Snakefile for smina workflow
#Input receptor and ligand
#Output scoring list and visualisation

#1. Load config file

configfile: "config.yaml"


#2. Goal

rule all:
    input:
        config["output_name"]


#3. Prep receptor

rule receptor_prep:
    input:
        config["receptor"]
    output:
        "results/receptor.pdbqt"
    shell:
        #Usen openbabel to add hydrogen and add partial charges
        "obabel {input} -O {output} -xr -h --partialcharge gasteiger"

#4. Prep ligand

rule ligand_prep:
    input:
        config["ligand"]
    output:
        "results/ligand.pdbqt"
    shell:
        # --gen3d generates 3D coordinates for molecules that lack them
        "obabel {input} -O {output} -h --gen3d --partialcharge gasteiger"


# In: ~/workflows/smina_project/Snakefile

#5. Run smina docking
rule run_smina:
    input:
        rec = "results/receptor.pdbqt",
        lig = "results/ligand.pdbqt",
        #Note -> autobox command needs the original PDB file for coordinates
        autobox_ref = config["autobox_ref"] 
    output:
        docked = config["output_name"]
    params:
        #Parameters for autobox, buffer size, etc.
        autobox_ref_file = config["autobox_ref"],
        autobox_add = config["autobox_buffer"],
        exhaust = config["exhaustiveness"],
        modes = config["num_modes"],
        cpu = config["cpu_cores"]
    log:
        #Log in case of problems
        "results/smina.log"
    shell:
        """
        smina --receptor {input.rec} \
              --ligand {input.lig} \
              --autobox_ligand {params.autobox_ref_file} \
              --autobox_add {params.autobox_add} \
              --exhaustiveness {params.exhaust} \
              --num_modes {params.modes} \
              --cpu {params.cpu} \
              --out {output.docked} \
              --log {log}
        """