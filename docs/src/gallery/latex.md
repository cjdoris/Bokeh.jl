# Gaussian Distribution (`TeX`, `Div`, `column`, `quad!`, `line!`)

Reproduces the plot from [https://docs.bokeh.org/en/latest/docs/gallery/latex\_normal\_distribution.html](https://docs.bokeh.org/en/latest/docs/gallery/latex_normal_distribution.html).

```@example
using Bokeh, Bokeh.Math, Bokeh.Widgets, StatsBase

N = 1000

# Sample from a Gaussian distribution
samples = randn(N)

# Scale random data so that it has mean of 0 and standard deviation of 1
scaled = (samples .- mean(samples)) ./ std(samples)

p = figure(
    width=670,
    height=400,
    title="Normal (Gaussian) Distribution",
    toolbar_location=nothing
)

# Plot the histogram
hist = fit(Histogram, scaled, range(-3, 3, length=40)) |> StatsBase.normalize
quad!(p,
    left=hist.edges[1][1:end-1],
    right=hist.edges[1][2:end],
    top=hist.weights,
    bottom=0,
    fill_color="skyblue",
    line_color="white",
    legend_label="$N random samples",
)

# Probability density function
x = range(-3, 3, length=100)
pdf = @. exp(-0.5 * x^2) / sqrt(2 * pi)
line!(p,
    x=x,
    y=pdf,
    line_width=2,
    line_color="navy",
    legend_label="Probability Density Function",
)

p.y_range.start = 0
p.x_axis.axis_label = "x"
p.y_axis.axis_label = "PDF(x)"

p.x_axis.ticker = [-3, -2, -1, 0, 1, 2, 3]
p.x_axis.major_label_overrides = Dict(
    "-3" => TeX(text=raw"\overline{x} - 3\sigma"),
    "-2" => TeX(text=raw"\overline{x} - 2\sigma"),
    "-1" => TeX(text=raw"\overline{x} - \sigma"),
    "0" => TeX(text=raw"\overline{x}"),
    "1" => TeX(text=raw"\overline{x} + \sigma"),
    "2" => TeX(text=raw"\overline{x} + 2\sigma"),
    "3" => TeX(text=raw"\overline{x} + 3\sigma"),
)

p.y_axis.ticker = [0, 0.1, 0.2, 0.3, 0.4]
p.y_axis.major_label_overrides = Dict(
    "0"   => TeX(text=raw"0"),
    "0.1" => TeX(text=raw"0.1/\sigma"),
    "0.2" => TeX(text=raw"0.2/\sigma"),
    "0.3" => TeX(text=raw"0.3/\sigma"),
    "0.4" => TeX(text=raw"0.4/\sigma"),
)


div = Div(text=raw"""
    A histogram of a samples from a Normal (Gaussian) distribution, together with
    the ideal probability density function, given by the equation:
    <p />
    $$
    \qquad PDF(x) = \frac{1}{\sigma\sqrt{2\pi}} \exp\left[-\frac{1}{2}
    \left(\frac{x-\overline{x}}{\sigma}\right)^2 \right]
    $$
    """)

Document(column(p, div))
```
