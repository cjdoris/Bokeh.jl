# Bokeh.jl

## Overview

[Bokeh.jl](https://github.com/cjdoris/Bokeh.jl) is a [Julia](https://julialang.org/)
front-end for the [Bokeh](https://bokeh.org/) plotting library. Bokeh makes it simple to
create interactive plots like this:

```@example
using Bokeh
n = 2_000
z = rand(1:3, n)
x = randn(n) .+ [-2, 0, 2][z]
y = randn(n) .+ [-1, 3, -1][z]
color = Bokeh.PALETTES["Julia3"][z]
p = figure(title="Julia Logo")
plot!(p, Scatter; x, y, color, alpha=0.4, size=10)
p
```

## How it works

Although Bokeh is mainly a Python library, all the actual plotting happens in the browser
using [BokehJS](https://docs.bokeh.org/en/latest/docs/user_guide/bokehjs.html). This package
wraps BokehJS directly without using Python.
