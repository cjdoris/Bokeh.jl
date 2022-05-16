# ---
# title: Colours
# id: demo_image_rgba
# description: "`ImageRGBA`"
# ---

# Reproduces the plot from [https://docs.bokeh.org/en/latest/docs/gallery/image_rgba.html](https://docs.bokeh.org/en/latest/docs/gallery/image_rgba.html).

using Bokeh

N = 20

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

p = figure(
    tooltips=[("x", "\$x"), ("y", "\$y"), ("value", "@image")],
)

p.ranges.range_padding = 0

plot!(p, ImageRGBA, image=[img], x=0, y=0, dw=10, dh=10)

p
