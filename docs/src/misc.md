# Settings, Theming & Backends

```@docs
Bokeh.settings!
```

## [Theming](@id theming)

The appearance of a Bokeh plot comes from these sources, in order of precedence:
- A plot-specific theme, given by creating a [`Document`](@ref) with the specified theme.
- A global theme, given as the `theme` argument to [`Bokeh.settings!`](@ref).
- The display backend.
- Bokeh defaults.

```@docs
Bokeh.Theme
Bokeh.Document
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
[Blink.jl](https://github.com/JuliaGizmos/Blink.jl) window.

To activate this backend, do
```julia
using Bokeh, BokehBlink
Bokeh.settings!(display=:blink)
```

By default, plots are stretched to fill the window. You may override this by setting
`sizing_mode` on the top-level figure or in the theme for [`Figure`](@ref).

This package can also be used to export plots as images. You do not need to activate the
backend first.

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
