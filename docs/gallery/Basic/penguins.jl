# ---
# title: Penguins
# id: demo_penguins
# description: Uses `Scatter`, `factor_mark` and `factor_cmap`.
# cover: ../assets/penguins.png
# ---

# Reproduces the plot from [https://docs.bokeh.org/en/latest/docs/gallery/marker_map.html](https://docs.bokeh.org/en/latest/docs/gallery/marker_map.html).

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
