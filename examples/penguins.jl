### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 1818e1e1-2c9d-43c0-806b-4df10be823dc
using Pkg; Pkg.activate("pluto", shared=true)

# ╔═╡ 8f2973ce-c8bf-11ec-03c0-b35d204ecc67
using Bokeh, PalmerPenguins, Tables

# ╔═╡ 9a9162a9-c1ef-451f-af32-930db032f2dc
df = Tables.dictcolumntable(PalmerPenguins.load());

# ╔═╡ d177dd54-c9d2-4021-979f-f7b76b9e803c
begin
	# prepare the data
	source = ColumnDataSource(data=df)
	species = unique(df.species)
	markers = ["hex", "circle_x", "triangle"]
	# create an empty plot
	plot = figure(
		title = "Penguin Size",
		background_fill_color = "#fafafa",
	)
	# add marks
	scatter!(plot, source,
		x="flipper_length_mm",
		y="body_mass_g",
		fill_alpha=0.4,
		size=12,
		marker=factor_mark("species", markers, species),
		color=factor_cmap("species", "Category10_3", species),
	)
	# display it by wrapping into a document
	Document(plot)
end

# ╔═╡ Cell order:
# ╠═1818e1e1-2c9d-43c0-806b-4df10be823dc
# ╠═8f2973ce-c8bf-11ec-03c0-b35d204ecc67
# ╠═9a9162a9-c1ef-451f-af32-930db032f2dc
# ╠═d177dd54-c9d2-4021-979f-f7b76b9e803c
