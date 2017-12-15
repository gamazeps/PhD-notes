# Way to generate the phase 3 data


[source](https://images.nature.com/original/nature-assets/nature/journal/v526/n7571/extref/nature15393-s1.pdf)

## High coverage

1. Alignment to GRCh37 (hg19) decoy reference (3.6.1) genome.  
```
bwa mem -p -M -t $ref_fa $fq_file
```
2. Adapter clipping.
```
java -jar MarkIlluminaAdapters.jar INPUT=in.bam OUTPUT=out.bam
PE=true ADAPTERS=DUAL_INDEXED M=out.bam.adapter_metrics
```
3. Indel realignment. See http://gatkforums.broadinstitute.org/
discussion/38/local-realignment-around-indels for command lines.
4. Base Quality Score Recalibration. See http://gatkforums.broadinstitute.
org/discussion/44/base-quality-score-recalibration-bqsr for command
lines.


## Low coverage

Data was aligned with bwa v0.5.915 to the GRCh37 (hg19) decoy reference (see
Section 3.6.1). The reference fasta file was first indexed:
```
bwa index -a bwtsw $ref_fa
```
Then, for each fastq file, a suffix-array index (sai) file was created
```
bwa aln -q 15 -f $sai_file $ref_fa $fq_file
```
Aligned SAM files16 were created using using ‘bwa sampe’ or ‘samse’ for paired-end
or unpaired reads respectively. For paired-end reads, the maximum insert size was
set to be 3 times the expected insert size.
```
bwa sampe -a $max_insert_size -f $sam $ref_fa $sai_files $fq_files
bwa samse -f $sam_file $ref_fa $sai_file $fq_file
```
SAM was converted to BAM, name-sorted, mate information fixed, coordinate-sorted
and the MD tag added:
```
samtools view -bSu $sam | \
samtools sort -n -o - samtools_nsort_tmp | \
samtools fixmate /dev/stdin /dev/stdout | \
samtools sort -o - samtools_csort_tmp | \
samtools fillmd -u - $ref_fa > $bam
```
As in Phase 1, run-level alignment BAMs are improved in various ways to help
increase the quality and speed of subsequent SNP calling that may be carried out on
them. Reads were locally realigned around known indels using GATK IndelRealigner.
```
java $jvm_args -jar GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R $ref_fa -o $intervals_file \
-known $known_indels_file(s)
java $jvm_args -jar GenomeAnalysisTK.jar \
-T IndelRealigner \
-R $ref_fa -I $bam_file -o $realigned_bam_file \
-targetIntervals $intervals_file \
-known $known_indels_file(s) \
-LOD 0.4 -model KNOWNS_ONLY -compress 0 --disable_bam_indexing
```

The set of known indels was updated since Phase 1 to the include both the MillsDevine
double-hit high-quality indel set and the 1000 Genomes Phase 1 indel set.
These files used are available here:
ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_mapping_
resources/ALL.wgs.indels_mills_devine_hg19_leftAligned_collapsed_double_hit.
indels.sites.vcf.gz
ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_mapping_
resources/ALL.wgs.low_coverage_vqsr.20101123.indels.sites.vcf.gz

Base quality scores were then recalibrated using GATK CountCovariates and TableRecalibration.
```
java $jvm_args -jar GenomeAnalysisTK.jar \
-T CountCovariates \
-R $ref_fa -I $realign_bam -recalFile recal_data.csv \
-knownSites $known_sites_file(s) -l INFO \
-cov ReadGroupCovariate -cov QualityScoreCovariate \
-cov CycleCovariate -cov DinucCovariate \
-L ‘1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;X;Y;MT’
java $jvm_args -jar GenomeAnalysisTK.jar \
-T TableRecalibration \
-R $ref_fa -recalFile recal_data.csv \
-I $realign_bam -o $recal_bam \
-l INFO -compress 0 --disable_bam_indexing
```
The set of known sites for recalibration was updated since Phase 1 to dbSNP135,
which includes sites from Phase 1.
ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_mapping_
resources/ALL.wgs.dbsnp.build135.snps.sites.vcf.gz

Recalibrated BAMs were then passed through samtools calmd to fix NM tags and
introduce BQ tags which can be used during SNP calling17.

```
samtools calmd -Erb $recal_bam $ref_fa > $bq_bam
```
Release BAM file production: The improved BAMs were merged together to
create the release BAM files available for download. Release BAM files therefore
contain reads from multiple readgroups.
Run-level BAMs have extraneous tags (OQ, XM, XG, XO) stripped from them, to
reduce total file size by around 30%. Tag-stripped BAMs from the same sample and
library were merged with Picard MergeSamFiles.
```
java $jvm_args -jar MergeSamFiles.jar \
INPUT=$tag_strip_bam(s) OUTPUT=$library_bam \
VALIDATION_STRINGENCY=SILENT
```
PCR duplicates are marked in library BAMs using Picard MarkDuplicates.
```
java $jvm_args -jar MarkDuplicates.jar \
INPUT=$library_level_bam OUTPUT=$markdup_bam \
ASSUME_SORTED=TRUE METRICS_FILE=/dev/null \
VALIDATION_STRINGENCY=SILENT
```
Duplicate-marked library BAMs from the same sample were merged with Picard
MergeSamFiles.
```
java $jvm_args -jar MergeSamFiles.jar \
INPUT=$markdup_bam(s) OUTPUT=$sample_bam \
VALIDATION_STRINGENCY=SILENT
```
Sample BAMs were split into mapped and unmapped BAMs for release.
