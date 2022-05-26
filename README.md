# Bokeh.jl

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://cjdoris.github.io/Bokeh.jl/stable)
[![Dev Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://cjdoris.github.io/Bokeh.jl/dev)
[![Test Status](https://github.com/cjdoris/Bokeh.jl/workflows/Tests/badge.svg)](https://github.com/cjdoris/Bokeh.jl/actions?query=workflow%3ATests)
[![Docs Status](https://github.com/cjdoris/Bokeh.jl/workflows/Docs/badge.svg)](https://github.com/cjdoris/Bokeh.jl/actions?query=workflow%3ADocs)
[![Codecov](https://codecov.io/gh/cjdoris/Bokeh.jl/branch/main/graph/badge.svg?token=A813UUIHGS)](https://codecov.io/gh/cjdoris/Bokeh.jl)

[Julia](https://julialang.org/) bindings for the [Bokeh](https://bokeh.org/) plotting
library.

Although Bokeh is mainly a Python library, all the actual plotting happens in the browser
using [BokehJS](https://docs.bokeh.org/en/latest/docs/user_guide/bokehjs.html). This package
wraps BokehJS directly without using Python.

## 🎨 Example

Here is an example from [**the gallery**](https://cjdoris.github.io/Bokeh.jl/stable/gallery):

![Mandelbrot example](https://raw.githubusercontent.com/cjdoris/Bokeh.jl/main/mandelbrot.png)

## 📦 Install

```
pkg> add Bokeh
```

Then head over to [**the documentation**](https://cjdoris.github.io/Bokeh.jl).
