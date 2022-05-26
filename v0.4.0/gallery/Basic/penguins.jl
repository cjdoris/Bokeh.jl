using Bokeh, Tables

data = Bokeh.Data.penguins(columntable)

source = ColumnDataSource(data=data)

species = unique(data.species)

markers = ["hex", "circle_x", "triangle"]

p = figure(
    title = "Penguin Size",
    background_fill_color = "#fafafa",
)

plot!(p, Scatter,
    x="flipper_length_mm",
    y="body_mass_g",
    source=source,
    fill_alpha=0.4,
    size=12,
    marker=factor_mark("species", markers, species),
    color=factor_cmap("species", "Category10_3", species),
)

p

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

