### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 73543614-354c-4514-bb99-73e4369d14f6
using Pkg; Pkg.activate("pluto", shared=true);

# ╔═╡ fcea3bb7-500a-45f8-9418-c809a4beab9a
using Bokeh

# ╔═╡ 6d90ddf0-ce0d-11ec-0804-efa1c6fc651e
md"""
# Lorenz Attractor

This example reproduces the plot here: [https://docs.bokeh.org/en/latest/docs/gallery/lorenz.html](https://docs.bokeh.org/en/latest/docs/gallery/lorenz.html)
"""

# ╔═╡ 9a2ecef4-6e5f-4330-b6cd-de51a263a7dc
params = (sigma=10.0, rho=28.0, beta=8/3, theta=3π/4);

# ╔═╡ 7cca7288-79e6-4c90-85cd-f7b25802f721
lorenz((x,y,z), t; sigma, rho, beta, theta) = (
	sigma * (y - x),
	x * rho - x * z - y,
	x * y - beta * z,
);

# ╔═╡ ca04993f-3b11-4145-a699-54edda0c470f
initial = (-10, -7, 35)

# ╔═╡ 144b9163-6ece-4c5f-b9e0-aa382b98ffc7
# This is a very basic ODE solver.
# Hence the resulting plot is not quite the same as the example.
function odeint(f, x0, ts, params)
	x = float.(x0)
	ans = [x]
	for i in 1:length(ts)-1
		t = ts[i]
		δt = ts[i+1] - t
		ẋ = f(x, t; params...)
		x = @. x + δt * ẋ
		push!(ans, x)
	end
	return ans
end;

# ╔═╡ 79c9e6d3-713d-4930-a450-361ec15419e4
solution = odeint(lorenz, initial, 0:0.006:100, params);

# ╔═╡ 7263f013-812c-4980-8735-a2fdf70f9094
x, y, z = ntuple(i -> map(x -> x[i], solution), 3);

# ╔═╡ 8b9ef902-5703-4819-8b5d-5cd95befeedb
x′ = @. cos(params.theta) * x - sin(params.theta) * y;

# ╔═╡ ec73128b-de61-46ff-9b79-42646bdff4bc
colors = [
	"#C6DBEF", "#9ECAE1", "#6BAED6", "#4292C6", "#2171B5", "#08519C", "#08306B"
];

# ╔═╡ 6246311e-8318-4ec9-9961-5a79d501d6e9
vec_split(xs, n) = [
	view(xs, fld((i-1)*length(xs), n)+1 : fld(i*length(xs), n))
	for i in 1:n
];

# ╔═╡ 779a41b5-2249-4a34-913a-0f661288575b
begin
	p = figure(
		title = "Lorenz attractor example",
		background_fill_color = "#fafafa",
	)

	lines!(p,
		xs = vec_split(x′, 7),
		ys = vec_split(z, 7),
		line_color = colors,
		line_alpha = 0.8,
		line_width = 1.5,
	)

	Document(p)
end

# ╔═╡ Cell order:
# ╟─6d90ddf0-ce0d-11ec-0804-efa1c6fc651e
# ╠═73543614-354c-4514-bb99-73e4369d14f6
# ╠═fcea3bb7-500a-45f8-9418-c809a4beab9a
# ╠═9a2ecef4-6e5f-4330-b6cd-de51a263a7dc
# ╠═7cca7288-79e6-4c90-85cd-f7b25802f721
# ╠═ca04993f-3b11-4145-a699-54edda0c470f
# ╠═144b9163-6ece-4c5f-b9e0-aa382b98ffc7
# ╠═79c9e6d3-713d-4930-a450-361ec15419e4
# ╠═7263f013-812c-4980-8735-a2fdf70f9094
# ╠═8b9ef902-5703-4819-8b5d-5cd95befeedb
# ╠═ec73128b-de61-46ff-9b79-42646bdff4bc
# ╠═6246311e-8318-4ec9-9961-5a79d501d6e9
# ╠═779a41b5-2249-4a34-913a-0f661288575b
