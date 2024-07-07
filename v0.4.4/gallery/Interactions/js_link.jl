using Bokeh

p = figure(width=400, height=400)
r = plot!(p, Circle; x=[1,2,3,4,5], y=[3,2,5,6,4], radius=0.2, alpha=0.5)

slider = Slider(start=0.1, end_=2, step=0.01, value=0.2)
js_link(slider, "value", r.glyph, "radius")

column(p, slider)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
