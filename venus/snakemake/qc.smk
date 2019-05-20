# Venus Quality-Control Workflow
# ----------------------------------------------------------------------
#
# Quality-filters and adapter-trims paired Illumina .fastq files.

localrules: qc_all

qc_output_dir = output_dir + 'qc/'
qc_working_dir = working_dir + 'qc/'
qc_reports_dir = reports_dir + 'qc/'

def sample_pairs(wc):
    sample_row = samples.loc[samples['sample_label'] == wc.sample]
    return {'r1': sample_row.r1_fp, 'r2': sample_row.r2_fp}

rule qc:
    input:
        unpack(sample_pairs)
    output:
        r1 = qc_output_dir + '{sample}_1.fastq.gz',
        r2 = qc_output_dir + '{sample}_2.fastq.gz',
    log:
        html = qc_reports_dir + 'fastp/{sample}.html',
        json = qc_reports_dir + 'fastp/{sample}.json'
    conda:
        resource_filename("venus", "snakemake/envs/qc.yaml")
    threads:
        config.get('qc_threads', 8)
    shell:
        (
            "fastp "
            " -i {input.r1} -I {input.r2}"
            " -o {output.r1} -O {output.r2}"
            " -h {log.html} -j {log.json}"
            " --thread {threads}"
        )

rule qc_all:
    message: "QC'd sequences are in {}".format(qc_output_dir)
    input:
        r1 = expand(rules.qc.output.r1, sample = list(samples.sample_label)),
        r2 = expand(rules.qc.output.r2, sample = list(samples.sample_label))
        

        
    
    
