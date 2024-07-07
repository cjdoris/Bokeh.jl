using Bokeh

data = [
    Float32(sin(x)*cos(y))
    for x in range(0, 10, length=500),
        y in range(0, 10, length=500)
]

p = figure(
    tooltips=[("x", "\$x"), ("y", "\$y"), ("value", "@image")]
)

p.ranges.range_padding = 0
p.grids.grid_line_width = 0

plot!(p, Image, image=[data], x=0, y=0, dw=10, dh=10, level="image", palette="Spectral11")

p

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
