# DeepVariant insigths

This document is an overview of DeepVariant.

## DeepVariant algorithm

### Pipeline overview

Here is a schematic of the whole pipeline, the steps are detailed below.

![Alt text](Images/DeepVariant_first_steps.jpg?raw=true "Pipeline part 1")
![Alt text](Images/path/to/DeepVriant_last_steps?raw=true "Pipelin part 2")

### Preprocessing (steps 1-2)

- (step 1) Alignement of the data.
- (step 1) Mark duplicates and recalibration of scores.
- (step 2) Use candidates from here based on mismatches and clips.

### Candidate emission (steps 3-6)

- (step 3) Local realignment
- (step 4) Create de Bruijn graph, weight each edge by the number of appearances in the reads and reference.
- (step 5) Select two most likely haplotypes using HMMs. This is limited to 2 because DeepVariant is designed
  for diploidy and germline mutations (no somatic ones).
- (step 5, 6) Filters the haplotypes based on:
    - read quality.
    - frequency of the variant.
    - # appearnces of the variant.
    - different from reference (no point in emitting reference).

### Image encoding (step 7)

Before the classification the data needs to be represented in the appropriate format.

A 3D representation is chosen with:

- rows: associated with a read.
- column: associated with the (relative) location in the reference genome.
- color (RGB): encodes the information at that position in a read.

The 3D reprensentation is called a pile-up image.

The dimension of this pile-up image is 100x221x3.

The second coordinates are (assumed to be) centered on the position of the candidate variant
(i.e 111th column). It thus contains information about the 110bps before and after the candidate
location for a variant.

The first five rows are dedicated to the reference genome, each following row is dedicated to a read
supporting the candidate variant (must thus overlap with the position of the candidate variant).

#### Color encoding:

- Red: base type.
- Green: quality score.
- Blue: direction of the strand.
- Alpha: is reference or not.

### Classification (step 8)

For each image generated for a candidate variant a classifier (Inception V2) is used to classify
this variant as either a real one or an error.

## DeepVariant insights

### Main difference with GATK best practices

In order to call the variants, GATK does two steps:

- Use HaplotypeCaller or Unified Genotyper in order to do the genotyping step.
- Use VQSR (with population information) in order to filter the variants.

Here DeepVariants does the two steps at once.

### Why it works

Small indels and SNPs are local variations on the genomes, representing them as a grid keeps
that local information and allows Neural Networks to process them.

Indeed neural networks are great statistical tools for pattern matching and can thus take advantage
of that locality using tools from image processing.

By skipping the VQSR step, DeepVariant does *not* use population information. Since VQSR is a
filtering step it can lower the recall by having false negative (i.e. mutations not present in the
population information used in VQSR). Not doing that steps helps DeepVariant having a high recall.

### Limits

#### Polyploidy

DeepVariant has been critized in its inability of working on polyploid data, I believe that this
critic is not correct as the diploid assumption is done in the preprocessing and can thus be easily
added by allowing more than two haplotypes to be emitted.

Working on non-diploid data is of high interest for discovering somatic mutations, especially in the
case of cancer patients or mosaic individuals.

#### Structural variants

I believe that DeepVariant cannot be used for finding structural variants.

Indeed DeepVariants works thanks to the assumption that the mutations are local variations, this is
the case for small indels and SNPs, but is not a correct assumption for SVs.  
Furthermore in the classification step DeepVariant does not use information about the absolute
coordinates of the candidate variant in the genome, this information is critical for identifying and
localinzing SVs (translocations for example).

It is also the case that DeepVariant is highly dependant on its candidate emission step, which is
itself dependant on the alignment quality. Having a proper alignment in the case of SVs is actually
the problem that needs solving in SV calling. DeepVariant can thus by construction not be used for
this problem as it happens after that step (it is noteworthy that the authors never made claims
about SV calling).

What's more DeepVarian works on windows of size 221bp, it is once again by construction unable to
detect variations larger than the size of that window.
