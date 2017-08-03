# OrderFromSamtools
Reorders by-individual consensus FASTQ files into FASTA by-gene alignments

This code was designed to process "by individual" FASTQ files that contain mapped consensus sequences of multiple genes. These aligned consensus sequences were generated in `samtools` (and other software) but stored in "by individual" files.

`OrderFromSamtools.pl` extracts the data and orders it in "by gene/region" alignments, with the name of the "individual" files as FASTA headers. Since these sequences were produced from aligning to a reference they should be aligned. Still, the program will introduced "Ns" as missing data according to the longest sequence found per gene/region. The result is a folder with all "per gene/region" FASTA alignments.

## Installation

    git clone https://github.com/santiagosnchez/OrderFromSamtools
    cd OrderFromSamtools
    chmod +x OrderFromSamtools.pl
    sudo cp OrderFromSamtools.pl /usr/local/bin

## Samtools code

The code to generate the FASTQ files:

    samtools view -b -S -o aln.bam aln.sam
    samtools sort aln.bam aln.sort
    samtools index aln.sort.bam
    samtools mpileup -uf probe_genes.fasta aln.sort.bam | bcftools view -cg - | vcfutils.pl vcf2fq -Q 20  > consensus.fastq

Multiple BAM files can be processed in a loop.

## Running the script

Run the program with the `-h` flag to have more details

    perl OrderFromSamtools.pl -h
    Try:
    perl OrderFromSamtools.pl -indir /path/to/fastq/files
                              -pattern fastq     [ or anything else present in all files ]
                              -outdir alignments [ or anything else, your outfiles will be stored here ]
                              -seqlist list.txt  [ a file with a list of sequence/gene names ]
                              -addlab            [ optional, you can add some label tu your sequences by editing %spp ]


