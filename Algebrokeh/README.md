# Algebrokeh.jl

Super simple statistical plotting, built on top of [Bokeh.jl](https://github.com/cjdoris/Bokeh.jl).

It provides a [AlgebraOfGraphics.jl](https://github.com/MakieOrg/AlgebraOfGraphics.jl)-style
interface to quickly construct complex layered plots with very little boilerplate.

## Example

```julia
using Bokeh, Algebrokeh

# (optional) Display the plot in the browser. Omit if you are in a notebook.
# (optional) Use the Algebrokeh default theme.
Bokeh.settings!(display="browser", theme="algebrokeh")

# The table of data to plot from.
data = Bokeh.Data.penguins()

# (optional) Convert the data table to a DataFrame and add labels to some of its columns.
# This will result in nicer labels automatically. If you don't do this, the field name
# (such as "bill_length_mm") is used as the label. You can specify a label in the plot with
# `x="@bill_length_mm"=>"Bill Length (mm)"`.
using DataFrames
data = DataFrame(data)
colmetadata!(data, :species, "label", "Species"; style=:note)
colmetadata!(data, :island, "label", "Island"; style=:note)
colmetadata!(data, :sex, "label", "Sex"; style=:note)
colmetadata!(data, :bill_length_mm, "label", "Bill Length (mm)"; style=:note)
colmetadata!(data, :bill_depth_mm, "label", "Bill Depth (mm)"; style=:note)

# Create a scatter plot. You can use any Bokeh glyph instead of `Scatter`. Named arguments
# whose value start with "@" map columns from the data to visual properties on the glyph.
# Use * to combine plots and + to layer them up.
plot(data, Scatter, x="@bill_length_mm", y="@bill_depth_mm") * (
  plot(color="@species", marker="@island", size=20, fill_alpha=0, line_width=3) +
  plot(color="@sex")
)
```

![Example plot](https://raw.githubusercontent.com/cjdoris/Bokeh.jl/main/Algebrokeh/example.png)
