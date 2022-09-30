# ---
# title: Linked Brushing
# id: linked_brushing
# description: Sharing data sources to link brushing.
# cover: ../assets/linked_brushing.png
# ---

# By using the same data source in multiple plots, actions performed on glyphs in one plot
# are shared between corresponding glyphs of another plot.
#
# Try out the selection tools in this example. The selected glyphs in each plot are
# automatically synchronised.
# 
# Reproduces the plot from [https://docs.bokeh.org/en/2.4.2/docs/user\_guide/interaction/linking.html#linked-brushing](https://docs.bokeh.org/en/2.4.2/docs/user_guide/interaction/linking.html#linked-brushing).

using Bokeh

x = -20:20
y0 = [abs(xx) for xx in x]
y1 = [xx^2 for xx in x]

source = ColumnDataSource(data=(; x, y0, y1))

tools = [BoxSelectTool(), LassoSelectTool(), HelpTool()]

left = figure(; tools, title=nothing)
plot!(left, Scatter; x="x", y="y0", source)

right = figure(; tools, title=nothing)
plot!(right, Scatter; x="x", y="y1", source)

grid([left right], merge_tools=true, item_width=300, item_height=300)
