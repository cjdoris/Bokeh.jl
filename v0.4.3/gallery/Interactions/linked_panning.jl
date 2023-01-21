using Bokeh

x = 0:10
y0 = x
y1 = [10-xx for xx in x]
y2 = [abs(xx-5) for xx in x]

s1 = figure(title=nothing)
plot!(s1, Scatter; x, y=y0, size=10, color="navy", alpha=0.5, marker="circle")

s2 = figure(x_range=s1.x_range, y_range=s1.y_range, title=nothing)
plot!(s2, Scatter; x, y=y1, size=10, color="firebrick", alpha=0.5, marker="triangle")

s3 = figure(x_range=s1.x_range, title=nothing)
plot!(s3, Scatter; x, y=y2, size=10, color="olive", alpha=0.5, marker="square")

grid([s1 s2 s3], merge_tools=true, toolbar_location=nothing, item_width=250, item_height=250)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

