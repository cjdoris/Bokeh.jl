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

To activate this backend, do
```julia
using Bokeh, BokehBlink
Bokeh.settings!(display=:blink)
```

This package can also be used to export plots as images.

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
