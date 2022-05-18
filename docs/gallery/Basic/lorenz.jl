# ---
# title: Lorenz Attractor
# id: demo_lorenz
# description: Demonstrates the `Multiline` glyph.
# cover: ../assets/lorenz.png
# ---

# Reproduces the plot from [https://docs.bokeh.org/en/latest/docs/gallery/lorenz.html](https://docs.bokeh.org/en/latest/docs/gallery/lorenz.html).

# The `odeint` function is a very basic ODE solver, so the results are not quite the same.

using Bokeh

params = (sigma=10.0, rho=28.0, beta=8/3, theta=3π/4)

lorenz((x,y,z), t; sigma, rho, beta, theta) = (
    sigma * (y - x),
    x * rho - x * z - y,
    x * y - beta * z,
)

initial = (-10, -7, 35)

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
end

solution = odeint(lorenz, initial, 0:0.006:100, params)

x, y, z = ntuple(i -> map(x -> x[i], solution), 3)

x′ = @. cos(params.theta) * x - sin(params.theta) * y

colors = ["#C6DBEF", "#9ECAE1", "#6BAED6", "#4292C6", "#2171B5", "#08519C", "#08306B"]

vec_split(xs, n) = [
    view(xs, fld((i-1)*length(xs), n)+1 : fld(i*length(xs), n))
    for i in 1:n
]

p = figure(
    title = "Lorenz attractor example",
    background_fill_color = "#fafafa",
)

plot!(p, MultiLine,
    xs = vec_split(Float32.(x′), 7),
    ys = vec_split(Float32.(z), 7),
    line_color = colors,
    line_alpha = 0.8,
    line_width = 1.5,
)

p
