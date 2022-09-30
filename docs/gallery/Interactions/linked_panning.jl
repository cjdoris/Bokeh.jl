# ---
# title: Linked Panning
# id: linked_panning
# description: Links ranges so that different plots pan together.
# cover: ../assets/linked_panning.png
# ---

# By setting the same range in different plots, when one plot is panned then the others
# are panned also.
# 
# The second plot shares both its `x_range` and `y_range` with the first plot, so that
# panning is linked in both the x- and y-axis. The third plot only shares `x_range` so that
# only the x-axis is linked and its y-axis is independent.
# 
# Reproduces the plot from [https://docs.bokeh.org/en/2.4.2/docs/user\_guide/interaction/linking.html#linked-panning](https://docs.bokeh.org/en/2.4.2/docs/user_guide/interaction/linking.html#linked-panning).

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

gridplot([s1 s2 s3], toolbar_location=nothing, width=250, height=250)
