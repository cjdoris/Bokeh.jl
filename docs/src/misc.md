# Settings & Backends

```@docs
Bokeh.settings!
```

## [Display Backends](@id display_backends)

Plots can automatically be displayed anywhere supporting HTML output, such as a Pluto or
Jupyter notebook. Anywhere else, such as the Julia REPL, will require a display backend to
be activated.

### Browser

To display plots in your default browser, set
```julia
Bokeh.settings!(display=:browser)
```

### Blink

The `BokehBlink` package can be separately installed to enable plotting into a standalone
[`Blink.jl`](https://github.com/JuliaGizmos/Blink.jl) window.

This package is currently experimental and unregistered. You can install it like so:
```julia
using Pkg
Pkg.add(url="https://github.com/cjdoris/Bokeh.jl")
Pkg.add(url="https://github.com/cjdoris/Bokeh.jl", subdir="BokehBlink")
```

To activate this backend, do
```julia
using Bokeh, BokehBlink
Bokeh.settings!(display=:blink)
```

```@docs
BokehBlink.save
```

### Null

The null backend cannot display anything. It is the default backend. Use it to deactivate
another backend:
```julia
Bokeh.settings!(display=:null)
```

## Interactive Backends

🚧 Coming soon! 🚧
