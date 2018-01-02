# Back propagation

## Notation

We consider a neural network as a series of layers and activation functions.

Each layer will be described as layer l, with layer 0 being the input.

For each layer we will have the following:

- $$z^{l-1}$$: input vector of layer l
- $\theta^{l}$: parameters of layer l
- $z^{l}$: output vector of layer l

We will also denote:

- X as an input vector with its associated true value Y
- $\widetilde{Y}$ prediction of the network for input X
- $\mathcal{L}(Y, \widetilde{Y})$: the loss function, mesauring the distance between the prediction
  and the true value.

## Objective

### Optimization

When we have a neural network described with a set of parameters, our objective is to solve the
optimization problem:

$\underset{\theta}{\operatorname{argmin}} \mathcal{L(Y, \widetilde{Y})}$

Two solutions are possible:

- Finding the optimal solution in a symbolic way.
- Use gradient based solutions to find the optimal value.

A problem with the optimal solution is that it often requires to inverse huges matrices (self
product of the input X), which is not always possible as it would not fit into memory.

Furthermore, with more complex networks with many nonlinearities finding a symbolic solution can be
a very hard and error prone operation. It is also noteworthy that it requires solving the equation
for each new network. A solution can also be hard to find as loss functions tend to not be convex.

This is why gradient based approaches are usually chosen.

### Computing the gradient

Since we chose gradient based approach we now need to compute the gradient of the loss function
relative to each parameters.

For that we can try to derive it directly from the expression of the loss function, but the problem
can quickly become intractable with fancy networks which have dropout, ReLUs or max-pooling.

We will hence take advantage of the structure of the network and its computation graph to compute
gradients by using the chain rule.

The chain rule is the following:

$\frac{\partial {f}}{\partial {x}} = \frac{\partial {f}}{\partial {y}} . \frac{\partial {y}}{\partial {x}}$ 

Using the notation introduced above we have the following relationship:

$\frac{\partial{\mathcal{L}}}{\partial{\theta^{l}}} = \frac{\partial{\mathcal{L}}}{\partial{z^{l}}} . \frac{\partial{z^{L}}}{\partial{\theta^{l}}}$

We can compute $\frac{\partial{z^{L}}}{\partial{\theta^{l}}}$ locally.

We will nevertheless need to have $\frac{\partial{\mathcal{L}}}{\partial{z^{l}}}$ but if we also
compute $\frac{\partial{z^{l}}}{\partial{z^{l-1}}}$ for each layer l, we can derive it by applying the
chain rule once again.

Thus for each layer we localy compute:

- $\frac{\partial{z^{l}}}{\partial{z^{l-1}}}$
- $\frac{\partial{z^{l}}}{\partial{\theta^{l}}}$
 
Which given $\frac{\partial{\mathcal{L}}}{\partial{z^{l}}}$ allows us to compute:

- $\frac{\partial{\mathcal{L}}}{\partial{\theta^{l}}}$
- $\frac{\partial{\mathcal{L}}}{\partial{z^{l-1}}}$

And we thus have computed the partial derivative relative to $\theta^l$ and can then go on to compute
the derivatives for layer l-1
