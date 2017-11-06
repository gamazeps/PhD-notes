# DeepSV (name to improve)

This white paper describes the algorithm to be used for detecting structural variants using the
insights given to us by DeepVariant.

## Brief overview

The algorithms has two phases, training and prediction.

As with many deep learning algorithms, the training only has to be done once, and then we can
predict.

Here is a brief overview of the prediction phase:

- 1. input fastq files
- 2. alignment and preprocessing (following GATK best practices).
- 3. generate candidate SV location based on PEM
- 4. take all read pairs with one read around that location
- 5. local reassembly
- 6. classification into SV or nonSV

The training phase will be the same as the prediction phase except that there will be a coefficient
update after the prediction (based on backpropagation).

## Training and testing data

The training and testing data that will be used is the 1000 genome project phase 3 structural
variant data.

| SV Class  | No. variants |
|-----------|--------------|
|deletion   | 42.279       |
|duplication| 6.025        |
|mCNV       | 2.929        |
|Inversion  | 786          |
|MEI        | 16.631       |
|NUMT       | 168          |

We will also need data for non SV data, for that we may use the strategy from svclassify and
randomly sample locations from the reference genome as variants are rare (this can be improved by
using regions where the alignment is almost perfect with just a few SNPs).

## Candidate emission

Here we will follow aplly a preprocessing similar to that of PINDEL, DELLY and BreakDancer:

- Allign the reads (aligner will probably be BWA, but no reason to commit here).
- Apply markduplicate and other steps as needed (To be determined).

We will then use an idea from DELLY here and follow this (inefficient) pseudocode

```python
def emit_candidates(reads, reference):
    aligned_reads = align(reads, reference)
    filtered_read = gatk_filter(reads, reference)

    candidates = defaultdict(list)
    for read in filtered_read:
        if pair_anomaly(read.first, read.second):
            candidates[anomaly_type(read)].append(read)

    # To be properly implemented with an index
    unified_candidates = group_supporting_reads(candidates)
    return unified_candidates


def group_supporting_reads(reads):
    """
    Put reads together that:
        - support the same type of anomaly
        - overlap in some manner

    This is basically the idea of building a union-find for reads supporting the same type of
    anomaly that overlap at some point.
    """
    pass

def pair_anomaly(read):
    """
    Uses conditions copied from delly:
        - If the distance between them is too small.
        - If the distance between them is too big.
        - If the order of the orientation is inversed.
        - If they have the same orientation.
    """
    pass
```

Once we have emmited the reads supporting a candidate variant we locally reassemble them.

## Prediction

Once we have a group of aligned reads supporting a possible variant, we generate a pileup image (see
deepvariant).

The actual size of that image will have to be determined, as most models need fixed sized images and
downsampling this image does not make any sense.

This part will have to be empirically tested (should we use a fixed size on the refernce or the
reads).

We then feed this image to a classifier to be determined.

Here we will probably want to convolutional neural network to detect local patterns (just like
DeepVariant). The most likely type is an inceptionv2 pretrained on imageNet (or the one from
DeepVariant if it is opensourced by then) and retrain the FC layer (and go as far as we can
afterwards).

## Motivation

This algorithm did not appear out of thin air, here are the inspirations it took:

- Using Anormal Read Pairs (ARP) is what Read Pairs and Soft Reads analysis is, and is the analysis
  method used in *all* recent variant callers (exluding assembly only ones, which are neither
  common nor successful). BreakDancer (part of the state of the art) even only uses the distribution
  of ARPs for calling variants.
- Aligning reads in an image (or other 2D representation) has proven succesful in DeepVariant,
  DeepBind and DeepMotif (the last two were recently publised in *Bioinformatics*).
- Grouping reads supporting the same variant is done in DELLY and BreakDancer to a great success.

## Drawbacks

This method suffers from the following drawbacks:

- This method does not have a way to localise breakpoints precisely, it can just say that there is a
  brakpoint around the candidate location.
- The way to chose the size of the window is not defined and this is most likely a very important
  factor.

## References

Alipanahi, Babak, Andrew Delong, Matthew T. Weirauch, and Brendan J. Frey. “Predicting the Sequence
Specificities of DNA- and RNA-Binding Proteins by Deep Learning.” Nature Biotechnology 33, no. 8
(August 2015): 831–38. https://doi.org/10.1038/nbt.3300.

Chen, Ken, John W. Wallis, Michael D. McLellan, David E. Larson, Joelle M. Kalicki, Craig S. Pohl,
Sean D. McGrath, et al. “BreakDancer: An Algorithm for High Resolution Mapping of Genomic Structural
Variation.” Nature Methods 6, no. 9 (September 2009): 677–81. https://doi.org/10.1038/nmeth.1363.

Lanchantin, Jack, Ritambhara Singh, Zeming Lin, and Yanjun Qi. “Deep Motif: Visualizing Genomic
Sequence Classifications.” ArXiv:1605.01133 [Cs], May 3, 2016. http://arxiv.org/abs/1605.01133.

Lanchantin, Jack, Ritambhara Singh, Beilun Wang, and Yanjun Qi. “Deep Motif Dashboard: Visualizing
and Understanding Genomic Sequences Using Deep Neural Networks.” ArXiv:1608.03644 [Cs], August 11,
2016. http://arxiv.org/abs/1608.03644.

Parikh, Hemang, Hariharan Iyer, Desu Chen, Mark Pratt, Gabor Bartha, Noah Spies, Wolfgang Losert,
Justin M. Zook, and Marc L. Salit. “Svclassify: A Method to Establish Benchmark Structural Variant
Calls.” BioRxiv, May 22, 2015, 019372. https://doi.org/10.1101/019372.

Poplin, Ryan, Dan Newburger, Jojo Dijamco, Nam Nguyen, Dion Loy, Sam Gross, Cory Y. McLean, and Mark
DePristo. “Creating a Universal SNP and Small Indel Variant Caller with Deep Neural Networks.”
BioRxiv, December 14, 2016, 092890. https://doi.org/10.1101/092890.

Rausch, Tobias, Thomas Zichner, Andreas Schlattl, Adrian M. Stütz, Vladimir Benes, and Jan O.
Korbel. “DELLY: Structural Variant Discovery by Integrated Paired-End and Split-Read Analysis.”
Bioinformatics (Oxford, England) 28, no. 18 (September 15, 2012): i333–39.
https://doi.org/10.1093/bioinformatics/bts378.

Sudmant, Peter H., Tobias Rausch, Eugene J. Gardner, Robert E. Handsaker, Alexej Abyzov, John
Huddleston, Yan Zhang, et al. “An Integrated Map of Structural Variation in 2,504 Human Genomes.”
Nature 526, no. 7571 (October 1, 2015): 75–81. https://doi.org/10.1038/nature15394.

Ye, Kai, Marcel H. Schulz, Quan Long, Rolf Apweiler, and Zemin Ning. “Pindel: A Pattern Growth
Approach to Detect Break Points of Large Deletions and Medium Sized Insertions from Paired-End Short
Reads.” Bioinformatics (Oxford, England) 25, no. 21 (November 1, 2009): 2865–71.
https://doi.org/10.1093/bioinformatics/btp394.
