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
Bokeh.display_in_browser()
```

Creating a plot generally consists of three steps:
1. Create an empty figure.
2. Add glyphs to the figure.
3. Display the figure.

```@example
using Bokeh
p = figure()
scatter!(p, x=randn(1000), y=randn(1000))
p
```

The final line causes the REPL or notebook you are using to display the plot `p`. You may
explicitly call `display(p)` instead, e.g. if you are plotting in a script or a loop.

If you are using `Bokeh.display_in_browser()` in the REPL, you may like to put `;` at the
end of each command to supress displaying it.
