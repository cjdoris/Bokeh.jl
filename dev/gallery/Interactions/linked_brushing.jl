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

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

