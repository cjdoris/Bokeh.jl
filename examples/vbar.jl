### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 2c4f4270-cc4e-11ec-0e14-3baff984e3a2
using Pkg; Pkg.activate("pluto", shared=true);

# ╔═╡ f40343e0-31e1-4c54-9b8b-716dca054fa9
using Bokeh

# ╔═╡ e21bd15a-c6dc-41e7-a4b0-5098950ca318
fruits = ["Apples", "Pears", "Nectarines", "Plums", "Grapes", "Strawberries"];

# ╔═╡ ec37bb66-6898-41e1-a4fa-66c23d935015
counts = [5, 3, 4, 2, 4, 6];

# ╔═╡ feea3661-a4e5-4096-b113-2a25b55c813f
source = ColumnDataSource(data=(fruits=fruits, counts=counts));

# ╔═╡ 1035c887-f382-4e51-be62-be8e12058e46
begin
	p = figure(
		x_range=fruits,
		height=350,
		toolbar_location=nothing,
		title="Fruit Counts",
	)
	vbar!(p, source,
		x="fruits",
		top="counts",
		width=0.9,
		# TODO legend_field="fruits",
       	line_color="white",
		fill_color=factor_cmap("fruits", "Spectral6", fruits),
	)
	p.center[1].grid_line_color = nothing # TODO p.xgrid.grid_line_color = nothing
	p.y_range.start = 0
	p.y_range.end = 9
	# TODO p.legend_field.orientation = "horizontal"
	# TODO p.legend.location = "top_center"
	Document(p)
end

# ╔═╡ Cell order:
# ╠═2c4f4270-cc4e-11ec-0e14-3baff984e3a2
# ╠═f40343e0-31e1-4c54-9b8b-716dca054fa9
# ╠═e21bd15a-c6dc-41e7-a4b0-5098950ca318
# ╠═ec37bb66-6898-41e1-a4fa-66c23d935015
# ╠═feea3661-a4e5-4096-b113-2a25b55c813f
# ╠═1035c887-f382-4e51-be62-be8e12058e46
