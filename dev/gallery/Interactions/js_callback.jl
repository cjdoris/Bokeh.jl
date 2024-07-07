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

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
