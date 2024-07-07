using Bokeh, DataFrames, Statistics

df = Bokeh.Data.autompg_clean(DataFrame)

agg = combine(
	groupby(df, ["cyl", "mfr"]),
	[
		["cyl","mfr"] => ((x,y)->(string(x[1]),y[1])) => "cyl_mfr",
		"mpg" => mean => "mpg_mean",
	]
)

p = figure(
	width=800,
	height=300,
	title="Mean MPG by # Cylinders and Manufacturer",
    x_range=sort(agg.cyl_mfr),
	toolbar_location=nothing,
	tooltips=[("MPG", "@mpg_mean"), ("Cyl, Mfr", "@cyl_mfr")],
)

plot!(p, VBar,
	x="cyl_mfr",
	top="mpg_mean",
	width=1,
	source=agg,
	line_color="white",
	fill_color=factor_cmap("cyl_mfr", "Spectral5", string.(sort(unique(agg.cyl))); :end=>1),
)

p.y_range.start = 0
p.x_range.range_padding = 0.05
p.x_grid.grid_line_color = nothing
p.x_axis.axis_label = "Manufacturer grouped by # Cylinders"
p.x_axis.major_label_orientation = 1.2
p.outline_line_color = nothing

p

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
