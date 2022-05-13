# Penguins (`scatter!`, `factor_mark`, `factor_cmap`)

Reproduces the plot from [https://docs.bokeh.org/en/latest/docs/gallery/marker_map.html](https://docs.bokeh.org/en/latest/docs/gallery/marker_map.html).

```@example
using Bokeh, Tables

data = Bokeh.Data.penguins(columntable)

source = ColumnDataSource(data=data)

species = unique(data.species)

markers = ["hex", "circle_x", "triangle"]

plot = figure(
    title = "Penguin Size",
    background_fill_color = "#fafafa",
)

scatter!(plot,
    x="flipper_length_mm",
    y="body_mass_g",
    source=source,
    fill_alpha=0.4,
    size=12,
    marker=factor_mark("species", markers, species),
    color=factor_cmap("species", "Category10_3", species),
)

plot
```
