### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 1818e1e1-2c9d-43c0-806b-4df10be823dc
using Pkg; Pkg.activate("pluto", shared=true)

# ╔═╡ 8f2973ce-c8bf-11ec-03c0-b35d204ecc67
using Bokeh, PalmerPenguins

# ╔═╡ fd486148-e2c1-4e71-b735-51c32005b61b
md"""
# Penguins

This example recreates the plot from:
[https://docs.bokeh.org/en/latest/docs/gallery/marker_map.html](https://docs.bokeh.org/en/latest/docs/gallery/marker_map.html)
"""

# ╔═╡ 0b50fae2-4cb0-45c5-89d7-a2520b7d90e5
data = PalmerPenguins.load();

# ╔═╡ d177dd54-c9d2-4021-979f-f7b76b9e803c
begin
	# prepare the data
	source = ColumnDataSource(data=PalmerPenguins.load())
	species = unique(data["species"])
	markers = ["hex", "circle_x", "triangle"]
	# create an empty plot
	plot = figure(
		title = "Penguin Size",
		background_fill_color = "#fafafa",
	)
	# add marks
	scatter!(plot,
		x="flipper_length_mm",
		y="body_mass_g",
		source=source,
		fill_alpha=0.4,
		size=12,
		marker=factor_mark("species", markers, species),
		color=factor_cmap("species", "Category10_3", species),
	)
	# display it by wrapping into a document
	Document(plot)
end

# ╔═╡ Cell order:
# ╟─fd486148-e2c1-4e71-b735-51c32005b61b
# ╠═1818e1e1-2c9d-43c0-806b-4df10be823dc
# ╠═8f2973ce-c8bf-11ec-03c0-b35d204ecc67
# ╠═0b50fae2-4cb0-45c5-89d7-a2520b7d90e5
# ╠═d177dd54-c9d2-4021-979f-f7b76b9e803c
