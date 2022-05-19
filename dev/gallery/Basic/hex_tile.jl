using Bokeh

n = 50_000
size = 0.1

x = randn(n)
y = randn(n)

bins = Bokeh.hexbin(x, y; size)

p = figure(
    title = "Manual hax bin for $n points",
    tools = [WheelZoomTool(), PanTool(), ResetTool()],
    match_aspect = true,
    background_fill_color = "#440154",
)

p.grids.visible = false

plot!(p, HexTile;
    q="q",
    r="r",
    size,
    line_color=nothing,
    source=bins,
    fill_color=linear_cmap("count", "Viridis256"; low=0),
)

p

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

