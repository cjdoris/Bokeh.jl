# ---
# title: Linked properties
# id: js_link
# description: Links a glyph size to a slider widget.
# #cover: ../assets/heatmap.png
# ---

# Demonstrates using [`js_link`](@ref) to use a slider widget to control the size of a glyph.
# 
# Reproduces the plot from [https://docs.bokeh.org/en/2.4.2/docs/user_guide/interaction/linking.html#linked-properties](https://docs.bokeh.org/en/2.4.2/docs/user_guide/interaction/linking.html#linked-properties).

using Bokeh

p = figure(width=400, height=400)
r = plot!(p, Circle; x=[1,2,3,4,5], y=[3,2,5,6,4], radius=0.2, alpha=0.5)

slider = Slider(start=0.1, end_=2, step=0.01, value=0.2)
js_link(slider, "value", r.glyph, "radius")

column(p, slider)
