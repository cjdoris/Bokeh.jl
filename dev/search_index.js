var documenterSearchIndex = {"docs":
[{"location":"gallery/lorenz/#Lorenz-Attractor-(multi_line!)","page":"Lorenz Attractor (multi_line!)","title":"Lorenz Attractor (multi_line!)","text":"","category":"section"},{"location":"gallery/lorenz/","page":"Lorenz Attractor (multi_line!)","title":"Lorenz Attractor (multi_line!)","text":"Reproduces the plot from https://docs.bokeh.org/en/latest/docs/gallery/lorenz.html.","category":"page"},{"location":"gallery/lorenz/","page":"Lorenz Attractor (multi_line!)","title":"Lorenz Attractor (multi_line!)","text":"The odeint function is a very basic ODE solver, so the results are not quite the same.","category":"page"},{"location":"gallery/lorenz/","page":"Lorenz Attractor (multi_line!)","title":"Lorenz Attractor (multi_line!)","text":"using Bokeh\n\nparams = (sigma=10.0, rho=28.0, beta=8/3, theta=3π/4)\n\nlorenz((x,y,z), t; sigma, rho, beta, theta) = (\n    sigma * (y - x),\n    x * rho - x * z - y,\n    x * y - beta * z,\n)\n\ninitial = (-10, -7, 35)\n\nfunction odeint(f, x0, ts, params)\n    x = float.(x0)\n    ans = [x]\n    for i in 1:length(ts)-1\n        t = ts[i]\n        δt = ts[i+1] - t\n        ẋ = f(x, t; params...)\n        x = @. x + δt * ẋ\n        push!(ans, x)\n    end\n    return ans\nend\n\nsolution = odeint(lorenz, initial, 0:0.006:100, params)\n\nx, y, z = ntuple(i -> map(x -> x[i], solution), 3)\n\nx′ = @. cos(params.theta) * x - sin(params.theta) * y\n\ncolors = [\"#C6DBEF\", \"#9ECAE1\", \"#6BAED6\", \"#4292C6\", \"#2171B5\", \"#08519C\", \"#08306B\"]\n\nvec_split(xs, n) = [\n    view(xs, fld((i-1)*length(xs), n)+1 : fld(i*length(xs), n))\n    for i in 1:n\n]\n\np = figure(\n    title = \"Lorenz attractor example\",\n    background_fill_color = \"#fafafa\",\n)\n\nmulti_line!(p,\n    xs = vec_split(Float32.(x′), 7),\n    ys = vec_split(Float32.(z), 7),\n    line_color = colors,\n    line_alpha = 0.8,\n    line_width = 1.5,\n)\n\np","category":"page"},{"location":"data/#Sample-Data","page":"Sample Data","title":"Sample Data","text":"","category":"section"},{"location":"data/","page":"Sample Data","title":"Sample Data","text":"The Bokeh.Data module provides access to some small sample datasets","category":"page"},{"location":"data/","page":"Sample Data","title":"Sample Data","text":"See the Python Bokeh reference for more details of these datasets.","category":"page"},{"location":"data/","page":"Sample Data","title":"Sample Data","text":"Unless otherwise stated, all these functions return a Tables.jl-compatible table. Optionally a materializer can be specified to convert it to some other type (such as rowtable, columntable or DataFrame).","category":"page"},{"location":"data/","page":"Sample Data","title":"Sample Data","text":"Bokeh.Data.anscombe\nBokeh.Data.antibiotics\nBokeh.Data.autompg\nBokeh.Data.autompg_clean\nBokeh.Data.autompg2\nBokeh.Data.browsers_nov_2013\nBokeh.Data.commits\nBokeh.Data.daylight_warsaw_2013\nBokeh.Data.degrees\nBokeh.Data.elements\nBokeh.Data.iris\nBokeh.Data.les_mis\nBokeh.Data.numberly\nBokeh.Data.obiszow_mtb_xcm\nBokeh.Data.olympics2014\nBokeh.Data.penguins\nBokeh.Data.probly\nBokeh.Data.sea_surface_temperature\nBokeh.Data.sprint\nBokeh.Data.unemployment1948\nBokeh.Data.us_holidays\nBokeh.Data.us_marriages_divorces\nBokeh.Data.us_states","category":"page"},{"location":"data/#Bokeh.Data.anscombe","page":"Sample Data","title":"Bokeh.Data.anscombe","text":"anscombe([materializer])\n\nThe four data series that comprise 'Anscombe's Quartet'.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.antibiotics","page":"Sample Data","title":"Bokeh.Data.antibiotics","text":"antibiotics([materializer])\n\nA table of Will Burtin's historical data regarding antibiotic efficacies.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.autompg","page":"Sample Data","title":"Bokeh.Data.autompg","text":"autompg([materializer])\n\nA version of the Auto MPG data set.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.autompg_clean","page":"Sample Data","title":"Bokeh.Data.autompg_clean","text":"autompg_clean([materializer])\n\nA version of the Auto MPG data set. Cleans the mfr and origin fields.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.autompg2","page":"Sample Data","title":"Bokeh.Data.autompg2","text":"autompg2([materializer])\n\nA version of the Auto MPG data set.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.browsers_nov_2013","page":"Sample Data","title":"Bokeh.Data.browsers_nov_2013","text":"browsers_nov_2013([materializer])\n\nBrowser market share by version from November 2013.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.commits","page":"Sample Data","title":"Bokeh.Data.commits","text":"commits([materializer])\n\nTime series of commits for a GitHub user between 2012 and 2016.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.daylight_warsaw_2013","page":"Sample Data","title":"Bokeh.Data.daylight_warsaw_2013","text":"daylight_warsaw_2013([materializer])\n\n2013 Warsaw daylight hours.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.degrees","page":"Sample Data","title":"Bokeh.Data.degrees","text":"degrees([materializer])\n\nA table of data regarding bachelor's degrees earned by women.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.elements","page":"Sample Data","title":"Bokeh.Data.elements","text":"elements([materializer])\n\nA periodic table dataset.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.iris","page":"Sample Data","title":"Bokeh.Data.iris","text":"iris([materializer])\n\nFisher's Iris dataset.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.les_mis","page":"Sample Data","title":"Bokeh.Data.les_mis","text":"les_mis([materializer])\n\nCo-occurrence of characters in Les Miserables.\n\nReturns a named tuple (nodes=..., links=...) of nodes (characters) and links (co-occurrences) between them.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.numberly","page":"Sample Data","title":"Bokeh.Data.numberly","text":"numberly([materializer])\n\nThe numberly dataset.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.obiszow_mtb_xcm","page":"Sample Data","title":"Bokeh.Data.obiszow_mtb_xcm","text":"obiszow_mtb_xcm([materializer])\n\nRoute data (including altitude) for a bike race in Eastern Europe.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.olympics2014","page":"Sample Data","title":"Bokeh.Data.olympics2014","text":"olympics2014([materializer])\n\nMedal counts by country for the 2014 Olympics.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.penguins","page":"Sample Data","title":"Bokeh.Data.penguins","text":"penguins([materializer])\n\nThe Palmer Archipelago (Antarctica) penguin dataset.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.probly","page":"Sample Data","title":"Bokeh.Data.probly","text":"probly([materializer])\n\nThe probly dataset.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.sea_surface_temperature","page":"Sample Data","title":"Bokeh.Data.sea_surface_temperature","text":"sea_surface_temperature([materializer])\n\nTime series of historical average sea surface temperatures.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.sprint","page":"Sample Data","title":"Bokeh.Data.sprint","text":"sprint([materializer])\n\nHistorical results for Olympic sprints by year.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.unemployment1948","page":"Sample Data","title":"Bokeh.Data.unemployment1948","text":"unemployment1948([materializer])\n\nUS Unemployment rate data by month and year, from 1948 to 2013.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.us_holidays","page":"Sample Data","title":"Bokeh.Data.us_holidays","text":"us_holidays([materializer])\n\nCalendar file of US Holidays from Mozilla provided by icalendar.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.us_marriages_divorces","page":"Sample Data","title":"Bokeh.Data.us_marriages_divorces","text":"us_marriages_divorces([materializer])\n\nU.S. marriage and divorce statistics between 1867 and 2014.\n\n\n\n\n\n","category":"function"},{"location":"data/#Bokeh.Data.us_states","page":"Sample Data","title":"Bokeh.Data.us_states","text":"us_states([materializer])\n\nGeometry data for US States.\n\n\n\n\n\n","category":"function"},{"location":"gallery/mpg/#Auto-MPG-(vbar!,-factor_cmap,-tooltips,-nested-factors)","page":"Auto MPG (vbar!, factor_cmap, tooltips, nested factors)","title":"Auto MPG (vbar!, factor_cmap, tooltips, nested factors)","text":"","category":"section"},{"location":"gallery/mpg/","page":"Auto MPG (vbar!, factor_cmap, tooltips, nested factors)","title":"Auto MPG (vbar!, factor_cmap, tooltips, nested factors)","text":"Reproduces the plot from https://docs.bokeh.org/en/latest/docs/gallery/bar_pandas_groupby_nested.html.","category":"page"},{"location":"gallery/mpg/","page":"Auto MPG (vbar!, factor_cmap, tooltips, nested factors)","title":"Auto MPG (vbar!, factor_cmap, tooltips, nested factors)","text":"using Bokeh, DataFrames, Statistics\n\ndf = Bokeh.Data.autompg_clean(DataFrame)\n\nagg = combine(\n\tgroupby(df, [\"cyl\", \"mfr\"]),\n\t[\n\t\t[\"cyl\",\"mfr\"] => ((x,y)->(string(x[1]),y[1])) => \"cyl_mfr\",\n\t\t\"mpg\" => mean => \"mpg_mean\",\n\t]\n)\n\np = figure(\n\twidth=800,\n\theight=300,\n\ttitle=\"Mean MPG by # Cylinders and Manufacturer\",\n    x_range=sort(agg.cyl_mfr),\n\ttoolbar_location=nothing,\n\ttooltips=[(\"MPG\", \"@mpg_mean\"), (\"Cyl, Mfr\", \"@cyl_mfr\")],\n)\n\nvbar!(p,\n\tx=\"cyl_mfr\",\n\ttop=\"mpg_mean\",\n\twidth=1,\n\tsource=agg,\n\tline_color=\"white\",\n\tfill_color=factor_cmap(\"cyl_mfr\", \"Spectral5\", string.(sort(unique(agg.cyl))); :end=>1),\n)\n\np.y_range.start = 0\np.x_range.range_padding = 0.05\np.x_grid.grid_line_color = nothing\np.x_axis.axis_label = \"Manufacturer grouped by # Cylinders\"\np.x_axis.major_label_orientation = 1.2\np.outline_line_color = nothing\n\np","category":"page"},{"location":"gallery/image_rgba/#Colours-(image_rgba!)","page":"Colours (image_rgba!)","title":"Colours (image_rgba!)","text":"","category":"section"},{"location":"gallery/image_rgba/","page":"Colours (image_rgba!)","title":"Colours (image_rgba!)","text":"Reproduces the plot from https://docs.bokeh.org/en/latest/docs/gallery/image_rgba.html.","category":"page"},{"location":"gallery/image_rgba/","page":"Colours (image_rgba!)","title":"Colours (image_rgba!)","text":"using Bokeh\n\nN = 20\n\nimg = zeros(UInt32, N, N)\n\nview = reshape(reinterpret(UInt8, img), 4, N, N)\n\nfor i in 1:N\n    for j in 1:N\n        view[1, j, i] = round(UInt8, (i-1)*255/N)\n        view[2, j, i] = 158\n        view[3, j, i] = round(UInt8, (j-1)*255/N)\n        view[4, j, i] = 255\n    end\nend\n\np = figure(\n    tooltips=[(\"x\", \"\\$x\"), (\"y\", \"\\$y\"), (\"value\", \"@image\")],\n)\n\np.ranges.range_padding = 0\n\nimage_rgba!(p, image=[img], x=0, y=0, dw=10, dh=10)\n\np","category":"page"},{"location":"guide/#User-Guide","page":"User Guide","title":"User Guide","text":"","category":"section"},{"location":"guide/#Installation","page":"User Guide","title":"Installation","text":"","category":"section"},{"location":"guide/","page":"User Guide","title":"User Guide","text":"In Julia, press ] to enter the Pkg REPL and do","category":"page"},{"location":"guide/","page":"User Guide","title":"User Guide","text":"pkg> add Bokeh","category":"page"},{"location":"guide/#Create-your-first-plot","page":"User Guide","title":"Create your first plot","text":"","category":"section"},{"location":"guide/","page":"User Guide","title":"User Guide","text":"You will need to use Pluto, Jupyter, or any other environment capable of displaying HTML.","category":"page"},{"location":"guide/","page":"User Guide","title":"User Guide","text":"Alternatively, you can display straight to the browser from the REPL by calling","category":"page"},{"location":"guide/","page":"User Guide","title":"User Guide","text":"using Bokeh\nBokeh.settings!(use_browser=true)","category":"page"},{"location":"guide/","page":"User Guide","title":"User Guide","text":"Creating a plot generally consists of three steps:","category":"page"},{"location":"guide/","page":"User Guide","title":"User Guide","text":"Create an empty figure.\nAdd glyphs to the figure.\nDisplay the figure.","category":"page"},{"location":"guide/","page":"User Guide","title":"User Guide","text":"using Bokeh\np = figure()\nscatter!(p, x=randn(1000), y=randn(1000))\np","category":"page"},{"location":"guide/","page":"User Guide","title":"User Guide","text":"The final line causes the REPL or notebook you are using to display the plot p. You may explicitly call display(p) instead, e.g. if you are plotting in a script or a loop.","category":"page"},{"location":"guide/","page":"User Guide","title":"User Guide","text":"If you are using use_browser=true in the REPL, you may like to put ; at the end of each command to supress displaying it.","category":"page"},{"location":"gallery/les_mis/#Les-Misérables-Co-occurrences-(rect!,-tools)","page":"Les Misérables Co-occurrences (rect!, tools)","title":"Les Misérables Co-occurrences (rect!, tools)","text":"","category":"section"},{"location":"gallery/les_mis/","page":"Les Misérables Co-occurrences (rect!, tools)","title":"Les Misérables Co-occurrences (rect!, tools)","text":"Reproduces the plot from https://docs.bokeh.org/en/latest/docs/gallery/les_mis.html.","category":"page"},{"location":"gallery/les_mis/","page":"Les Misérables Co-occurrences (rect!, tools)","title":"Les Misérables Co-occurrences (rect!, tools)","text":"using Bokeh, Tables\n\ndata = Bokeh.Data.les_mis(rowtable)\n\nnames = [node.name for node in sort(data.nodes, by=x->x.group)]\n\ncounts = Dict(\n    (s ? (x.source, x.target) : (x.target, x.source)) => x.value\n    for x in data.links\n    for s in (true, false)\n)\n\ncolormap = [\"#444444\", \"#a6cee3\", \"#1f78b4\", \"#b2df8a\", \"#33a02c\", \"#fb9a99\",\n            \"#e31a1c\", \"#fdbf6f\", \"#ff7f00\", \"#cab2d6\", \"#6a3d9a\"]\n\npairdata = [\n    (\n        xname = node1.name,\n        yname = node2.name,\n        alpha = min(get(counts, (i1 - 1, i2 - 1), 0) / 4, 0.9) + 0.1,\n        color = node1.group == node2.group ? colormap[node1.group + 1] : \"lightgrey\",\n        count = get(counts, (i1 - 1, i2 - 1), 0),\n    )\n    for (i1, node1) in enumerate(data.nodes)\n    for (i2, node2) in enumerate(data.nodes)\n]\n\np = figure(\n    title=\"Les Mis Occurrences\",\n    x_axis_location=\"above\",\n    x_range=reverse(names),\n    y_range=names,\n    tools=[SaveTool()],\n    tooltips = [(\"names\", \"@yname, @xname\"), (\"count\", \"@count\")],\n    width = 800,\n    height = 800,\n)\n\np.grids.grid_line_color = nothing\np.axes.axis_line_color = nothing\np.axes.major_tick_line_color = nothing\np.axes.major_label_text_font_size = \"7px\"\np.axes.major_label_standoff = 0\np.x_axis.major_label_orientation = π/3\n\nrect!(p,\n    x=\"xname\",\n    y=\"yname\",\n    width=0.9,\n    height=0.9,\n    source=pairdata,\n    color=\"color\",\n    alpha=\"alpha\",\n    line_color=nothing,\n    # hover_color=\"colors\", TODO\n    # hover_line_color=\"black\", TODO\n)\n\np","category":"page"},{"location":"gallery/mandelbrot/#Mandelbrot-Set-(image!)","page":"Mandelbrot Set (image!)","title":"Mandelbrot Set (image!)","text":"","category":"section"},{"location":"gallery/mandelbrot/","page":"Mandelbrot Set (image!)","title":"Mandelbrot Set (image!)","text":"A classic visualisation of the Mandelbrot set.","category":"page"},{"location":"gallery/mandelbrot/","page":"Mandelbrot Set (image!)","title":"Mandelbrot Set (image!)","text":"using Bokeh\n\nfunction mandelbrot(c::Complex, niters=100)\n    z = zero(c)\n    for i in 1:niters\n        if isnan(z) || abs2(z) > 4\n            return i\n        else\n            z = z ^ 2 + c\n        end\n    end\n    return niters+1\nend\n\nxmin, xmax = (-2.0, 0.5)\nymin, ymax = (-1.25, 1.25)\nresolution = 500\nniters = 100\n\nimage = [\n    mandelbrot(Complex(x, y), niters) |> log |> Float32\n    for x in range(xmin, xmax, length=resolution),\n        y in range(ymin, ymax, length=resolution)\n]\n\np = figure(\n    title = \"Mandelbrot set\",\n)\np.ranges.range_padding = 0\n\nimage!(p,\n    image = [image],\n    x = xmin,\n    y = ymin,\n    dw = xmax - xmin,\n    dh = ymax - ymin,\n    palette = \"Magma256\",\n)\n\np","category":"page"},{"location":"gallery/image/#Heatmap-(image!)","page":"Heatmap (image!)","title":"Heatmap (image!)","text":"","category":"section"},{"location":"gallery/image/","page":"Heatmap (image!)","title":"Heatmap (image!)","text":"Reproduces the plot from https://docs.bokeh.org/en/latest/docs/gallery/image.html.","category":"page"},{"location":"gallery/image/","page":"Heatmap (image!)","title":"Heatmap (image!)","text":"using Bokeh\n\ndata = [\n    Float32(sin(x)*cos(y))\n    for x in range(0, 10, length=500),\n        y in range(0, 10, length=500)\n]\n\np = figure(\n    tooltips=[(\"x\", \"\\$x\"), (\"y\", \"\\$y\"), (\"value\", \"@image\")]\n)\n\np.ranges.range_padding = 0\np.grids.grid_line_width = 0\n\nimage!(p, image=[data], x=0, y=0, dw=10, dh=10, level=\"image\", palette=\"Spectral11\")\n\np","category":"page"},{"location":"gallery/penguins/#Penguins-(scatter!,-factor_mark,-factor_cmap)","page":"Penguins (scatter!, factor_mark, factor_cmap)","title":"Penguins (scatter!, factor_mark, factor_cmap)","text":"","category":"section"},{"location":"gallery/penguins/","page":"Penguins (scatter!, factor_mark, factor_cmap)","title":"Penguins (scatter!, factor_mark, factor_cmap)","text":"Reproduces the plot from https://docs.bokeh.org/en/latest/docs/gallery/marker_map.html.","category":"page"},{"location":"gallery/penguins/","page":"Penguins (scatter!, factor_mark, factor_cmap)","title":"Penguins (scatter!, factor_mark, factor_cmap)","text":"using Bokeh, Tables\n\ndata = Bokeh.Data.penguins(columntable)\n\nsource = ColumnDataSource(data=data)\n\nspecies = unique(data.species)\n\nmarkers = [\"hex\", \"circle_x\", \"triangle\"]\n\nplot = figure(\n    title = \"Penguin Size\",\n    background_fill_color = \"#fafafa\",\n)\n\nscatter!(plot,\n    x=\"flipper_length_mm\",\n    y=\"body_mass_g\",\n    source=source,\n    fill_alpha=0.4,\n    size=12,\n    marker=factor_mark(\"species\", markers, species),\n    color=factor_cmap(\"species\", \"Category10_3\", species),\n)\n\nplot","category":"page"},{"location":"gallery/latex/#Gaussian-Distribution-(TeX,-Div,-column,-quad!,-line!)","page":"Gaussian Distribution (TeX, Div, column, quad!, line!)","title":"Gaussian Distribution (TeX, Div, column, quad!, line!)","text":"","category":"section"},{"location":"gallery/latex/","page":"Gaussian Distribution (TeX, Div, column, quad!, line!)","title":"Gaussian Distribution (TeX, Div, column, quad!, line!)","text":"Reproduces the plot from https://docs.bokeh.org/en/latest/docs/gallery/latex_normal_distribution.html.","category":"page"},{"location":"gallery/latex/","page":"Gaussian Distribution (TeX, Div, column, quad!, line!)","title":"Gaussian Distribution (TeX, Div, column, quad!, line!)","text":"using Bokeh, StatsBase\n\nN = 1000\n\n# Sample from a Gaussian distribution\nsamples = randn(N)\n\n# Scale random data so that it has mean of 0 and standard deviation of 1\nscaled = (samples .- mean(samples)) ./ std(samples)\n\np = figure(\n    width=670,\n    height=400,\n    title=\"Normal (Gaussian) Distribution\",\n    toolbar_location=nothing\n)\n\n# Plot the histogram\nhist = fit(Histogram, scaled, range(-3, 3, length=40)) |> StatsBase.normalize\nquad!(p,\n    left=hist.edges[1][1:end-1],\n    right=hist.edges[1][2:end],\n    top=hist.weights,\n    bottom=0,\n    fill_color=\"skyblue\",\n    line_color=\"white\",\n    legend_label=\"$N random samples\",\n)\n\n# Probability density function\nx = range(-3, 3, length=100)\npdf = @. exp(-0.5 * x^2) / sqrt(2 * pi)\nline!(p,\n    x=x,\n    y=pdf,\n    line_width=2,\n    line_color=\"navy\",\n    legend_label=\"Probability Density Function\",\n)\n\np.y_range.start = 0\np.x_axis.axis_label = \"x\"\np.y_axis.axis_label = \"PDF(x)\"\n\np.x_axis.ticker = [-3, -2, -1, 0, 1, 2, 3]\np.x_axis.major_label_overrides = Dict(\n    \"-3\" => TeX(text=raw\"\\overline{x} - 3\\sigma\"),\n    \"-2\" => TeX(text=raw\"\\overline{x} - 2\\sigma\"),\n    \"-1\" => TeX(text=raw\"\\overline{x} - \\sigma\"),\n    \"0\" => TeX(text=raw\"\\overline{x}\"),\n    \"1\" => TeX(text=raw\"\\overline{x} + \\sigma\"),\n    \"2\" => TeX(text=raw\"\\overline{x} + 2\\sigma\"),\n    \"3\" => TeX(text=raw\"\\overline{x} + 3\\sigma\"),\n)\n\np.y_axis.ticker = [0, 0.1, 0.2, 0.3, 0.4]\np.y_axis.major_label_overrides = Dict(\n    \"0\"   => TeX(text=raw\"0\"),\n    \"0.1\" => TeX(text=raw\"0.1/\\sigma\"),\n    \"0.2\" => TeX(text=raw\"0.2/\\sigma\"),\n    \"0.3\" => TeX(text=raw\"0.3/\\sigma\"),\n    \"0.4\" => TeX(text=raw\"0.4/\\sigma\"),\n)\n\n\ndiv = Div(text=raw\"\"\"\n    A histogram of a samples from a Normal (Gaussian) distribution, together with\n    the ideal probability density function, given by the equation:\n    <p />\n    $$\n    \\qquad PDF(x) = \\frac{1}{\\sigma\\sqrt{2\\pi}} \\exp\\left[-\\frac{1}{2}\n    \\left(\\frac{x-\\overline{x}}{\\sigma}\\right)^2 \\right]\n    $$\n    \"\"\")\n\ncolumn(p, div)","category":"page"},{"location":"gallery/vbar/#Bar-Charts-(vbar!,-factor_cmap)","page":"Bar Charts (vbar!, factor_cmap)","title":"Bar Charts (vbar!, factor_cmap)","text":"","category":"section"},{"location":"gallery/vbar/","page":"Bar Charts (vbar!, factor_cmap)","title":"Bar Charts (vbar!, factor_cmap)","text":"Reproduces the plot from https://docs.bokeh.org/en/latest/docs/gallery/bar_colormapped.html.","category":"page"},{"location":"gallery/vbar/","page":"Bar Charts (vbar!, factor_cmap)","title":"Bar Charts (vbar!, factor_cmap)","text":"using Bokeh\n\ndata = (\n    fruits = [\"Apples\", \"Pears\", \"Nectarines\", \"Plums\", \"Grapes\", \"Strawberries\"],\n    counts = [5, 3, 4, 2, 4, 6],\n)\n\np = figure(\n    x_range=data.fruits,\n    height=350,\n    toolbar_location=nothing,\n    title=\"Fruit Counts\",\n)\n\nvbar!(p,\n    x=\"fruits\",\n    top=\"counts\",\n    source=data,\n    width=0.9,\n    legend_field=\"fruits\",\n    line_color=\"white\",\n    fill_color=factor_cmap(\"fruits\", \"Spectral6\", data.fruits),\n)\n\np.x_grid.grid_line_color = nothing\np.y_range.start = 0\np.y_range.end = 9\np.legend.orientation = \"horizontal\"\np.legend.location = \"top_center\"\n\np","category":"page"},{"location":"#Bokeh.jl","page":"Home","title":"Bokeh.jl","text":"","category":"section"},{"location":"#Overview","page":"Home","title":"Overview","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Bokeh.jl is a Julia front-end for the Bokeh plotting library. Bokeh makes it simple to create interactive plots like this:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Bokeh\nn = 2_000\nz = rand(1:3, n)\nx = randn(n) .+ [-2, 0, 2][z]\ny = randn(n) .+ [-1, 3, -1][z]\ncolor = Bokeh.PALETTES[\"Julia3\"][z]\np = figure(title=\"Julia Logo\")\nscatter!(p; x, y, color, alpha=0.4, size=10)\np","category":"page"},{"location":"#How-it-works","page":"Home","title":"How it works","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Although Bokeh is mainly a Python library, all the actual plotting happens in the browser using BokehJS. This package wraps BokehJS directly without using Python.","category":"page"}]
}
