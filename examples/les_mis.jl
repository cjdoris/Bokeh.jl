### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 455fbcf2-3016-4148-af34-5e05e4f9381b
using Pkg; Pkg.activate("pluto", shared=true);

# ╔═╡ b572ba02-dbef-4878-a105-cc783833173a
using Bokeh, Bokeh.Tools, Downloads, JSON3

# ╔═╡ 674d5fb0-cded-11ec-0e12-a503d493eac3
md"""
# Les Misérables Co-occurrences

This example reproduces the plot from: [https://docs.bokeh.org/en/latest/docs/gallery/les_mis.html](https://docs.bokeh.org/en/latest/docs/gallery/les_mis.html)
"""

# ╔═╡ 47a11866-b294-4c60-b273-a0e9f21947b8
data_url = "https://cdn.jsdelivr.net/gh/bokeh/bokeh@2.4.2/bokeh/sampledata/_data/les_mis.json";

# ╔═╡ 7edf2296-bf92-48c5-b46c-e0878c9413a3
data = Downloads.download(data_url, IOBuffer()) |> seekstart |> JSON3.read;

# ╔═╡ 09a5985e-79d9-46fe-b038-a397a0d78ba7
names = [node.name for node in sort(data.nodes, by=x->x.group)];

# ╔═╡ 90176769-e154-4b38-91c7-3c621dfedafd
counts = Dict(
	(s ? (x.source, x.target) : (x.target, x.source)) => x.value
	for x in data.links
	for s in (true, false)
);

# ╔═╡ 36497e43-f6af-4924-9a51-0a4fec322013
colormap = ["#444444", "#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99",
            "#e31a1c", "#fdbf6f", "#ff7f00", "#cab2d6", "#6a3d9a"];

# ╔═╡ a20365bd-8d0b-4df4-a6a6-e7e330bd3d03
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
];

# ╔═╡ 6c89365d-7913-4887-8638-f84e6417589a
begin
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

	rect!(p,
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

	Document(p)
end

# ╔═╡ Cell order:
# ╟─674d5fb0-cded-11ec-0e12-a503d493eac3
# ╠═455fbcf2-3016-4148-af34-5e05e4f9381b
# ╠═b572ba02-dbef-4878-a105-cc783833173a
# ╠═47a11866-b294-4c60-b273-a0e9f21947b8
# ╠═7edf2296-bf92-48c5-b46c-e0878c9413a3
# ╠═09a5985e-79d9-46fe-b038-a397a0d78ba7
# ╠═90176769-e154-4b38-91c7-3c621dfedafd
# ╠═36497e43-f6af-4924-9a51-0a4fec322013
# ╠═a20365bd-8d0b-4df4-a6a6-e7e330bd3d03
# ╠═6c89365d-7913-4887-8638-f84e6417589a
