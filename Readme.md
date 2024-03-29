# eggd_fastqc

Based on http://www.bioinformatics.babraham.ac.uk/projects/fastqc/
and the DNAnexus FastQC app (app-FZ68b180qjX8ZFVxGJ1Qg2vF)

## Version
eggd_fastqc v1.2.0 uses FastQC v0.12.1 

## What does this app do?
Runs fastqc for each fastq file submitted as input.
Each fastqc run is performed as a sub-job of the parent job

## What are typical use cases for this app?
Quality control for NGS reads

## What data are required for this app to run?

Input files:
1. `fastqs` - An array of fastq files ( .fastq.gz | fq.gz )

## What does this app output?

This app outputs:
1. report_htmls - an array of fastqc report html files. One report is generated per input fastq.
2. stats_txts - an array of fastqc stats txt files. One report is generated per input fastq.

## How does this app work?

The parent job runs the main() function which submits one subjob for each input fastq file. Each subjob runs the fastqc() function.

## What are the limitations of this app?
Optional fastqc inputs (e.g. kmer size, contaminants, adapters) are handled within code.sh but have not been implemented within dxapp.json. This functionality will be restored in a future version. 