#!/bin/bash
# multi_fastqc 1.0.0
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://documentation.dnanexus.com/developer for tutorials on how
# to modify this file.

fastqc() {
    
    # The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

# Run FastQC

sample_name=${reads_name%.fastq.gz}
sample_name=${sample_name%.fq.gz}
sample_name=${sample_name%.bam}
sample_name=${sample_name%.sam}

mkdir results

# FASTQC doesn't play nicely with streamed BAM/SAM inputs

# Using streaming method of downloading for FASTQ/FASTQ.gz inputs
#mark-section "running FastQC"

dx cat "$reads" | zcat | /FastQC/fastqc --extract -t $(nproc) -k "${kmer_size}" -o results ${opts} -f "fastq" ${extra_options} stdin:"$sample_name"

#
# Upload results
#

mkdir -p ~/out/report_html/ ~/out/stats_txt/
mv results/*/fastqc_report.html ~/out/report_html/"$reads_prefix".stats-fastqc.html
mv results/*/fastqc_data.txt ~/out/stats_txt/"$reads_prefix".stats-fastqc.txt

report_html=$(dx upload /home/dnanexus/out/report_html/${reads_prefix}.stats-fastqc.html --brief)
dx-jobutil-add-output report_html "${report_html}" --class=file

stats_txt=$(dx upload /home/dnanexus/out/stats_txt/${reads_prefix}.stats-fastqc.txt --brief)
dx-jobutil-add-output stats_txt "${stats_txt}" --class=file

}


main() {

    set -e -x -o pipefail
    echo "Value of fastqs: '${fastqs[@]}'"

    #
    # Set up some options
    #
    opts=()
    if [[ "${contaminants_txt}" != "" ]]; then
        opts+=("-c" "./in/contaminants_txt/*")
    fi
    if [[ "${adapters_txt}" != "" ]]; then
        opts+=("-a" "./in/adapters_txt/*")
    fi
    if [[ "${limits_txt}" != "" ]]; then
        opts+=("-l" "./in/limits_txt/*")
    fi
    if [[ "${nogroup}" == "true" ]]; then
        opts+=("--nogroup")
    fi

    opts_str=$(echo ${opts[@]})
    echo $opts_str

    # Run fastqc for each fastq input file
    fastqc_jobs=()
    for i in ${!fastqs[@]}
    do
        file_id=$(echo ${fastqs[$i]} | jq '.["$dnanexus_link"]' | sed s/\"//g )
        command="dx-jobutil-new-job fastqc -ireads=${file_id} -ikmer_size=${kmer_size} -iopts="${opts_str}" -iextra_options=${extra_options}"
        fastqc_jobs+=($(eval $command))
    done

    # Get the output from the fastqc jobs
    echo "fastqc jobs:"
    echo "${fastqc_jobs[@]}"
    
    echo "Specifying output file"
    for job in ${fastqc_jobs[@]}
    do
        dx-jobutil-add-output report_htmls ${job}:report_html --class=array:jobref
        dx-jobutil-add-output stats_txts ${job}:stats_txt --class=array:jobref

    done
}
