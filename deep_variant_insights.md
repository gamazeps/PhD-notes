# DeepVariant insigths

This document is an overview of DeepVariant.

## DeepVariant algorithm

### Preprocessing

- Alignement of the data
- Mark duplicates and recalibration of scores.
- Use candidates from here

### Candidate emission

- Local realignment
- Create de Bruijn graph, weight each edge by the number of appearances in the reads and reference.
- Select two most likely haplotypes using HMMs. This is limited to 2 because DeepVariant is designed
  for diploidy and germline mutations (no somatic ones).
- Filters the haplotypes based on:
    - read quality.
    - frequency of the variant.
    - # appearnces of the variant
    - different from reference (no point in emitting reference)

### Image encoding

Before the classification the data needs to be represented in the appropriate format.

A 3D representation is chosen with:

- rows: associated with a read
- column: associated with the (relative) location in the reference genome
- color (RGB): encodes the information at that position in a read.

The 3D reprensentation is called a pile-up image.

The dimension of this pile-up image is 100x221x3.

The second coordinates are (assumed to be) centered on the position of the candidate variant
(i.e 111th column). It thus contains information about the 110bps before and after the candidate
location for a variant.

The first five rows are dedicated to the reference genome, each following row is dedicated to a read
supporting the candidate variant (must thus overlap with the position of the candidate variant).


### Classification

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

DeepVariant has been critized in its ability of working on polyploid data, I believe that this
critic is not correct as the diploid assumption is done in the preprocessing and can thus be easily
added by allowing more than two haplotypes to be emitted.

Working on non-diploid data is of high interest for discovering somatic mutations, especially in the
case of cancer patients or mosaic individuals.

#### Structural variants

I believe that DeepVariant cannot be used for finding structural variants.

Indeed DeepVariants works because of the assumption that the mutations are local variations, this is
the case for small indels and SNPs, but is not a correct assumption for SVs.  
Furthermore in the classification step DeepVariant does not have information about the absolute
coordinates of the candidate variant in the genome, this information is critical for identifying and
localinzing SVs (translocations for example).

It is also the case that DeepVariant is highly dependant on its candidate emission step, which is
itself dependant on the alignment quality. Having a proper alignment in the case of SVs is actually
the problem that needs solving in SV calling. DeepVariant can thus by definition not be used for
this problem as it happens after that step (it is noteworthy that the authors never made claims
about SV calling).
