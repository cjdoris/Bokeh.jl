### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 1a6e05e0-cc54-11ec-10e2-7961b6637467
using Pkg; Pkg.activate("pluto", shared=true);

# ╔═╡ ef5b17f7-3c32-4f8e-9cd1-0813f3b7bcb8
using Bokeh

# ╔═╡ deb0d26c-80a1-4970-9d1d-cb3c409e7e46
md"""
# Images

This example recreates the plot from: [https://docs.bokeh.org/en/latest/docs/gallery/image.html](https://docs.bokeh.org/en/latest/docs/gallery/image.html)
"""

# ╔═╡ 5e13c6e3-3622-4eaf-945d-34527bfc4538
data = [
	sin(x)*cos(y)
	for x in range(0, 10, length=500),
	    y in range(0, 10, length=500)
];

# ╔═╡ e06ffd07-7a82-4b9a-9d1e-b8eda37e8a4d
begin
	p = figure() # TODO tooltips=[("x", "$x"), ("y", "$y"), ("value", "@image")]
	p.x_range.range_padding = p.y_range.range_padding = 0
	image!(p, image=[data], x=0, y=0, dw=10, dh=10, level="image",
		color_mapper=LinearColorMapper(palette="Spectral11"), # TODO palette="..."
	)
	Document(p)
end

# ╔═╡ Cell order:
# ╟─deb0d26c-80a1-4970-9d1d-cb3c409e7e46
# ╠═1a6e05e0-cc54-11ec-10e2-7961b6637467
# ╠═ef5b17f7-3c32-4f8e-9cd1-0813f3b7bcb8
# ╠═5e13c6e3-3622-4eaf-945d-34527bfc4538
# ╠═e06ffd07-7a82-4b9a-9d1e-b8eda37e8a4d
