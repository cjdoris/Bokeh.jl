# Mandelbrot Set (`image!`)

A classic visualisation of the Mandelbrot set.

```@example
using Bokeh

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
end

xmin, xmax = (-2.0, 0.5)
ymin, ymax = (-1.25, 1.25)
resolution = 500
niters = 100

image = [
    mandelbrot(Complex(x, y), niters) |> log |> Float32
    for x in range(xmin, xmax, length=resolution),
        y in range(ymin, ymax, length=resolution)
]

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
```
