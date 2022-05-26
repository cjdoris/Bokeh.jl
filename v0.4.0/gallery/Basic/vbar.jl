using Bokeh

data = (
    fruits = ["Apples", "Pears", "Nectarines", "Plums", "Grapes", "Strawberries"],
    counts = [5, 3, 4, 2, 4, 6],
)

p = figure(
    x_range=data.fruits,
    height=350,
    toolbar_location=nothing,
    title="Fruit Counts",
)

plot!(p, VBar,
    x="fruits",
    top="counts",
    source=data,
    width=0.9,
    legend_field="fruits",
    line_color="white",
    fill_color=factor_cmap("fruits", "Spectral6", data.fruits),
)

p.x_grid.grid_line_color = nothing
p.y_range.start = 0
p.y_range.end = 9
p.legend.orientation = "horizontal"
p.legend.location = "top_center"

p

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

