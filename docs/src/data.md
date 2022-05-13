# Sample Data

The `Bokeh.Data` module provides access to some small sample datasets

See the [Python Bokeh reference](https://docs.bokeh.org/en/2.4.2/docs/reference/sampledata.html)
for more details of these datasets.

Unless otherwise stated, all these functions return a
[Tables.jl](https://github.com/JuliaData/Tables.jl)-compatible table. Optionally a
`materializer` can be specified to convert it to some other type (such as `rowtable`,
`columntable` or `DataFrame`).

```@docs
Bokeh.Data.anscombe
Bokeh.Data.antibiotics
Bokeh.Data.autompg
Bokeh.Data.autompg_clean
Bokeh.Data.autompg2
Bokeh.Data.browsers_nov_2013
Bokeh.Data.commits
Bokeh.Data.daylight_warsaw_2013
Bokeh.Data.degrees
Bokeh.Data.elements
Bokeh.Data.iris
Bokeh.Data.les_mis
Bokeh.Data.numberly
Bokeh.Data.obiszow_mtb_xcm
Bokeh.Data.olympics2014
Bokeh.Data.penguins
Bokeh.Data.probly
Bokeh.Data.sea_surface_temperature
Bokeh.Data.sprint
Bokeh.Data.unemployment1948
Bokeh.Data.us_holidays
Bokeh.Data.us_marriages_divorces
Bokeh.Data.us_states
```
