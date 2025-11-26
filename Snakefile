#Snakefile for smina workflow
#Input receptor and ligand
#Output scoring list and visualisation

#1. Load config file

configfile: "config.yaml"


#2. Goal

rule all:
    input:
        config["output_name"],
        config["smina_plot"]


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
        #Manualbox parameters, remove comments to enable and comment out autobox_ref_file and autobox_add
        #Must also modify config file
        #cx = config["center"]["x"], cy = config["center"]["y"], cz = config["center"]["z"],
        #sx = config["size"]["x"], sy = config["size"]["y"], sz = config["size"]["z"],
    log:
        #Log results
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

#6. Clean smina.log to csv
rule clean_log:
    input:
        log = "results/smina.log"
    output:
        csv = config["clean_csv"]
    shell:
        """
        echo "Mode,Affinity,RMSD_lb,RMSD_ub" > {output.csv}
        awk '$2 ~ /^-?[0-9]/ {{ print $1","$2","$3","$4 }}' {input.log} >> {output.csv}
        """


#7. Plot RMSD vs Affinity from cleaned smina.log
rule plot_results:
    input:
        csv = config["clean_csv"]
    output:
        plot = config["smina_plot"]
    shell:
        "python {workflow.basedir}/scripts/AffinityvsRMSD.py {input.csv} {output.plot}"


#8. Visualization (Optional activation using visualize, run without first followed by this by simply adding "visualize")
rule visualize:
    input:
        plot = config["smina_plot"],
        log = config["smina_log"],
        docked = config["output_name"],
        lig_qt = "results/ligand.pdbqt",
        rec_qt = "results/receptor.pdbqt"
    shell:
        """
        # Open the Plot and Log
        open {input.plot}
        open {input.log}
        
        # Launch PyMOL with the 3 structures loaded
        pymol {input.docked} {input.lig_qt} {input.rec_qt} &
        """