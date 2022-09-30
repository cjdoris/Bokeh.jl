# ---
# title: JavaScript Callbacks
# id: js_callback
# description: Writing custom JavaScript for advanced interactivity.
# cover: ../assets/js_callback.png
# ---

# In this example we write some custom JavaScript which is called whenever the value of a
# slider widget changes. It changes the data in the data source of our plot, so the plot
# gets re-drawn.
# 
# Reproduces the plot from [https://docs.bokeh.org/en/2.4.2/docs/user\_guide/interaction/callbacks.html#customjs-for-widgets](https://docs.bokeh.org/en/2.4.2/docs/user_guide/interaction/callbacks.html#customjs-for-widgets).

using Bokeh

x = range(0, 1, length=200)
y = x

source = ColumnDataSource(data=(; x, y))

fig = figure(width=400, height=400)
plot!(fig, Line; x="x", y="y", source, line_width=3, line_alpha=0.6)

callback = CustomJS(args=Dict("source"=>source), code="""
    const data = source.data
    const f = cb_obj.value
    const x = data['x']
    const y = data['y']
    for (let i = 0; i < x.length; i++) {
        y[i] = Math.pow(x[i], f)
    }
    source.change.emit()
    """)

slider = Slider(start=0.1, end_=4, value=1, step=0.1, title="power")
js_on_change(slider, "value", callback)

column(slider, fig)
