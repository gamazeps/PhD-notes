# Planing until the NIPS CFP

## Variant scoring algorithm

I am still convinced that the variant scoring algorithm (the classifier we talked about) is a good
contribution for a Machine Learning conference, however this does not free me from implementing
a full caller.

- Finish up the code for generating the training samples (1 week)
- Set up a tensorflow cluster on the new cluster (2-3 days): indeed TensorFlow offers a distributed
  support, but is notorius for being a pain to get up and running properly (work usable by all the
  group).
- Code the general framework we will use for training, evaluating and tuning the models (1 week)
- Choose the model and data representation (1 week synchronous, 3-5 weeks asynchronous): This part
  can either be very short or very long depending on how long it takes to train deep learning models
  on CPU, I know it would take a few days on GPU but I have found no information on the time needed
  with GPU (models as big as ours are usually trained on GPU).
- Evaluation of the state of the art (1 week): we need to tweak the usual tools so that they look
  at the same regions that we do in order to evaluate them fairly.
- Explore our results to look for bias, systemic failures/successes or any other results (1 week).
- Write a draft for NIPS (2 weeks): I am new to this task, but have had my structure and method
  checked by Machine Learning friends who deemed it good for this conference. They can also provide
  some help reviewing the paper before we submit it (from an ML perspective).

This leaves us with 8 weeks of synchronous work, and 10-12 weeks counting the asynchronous task of
training the models.

The output is:

- A software that given VCF for a set of individual can train an ML model to score variants
- A good publication at NIPS (A+ conference), this will probably not receive a prize, but I expect
  it to be in the best quartile of papers.

## Structural Variant caller

Once we have a good variant scoring algorithm we will need to integrate it in a variant caller that
does all that is expected of a variant caller, that is: BAM in, VCF out.

The implementation will probably be done in C++ as I hope to reuse code from other open source
variant callers (written in C/C++), with calls to python for the scoring part (python has a decent
FFI and the heavy lifting is done with blast).

- Candidate emission (1-2 weeks): integrate the code from PINDEL and tune it a bit with our method.
- Integrate the scoring algorithm (1 week): some crafty software engineering will be needed to have
  an efficient implementation of python with c/c++.
- Breakpoint location (1-2 weeks): some code can be reused from other variant callers (for the split
  read analysis).
- Variant merging (0-1 week): for overlapping calls, we need to merge them together (in the case of
  population).
- Documentation and publication (2 weeks):
  - Clean up dependencies and make it easily deployable.
  - Set up a website.
  - Write a good documentation.
  - Clean up the code.
  - Set up continuous integration and evaluation.
  - Clear up the conditions for making it open source and available.
  - Write blog posts and publicize on social media (where the bioinformatics comunity lives).

This leaves us with 6 weeks of work.

The output is:

- A usable SV caller using our variant scoring strategy.
- Code that can be discussed and evaluated in the community.
- Enough science and implementation to have a short paper if we want to.

We can later decide whether it is worthy of publication as a technical report or paper in a
bioinformatics journal or bioArXiv.

Writting the paper would probably take two weeks as all the science and implemenation efforts would
already be done.

## Cancer variant calling

I do not expect to have a sensible time table here as the problem and methods are yet to be defined.

We need to:

- Identify the sources of data
- Explore the data for unseen insights to be used (preferably biological ones).
- Translate the insights into a usable algorithm or statistical model. Indeed I am not convinced
  that machine learning will save us here, some good old fashioned algorithm design and statistics
  might be the key here.
- Learn some biology and chemistery on how the mutations appear, the data generated etc...
