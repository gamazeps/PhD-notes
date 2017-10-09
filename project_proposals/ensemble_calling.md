# Ensemble methods for Structural variant calling
------------------------------------------------

As the Lin et al. paper mentions, there are currently a few big issues
in structural variant calling pipelines.

A rough summary would be:

-   No golden standard.
-   Many tools, good at different types of SV calling (often find non
    overlapping variants).
-   Poor unifcation of pipelines (there were 4 pipelines integrating
    different tools at that time though).
-   Results of different tools are merged in a very much `ad hoc` way.

What we can do here
-------------------

The first two problems mentionned represent a lot of work and inovation
in order to provide a better caller, I belive this is where our deep
learning approach may prove successful.

The third problem is more of an engineering problem than a research one
according to what I understand of research, and may not be publication
worthy as such (Avinash, your input would be interesting here as you
have already published in Bioinformatics).

On the other hand, the merging phase is in my opinion both doable in a
reasonable amount of time, publishable (once again Avinash's input would
be interesting here) and useful for the rest of the PhD.

Merging callers
---------------

Only four methods have been referenced as using mutiple callers and
merging their results:

-   SVMerge
-   HugeSeq
-   InstanSV
-   iSVP

*Note*: It is interesting to note that they all use BreakDancer for RPs
and Pindel for (SR+RP) which is a strong statement to the quality of
these two callers.

The merging strategies are usually a combination of the following:

-   Union over all the calls (lots of false positives).
-   Selecting variants called by at least two callers.
-   Blindly trusting some callers even if the others disagree.

This fusion of candidates feels rather unsatisfying as it is not backed
by strong statistical evidence.

Lin et al. made a call to machine learning people to build a merging
strategy that would be able to have varying levels of confidence in
callers depending on their calls (as some are more fine tuned for
specific types of variants and poor for other types).

Such a system could be done by investigating various methods:

-   (shallow) Neural Network, as they are able to give more weight to
    some signals for some classes.
-   Ensemble, stacking, boosting and voting strategies used in other
    areas of science.
-   Sensor fusion, such as Kalman filters.

Project description
-------------------

Investigating these three methods would require us to also build an
evaluation tool for structural variant caling, which is not exactly done
for now to the best of my knowledge (each caller is evaluated on the
specific type of variants it is optimized for).

An evaluation of SV callers on a unique dataset (such as na27128 or 1k
genome) with all types of variants evaluated in it would be an
interesting contribution in my opinion.

Furthermore, building such an evaluation strategy with benchmarks would
be useful if we decide to work further on SV calling as we will need it
to evaluate our algorithms.

Once such an evaluation strategy has been built, training a neural
network to optimaly merge the signals would be an easy task.

Work to be done
---------------

-   Identify a quality annotated dataset for SV calling.
-   Run the most common pipelines and callers on that single dataset.
-   Compute a single digit metric that can be used as an
    optimization target.
-   Investigate merging strategies.
-   Write a paper.

The first three parts could be done in parallel of my training period,
and should be doable in a 1.5 months period (done part time) if all goes
well. The investigation should be doable in less than a month and the
paper could be doable in a few weeks (as we would already have run the
experiences).

Project impact
--------------

I believe that such a project has the following pros:

-   Potentially publishable result in Bioinformatics or PLOS.
-   Set up an evaluation strategy that can be used for further work.
-   Have first hand experience with the various callers, this would help
    understand their insights, drawbacks, assumptions and limitations,
    if we want to beat them we need to know them.
-   Arise interest in the problem of SV callers (before hopefuly
    bringing new results to this area ourselve).
-   Good follow-up on the training phase, as a researcher I will need to
    learn how to write papers.
-   Give us a deep understanding on the state of the art of SV calling.
-   Having a metric and an evaluation of each callers and pipelines
    would allow to make the marginal gains of using more callers
    explicit, and thus allow to chose which callers to used and which
    not to use together (by adding a correlation matrix ofr example),
    thus lowering the computational cost for genome centers (by using
    less callers).

References
----------

Lin, Ke, Sandra Smit, Guusje Bonnema, Gabino Sanchez-Perez, and Dick de
Ridder. “Making the Difference: Integrating Structural Variation
Detection Tools.” Briefings in Bioinformatics 16, no. 5 (September
2015): 852–64. doi:10.1093/bib/bbu047.

Rausch, Tobias, Thomas Zichner, Andreas Schlattl, Adrian M. Stütz,
Vladimir Benes, and Jan O. Korbel. “DELLY: Structural Variant Discovery
by Integrated Paired-End and Split-Read Analysis.” Bioinformatics
(Oxford, England) 28, no. 18 (September 15, 2012): i333–39.
doi:10.1093/bioinformatics/bts378.

Ye, Kai, Marcel H. Schulz, Quan Long, Rolf Apweiler, and Zemin Ning.
“Pindel: A Pattern Growth Approach to Detect Break Points of Large
Deletions and Medium Sized Insertions from Paired-End Short Reads.”
Bioinformatics (Oxford, England) 25, no. 21 (November 1, 2009): 2865–71.
doi:10.1093/bioinformatics/btp394.

Chen, Ken, John W. Wallis, Michael D. McLellan, David E. Larson, Joelle
M. Kalicki, Craig S. Pohl, Sean D. McGrath, et al. “BreakDancer: An
Algorithm for High-Resolution Mapping of Genomic Structural Variation.”
Nature Methods 6, no. 9 (September 2009): 677–81.
doi:10.1038/nmeth.1363.

Wong, Kim, Thomas M. Keane, James Stalker, and David J. Adams. “Enhanced
Structural Variant and Breakpoint Detection Using SVMerge by Integration
of Multiple Detection Methods and Local Assembly.” Genome Biology 11
(December 31, 2010): R128. doi:10.1186/gb-2010-11-12-r128.

Lam, Hugo Y. K., Cuiping Pan, Michael J. Clark, Phil Lacroute, Rui Chen,
Rajini Haraksingh, Maeve O’Huallachain, et al. “Detecting and Annotating
Genetic Variations Using the HugeSeq Pipeline.” Nature Biotechnology 30,
no. 3 (March 7, 2012): 226–29. doi:10.1038/nbt.2134.

Mimori, Takahiro, Naoki Nariai, Kaname Kojima, Mamoru Takahashi, Akira
Ono, Yukuto Sato, Yumi Yamaguchi-Kabata, and Masao Nagasaki. “ISVP: An
Integrated Structural Variant Calling Pipeline from High-Throughput
Sequencing Data.” BMC Systems Biology 7, no. 6 (December 13, 2013): S8.
doi:10.1186/1752-0509-7-S6-S8.

“Intansv: Integrative Analysis of Structural Variations Version 1.14.0
from Bioconductor.” Accessed October 9, 2017.
https://rdrr.io/bioc/intansv/.
