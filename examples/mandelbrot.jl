### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 530b180e-7cb2-469a-9ed6-bd81068ff41b
using Pkg; Pkg.activate("pluto", shared=true);

# ╔═╡ 66355262-4c3e-476e-aa8e-29713fcc8f1e
using Bokeh

# ╔═╡ eca86eb0-ce11-11ec-12a3-d90c81ef0069
md"""
# Mandelbrot Set

A classic visualisation of the Mandelbrot set.
"""

# ╔═╡ 41b5908c-2892-4659-899b-3681bbb0ccb5
function mandelbrot(c::Complex, niters=100)
	z = zero(c)
	for i in 1:niters
		if isnan(z) || abs2(z) > 4
			return i
		else
			z = z ^ 2 + c
		end
	end
	return niters+1
end;

# ╔═╡ f514ce78-3e0a-4ef0-9065-9b681f814e68
(xmin, xmax, ymin, ymax, resolution, niters) = (-2.0, 0.5, -1.25, 1.25, 1000, 100);

# ╔═╡ 0e335aa5-e6cb-433d-9bb5-31e931ab92cc
image = [
	log(mandelbrot(Complex(x, y), niters))
	for x in range(xmin, xmax, length=resolution),
		y in range(ymin, ymax, length=resolution)
];

# ╔═╡ 6433362f-2d40-458a-a8ef-21998c1991d2
begin
	p = figure(
		title = "Mandelbrot set",
	)
	p.ranges.range_padding = 0
	
	image!(p,
		image = [image],
		x = xmin,
		y = ymin,
		dw = xmax - xmin,
		dh = ymax - ymin,
		palette = "Magma256",
	)

	Document(p)
end

# ╔═╡ Cell order:
# ╟─eca86eb0-ce11-11ec-12a3-d90c81ef0069
# ╠═530b180e-7cb2-469a-9ed6-bd81068ff41b
# ╠═66355262-4c3e-476e-aa8e-29713fcc8f1e
# ╠═41b5908c-2892-4659-899b-3681bbb0ccb5
# ╠═f514ce78-3e0a-4ef0-9065-9b681f814e68
# ╠═0e335aa5-e6cb-433d-9bb5-31e931ab92cc
# ╠═6433362f-2d40-458a-a8ef-21998c1991d2
