# Venus Assembly Workflow
# ----------------------------------------------------------------------
#
# Assembles samples and assesses assembly quality

from pathlib import Path

localrules: assemble_all

asm_output_dir = output_dir + 'assemblies/'
asm_working_dir = working_dir + 'assemble/'
asm_reports_dir = reports_dir + 'assemble/'

rule create_ref_sketch:
    '''Creates a mash sketch of all provided reference genomes.'''
    output:
        asm_working_dir + 'reference_genomes.msh'
    params:
        k = config.get('mash_k_size', 32),
        ref_dir = config.get('ref_genomes_dir')
    threads:
        config.get('mash_threads', 8)
    conda:
        resource_filename("venus", "snakemake/envs/mash.yaml")
    shell:        
        """
        mash sketch -k {params.k} -p {threads} -o {output} {params.ref_dir}/*
        """

rule calc_ref_dist_mash:
    '''
    Calculates the minhash (mash) distance of the filtered reads
    to all the provided reference genomes.
    '''
    input:
        sketch = rules.create_ref_sketch.output,
        r1 = rules.qc.output.r1,
        r2 = rules.qc.output.r2
    output:
        asm_reports_dir + '{sample}/mash_distance_to_ref_genomes.tsv'
    threads:
        config.get('mash_threads', 1)
    conda:
        resource_filename("venus", "snakemake/envs/mash.yaml")
    shell:
        """
        mash dist -p {threads} {input.sketch} <(cat {input.r1} {input.r2}) |\
        sort -t$'\t' -k3 -n > {output}
        """

checkpoint mark_ref_genome:
    '''
    Writes the name of the closest reference genome to a flag file 
    for downstream rules. 
    '''
    input:
        rules.calc_ref_dist_mash.output
    output:
        directory(asm_working_dir + '{sample}/ref_genome')
    shell:
        """
        mkdir -p {output} &&
        ref=$(basename $(head -1 {input} | cut -f1)) &&
        touch {output}/$ref
        """

def ref_genome(wc):
    '''Returns the location of the ref genome in the ref genome directory'''
    ref_dir = checkpoints.mark_ref_genome.get(**wc).output[0]
    refs = [p.name for p in Path(ref_dir).glob("*.f*")]
    return expand(config.get('ref_genomes_dir') + '/{ref}', ref=refs)


rule assemble_spades:
    input:
        r1 = rules.qc.output.r1,
        r2 = rules.qc.output.r2
    output:
        contigs = asm_output_dir + 'spades/{sample}/scaffolds.fasta',
        graph = asm_output_dir + 'spades/{sample}/assembly_graph_with_scaffolds.gfa',
    params:
        output_dir = asm_output_dir + 'spades/{sample}',
        temp_dir = asm_working_dir + 'spades/{sample}'
    conda:
        resource_filename("venus", "snakemake/envs/spades.yaml")
    threads:
        config.get('assembly_threads', 8)
    shell:
        (
            "spades.py "
            " -o {params.output_dir}"
            " -1 {input.r1} -2 {input.r2}"
            " -t {threads}"
            " --tmp-dir {params.temp_dir}"
        )

rule assess_assembly_quast:
    input:
        reference=ref_genome,
        assembly=rules.assemble_spades.output.contigs
    output:
        directory(asm_reports_dir + '{sample}/quast')
    conda:
        resource_filename("venus", "snakemake/envs/quast.yaml")
    threads:
        config.get("assembler_threads", 8)    
    shell:
        """
        quast {input.assembly} \
        -o {output} \
        -r {input.reference} \
        -t {threads}
        """

rule assemble_all:
    message: "Assemblies are in {}".format(asm_output_dir)
    input:
        contigs=expand(
            rules.assemble_spades.output.contigs, sample=list(samples.sample_label)),
        reports=expand(
            rules.assess_assembly_quast.output, sample=list(samples.sample_label))
