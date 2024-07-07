using Bokeh, Tables

data = Bokeh.Data.les_mis(rowtable)

names = [node.name for node in sort(data.nodes, by=x->x.group)]

counts = Dict(
    (s ? (x.source, x.target) : (x.target, x.source)) => x.value
    for x in data.links
    for s in (true, false)
)

colormap = ["#444444", "#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99",
            "#e31a1c", "#fdbf6f", "#ff7f00", "#cab2d6", "#6a3d9a"]

pairdata = [
    (
        xname = node1.name,
        yname = node2.name,
        alpha = min(get(counts, (i1 - 1, i2 - 1), 0) / 4, 0.9) + 0.1,
        color = node1.group == node2.group ? colormap[node1.group + 1] : "lightgrey",
        count = get(counts, (i1 - 1, i2 - 1), 0),
    )
    for (i1, node1) in enumerate(data.nodes)
    for (i2, node2) in enumerate(data.nodes)
]

p = figure(
    title="Les Mis Occurrences",
    x_axis_location="above",
    x_range=reverse(names),
    y_range=names,
    tools=[SaveTool()],
    tooltips = [("names", "@yname, @xname"), ("count", "@count")],
    width = 800,
    height = 800,
)

p.grids.grid_line_color = nothing
p.axes.axis_line_color = nothing
p.axes.major_tick_line_color = nothing
p.axes.major_label_text_font_size = "7px"
p.axes.major_label_standoff = 0
p.x_axis.major_label_orientation = π/3

plot!(p, Rect,
    x="xname",
    y="yname",
    width=0.9,
    height=0.9,
    source=pairdata,
    color="color",
    alpha="alpha",
    line_color=nothing,
    # hover_color="colors", TODO
    # hover_line_color="black", TODO
)

p

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
