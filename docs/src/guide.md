# User Guide

## Installation

In Julia, press `]` to enter the Pkg REPL and do
```julia-repl
pkg> add Bokeh
```

## Create your first plot

You will need to use Pluto, Jupyter, or any other environment capable of displaying HTML.

Alternatively, you can display straight to the browser from the REPL by calling
```julia
using Bokeh
Bokeh.settings!(use_browser=true)
```

Creating a plot generally consists of three steps:
1. Create an empty figure using [`figure`](@ref).
2. Add glyphs to the figure using [`plot!`](@ref).
3. Display the figure.

```@example
using Bokeh
p = figure()
plot!(p, Scatter, x=randn(1000), y=randn(1000))
p
```

The final line causes the REPL or notebook you are using to display the plot `p`. You may
explicitly call `display(p)` instead, e.g. if you are plotting in a script or a loop.

If you are using `use_browser=true` in the REPL, you may like to put `;` at the end of each
command to supress displaying it.

## Getting help

Aside from this documentation, you can access extensive documentation from your Julia
session.

If you are at the REPL, you can use the help mode to find out about Bokeh functions,
models and properties. For example, to learn more about the [`Scatter`](@ref) model used
above, press `?` then do
```text
help?> Scatter
search: Scatter AbstractPattern BasicTickFormatter ScientificFormatter

  Bokeh model type Scatter.

  Render scatter markers selected from a predefined list of designs.

[...]
```

This mentions the property `marker`, which we can find out about with
```text
help?> Scatter.marker
  Bokeh model property Scatter.marker.

  Which marker to render. This can be the name of any built in marker, e.g. "circle", or a
  reference to a data column containing such names.
```

If you are not at the REPL, the `Docs.doc` function can be used to access model
documentation:
```julia
Docs.doc(Scatter)
Docs.doc(Scatter, :size)
```
