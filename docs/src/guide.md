# User Guide

## Installation

In Julia, press `]` to enter the Pkg REPL and do
```julia-repl
pkg> add Bokeh
```

## Create your first plot

You will need to use Pluto, Jupyter, or some other environment capable of displaying HTML.

Creating a plot generally consists of three steps:
1. Create an empty figure.
2. Add glyphs to the figure.
3. Display the figure by wrapping it as a `Document`.

```@example
p = figure()
scatter!(p, x=rand(100), y=rand(100))
Document(p)
```

A `Document` is displayable as HTML, so returning it from a notebook cell will render it
for you. You may instead `display` the document.
