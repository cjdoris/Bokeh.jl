### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ e5f1c840-cd6d-11ec-12e0-5ddc4d29b81b
using Pkg; Pkg.activate("pluto", shared=true);

# ╔═╡ efb358c1-e90b-42ad-b680-cf1e80bfed89
using Bokeh

# ╔═╡ f05c8489-d07e-4587-88a3-e01225451771
md"""
# Image RGBA

This example reproduces the plot from: [https://docs.bokeh.org/en/latest/docs/gallery/image_rgba.html](https://docs.bokeh.org/en/latest/docs/gallery/image_rgba.html)
"""

# ╔═╡ 5c0378eb-fd1a-41ee-b8e6-f19696b9f2c7
N = 20;

# ╔═╡ 9940c1cd-7593-4b56-816c-ca5da2b05560
begin
	img = zeros(UInt32, N, N)
	view = reshape(reinterpret(UInt8, img), 4, N, N)
	for i in 1:N
		for j in 1:N
			view[1, j, i] = round(UInt8, (i-1)*255/N)
			view[2, j, i] = 158
			view[3, j, i] = round(UInt8, (j-1)*255/N)
			view[4, j, i] = 255
		end
	end
end;

# ╔═╡ 57d43b83-d18f-4cc7-999d-52f9d5e9840e
begin
	p = figure(
		tooltips=[("x", "\$x"), ("y", "\$y"), ("value", "@image")],
	)
	p.x_range.range_padding = p.y_range.range_padding = 0
	image_rgba!(p, image=[img], x=0, y=0, dw=10, dh=10)
	Document(p)
end

# ╔═╡ Cell order:
# ╟─f05c8489-d07e-4587-88a3-e01225451771
# ╠═e5f1c840-cd6d-11ec-12e0-5ddc4d29b81b
# ╠═efb358c1-e90b-42ad-b680-cf1e80bfed89
# ╠═5c0378eb-fd1a-41ee-b8e6-f19696b9f2c7
# ╠═9940c1cd-7593-4b56-816c-ca5da2b05560
# ╠═57d43b83-d18f-4cc7-999d-52f9d5e9840e
