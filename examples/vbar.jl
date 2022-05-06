### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 2c4f4270-cc4e-11ec-0e14-3baff984e3a2
using Pkg; Pkg.activate("pluto", shared=true);

# ╔═╡ f40343e0-31e1-4c54-9b8b-716dca054fa9
using Bokeh

# ╔═╡ f26563d9-0865-43fb-9dce-6449c7f331bf
md"""
# Bar Charts

This example reproduces the plot from: [https://docs.bokeh.org/en/latest/docs/gallery/bar_colormapped.html](https://docs.bokeh.org/en/latest/docs/gallery/bar_colormapped.html)
"""

# ╔═╡ 68ac3560-cd33-461f-a531-7d92258b84e1
data = (
	fruits = ["Apples", "Pears", "Nectarines", "Plums", "Grapes", "Strawberries"],
	counts = [5, 3, 4, 2, 4, 6],
)

# ╔═╡ 1035c887-f382-4e51-be62-be8e12058e46
begin
	p = figure(
		x_range=data.fruits,
		height=350,
		toolbar_location=nothing,
		title="Fruit Counts",
	)
	vbar!(p,
		x="fruits",
		top="counts",
		source=data,
		width=0.9,
		# TODO legend_field="fruits",
       	line_color="white",
		fill_color=factor_cmap("fruits", "Spectral6", data.fruits),
	)
	p.x_grid.grid_line_color = nothing
	p.y_range.start = 0
	p.y_range.end = 9
	# TODO p.legend_field.orientation = "horizontal"
	# TODO p.legend.location = "top_center"
	Document(p)
end

# ╔═╡ Cell order:
# ╟─f26563d9-0865-43fb-9dce-6449c7f331bf
# ╠═2c4f4270-cc4e-11ec-0e14-3baff984e3a2
# ╠═f40343e0-31e1-4c54-9b8b-716dca054fa9
# ╠═68ac3560-cd33-461f-a531-7d92258b84e1
# ╠═1035c887-f382-4e51-be62-be8e12058e46
