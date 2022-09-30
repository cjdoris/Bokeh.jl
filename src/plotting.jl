### TRANSFORMS

"""
    transform(field, transform)

A the field of the given name transformed with the given [`Transform`](@ref).
"""
function transform(field, transform)
    ismodelinstance(transform, Transform) || error("transform must be a Transform")
    return Field(field; transform)
end

"""
    dodge(field, value; kw...)

Transform the given field with a [`Dodge`](@ref).
"""
dodge(field, value; kw...) = transform(field, Dodge(; value, kw...))

"""
    factor_mark(field, markers, factors; ...)

Transform the given field with a [`CategoricalMarkerMapper`](@ref) that selects the given
markers for the corresponding factors.
"""
factor_mark(field, markers, factors; kw...) = transform(field, CategoricalMarkerMapper(; markers, factors, kw...))

"""
    factor_cmap(field, palette, factors; ...)

Transform the given field with a [`CategoricalColorMapper`](@ref) that selects the given
colors for the corresponding factors.
"""
factor_cmap(field, palette, factors; kw...) = transform(field, CategoricalColorMapper(; palette, factors, kw...))

"""
    factor_hatch(field, patterns, factors; ...)

Transform the given field with a [`CategoricalPatternMapper`](@ref) that selects the given
hatch patterns for the corresponding factors.
"""
factor_hatch(field, patterns, factors; kw...) = transform(field, CategoricalPatternMapper(; patterns, factors, kw...))

"""
    jitter(field, width; ...)

Transform the given field with a [`Jitter`](@ref) that applies random pertubations of the
given width.
"""
jitter(field, width; kw...) = transform(field, Jitter(; width, kw...))

"""
    linear_cmap(field, palette; ...)

Transform the given field with a [`LinearColorMapper`](@ref) that selects colors linearly
from the given palette.
"""
linear_cmap(field, palette; kw...) = transform(field, LinearColorMapper(; palette, kw...))

"""
    log_cmap(field, palette; ...)

Transform the given field with a [`LogColorMapper`](@ref) that selects colors
logarithmically from the given palette.
"""
log_cmap(field, palette; kw...) = transform(field, LogColorMapper(; palette, kw...))


### FIGURE

function get_range(range)
    if range === Undefined()
        return DataRange1d()
    elseif ismodelinstance(range, Range)
        return range
    elseif range isa AbstractVector
        if all(x isa AbstractString for x in range)
            return FactorRange(factors=collect(String, range))
        elseif all(x isa Tuple{Vararg{AbstractString}} for x in range)
            return FactorRange(factors=collect(Tuple{Vararg{String}}, range))
        end
    elseif range isa Tuple{Any,Any}
        x0, x1 = range
        if x0 === nothing
            x0 = Undefined()
        end
        if x1 === nothing
            x1 = Undefined()
        end
        return Range1d(; :start=>x0, :end=>x1)
    end
    error("invalid range: $range")
end

function get_axis(axis, range)
    if axis === nothing
        return nothing
    elseif axis === Undefined()
        if ismodelinstance(range, DataRange1d) || ismodelinstance(range, Range1d)
            return LinearAxis()
        elseif ismodelinstance(range, FactorRange)
            return CategoricalAxis()
        else
            error("cannot determine axis for range: $range")
        end
    elseif ismodelinstance(axis, Axis)
        return axis
    end
    error("invalid axis: $axis")
end

function get_scale(scale, range, axis)
    if scale === Undefined()
        if ismodelinstance(range, DataRange1d) || ismodelinstance(range, Range1d)
            if axis===nothing || ismodelinstance(axis, LinearAxis) || ismodelinstance(axis, DatetimeAxis) || ismodelinstance(axis, MercatorAxis)
                return LinearScale()
            elseif ismodelinstance(axis, LogAxis)
                return LogScale()
            end
        elseif ismodelinstance(range, FactorRange)
            return CategoricalScale()
        end
        error("cannot determine scale for range: $range")
    elseif ismodelinstance(scale, Scale)
        return scale
    else
        error("invalid scale: $scale")
    end
end

function get_grid(grid, axis, dimension)
    if grid === nothing
        return nothing
    elseif ismodelinstance(grid, Grid)
        return grid
    elseif grid === Undefined()
        if axis === nothing
            return nothing
        else
            return Grid(; axis, dimension)
        end
    else
        error("invalid grid: $grid")
    end
end

"""
    figure(; ...)

Create a new [`Figure`](@ref) and return it.

Acceptable keyword arguments are:
- Anything taken by [`Figure`](@ref).
- `x_range`/`y_range`: Sets the x/y-range. May be a vector of factors or a 2-tuple representing an interval. Default: `DataRange1d()`.
- `x_axis`/`y_axis`: Sets the x/y-axis. May be `nothing` to suppress. Default: `LinearAxis()`.
- `x_axis_location`/`y_axis_location`: Where to put the axis. One of `"left"`, `"right"`, `"above"` or `"below"`. Default: `"below"`/`"left"`.
- `x_axis_label`/`y_axis_label`: Sets the label on the x/y-axis.
- `x_grid`/`y_grid`: Sets the x/y-grid. May be `nothing` to suppress.
- `tools`: Optional list of tools to create a toolbar from.
- `tooltips`: If given, add a [`HoverTool`](@ref) with these tooltips.
"""
function figure(;
    x_range=Undefined(),
    y_range=Undefined(),
    x_axis=Undefined(),
    y_axis=Undefined(),
    x_axis_location="below",
    y_axis_location="left",
    x_axis_label=Undefined(),
    y_axis_label=Undefined(),
    x_scale=Undefined(),
    y_scale=Undefined(),
    x_grid=Undefined(),
    y_grid=Undefined(),
    # x_minor_ticks="auto",
    # y_minor_ticks="auto",
    tools=Undefined(),
    tooltips=Undefined(),
    kw...,
)
    fig = Figure(; kw...)

    # range/axis/scale/grid
    fig.x_range = x_range = get_range(x_range)
    fig.y_range = y_range = get_range(y_range)
    x_axis = get_axis(x_axis, x_range)
    y_axis = get_axis(y_axis, y_range)
    x_axis_label !== nothing && x_axis !== nothing && setproperty!(x_axis, :axis_label, x_axis_label)
    y_axis_label !== nothing && y_axis !== nothing && setproperty!(y_axis, :axis_label, y_axis_label)
    fig.x_scale = x_scale = get_scale(x_scale, x_range, x_axis)
    fig.y_scale = y_scale = get_scale(y_scale, y_range, y_axis)
    x_grid = get_grid(x_grid, x_axis, 0)
    y_grid = get_grid(y_grid, y_axis, 1)
    x_axis !== nothing && x_axis_location !== nothing && plot!(fig, x_axis, location=x_axis_location)
    y_axis !== nothing && y_axis_location !== nothing && plot!(fig, y_axis, location=y_axis_location)
    x_grid !== nothing && plot!(fig, x_grid)
    y_grid !== nothing && plot!(fig, y_grid)

    # tools
    if tools === Undefined()
        fig.toolbar.tools = [PanTool(), BoxZoomTool(), WheelZoomTool(), SaveTool(), ResetTool(), HelpTool()]
    else
        fig.toolbar.tools = tools
    end
    if tooltips !== Undefined()
        plot!(fig, HoverTool; tooltips)
    end

    return fig
end

"""
    plot!(plot, item; ...)
    plot!(plot, type; ...)

Adds a new item to the plot, or an item of the given type.

When passing a type, the allowed keyword arguments include anything accepted by the type.
Some additional arguments are allowed depending on what `item` or `type` is.

The constructed item is returned. In the case of glyphs, the corresponding
[`GlyphRenderer`](@ref) is returned instead.

## Glyphs

Additional keyword arguments:
- Anything accepted by [`GlyphRenderer`](@ref).
- `source`: Alias for `data_source`. May be a [`DataSource`](@ref), `Dict` of columns, or a
  `Tables.jl`-style table.
- `color`: Alias for all the `*_color` properties.
- `alpha`: Alias for all the `*_alpha` properties.
- `palette`: If the glyph has a `color_mapper` property, it is set to a
  [`LinearColorMapper`](@ref) with this palette.
- `legend_label`
- `legend_field`
- `legend_group`
- `filters`: List of filters to apply to the source data.

## Renderers

This includes axes, grids, legends and other annotations.

Additional keyword arguments:
- `location`: One of `"center"` (default), `"left"`, `"right"`, `"below"` or `"above"`.
- `dimension`: For axes, you must specify either the `location` or `dimension` and the other
  one is inferred.

## Tools

Additional keyword arguments:
- `activate`: If true, then set the tool as the active one of its kind on the toolbar.
"""
function plot!(plot::ModelInstance, t::ModelType; kw...)
    return _plot!(plot, t, collect(Kwarg, kw))
end
function plot!(plot::ModelInstance, x::ModelInstance; kw...)
    return _plot!(plot, x, collect(Kwarg, kw))
end

checkmodelinstance(x, t::ModelType) = ismodelinstance(x, t) || error("expecting a $(t.name)")
checkmodeltype(x::ModelType, t::ModelType) = issubmodeltype(x, t) || error("expecting a subtype of $(t.name)")

function _plot!(plot::ModelInstance, x::ModelInstance, kw::Vector{Kwarg})
    checkmodelinstance(plot, Plot)
    if ismodelinstance(x, Glyph)
        _plot_glyph!(plot, x, kw)
    elseif ismodelinstance(x, Tool)
        _plot_tool!(plot, x, kw)
    elseif ismodelinstance(x, Renderer)
        _plot_renderer!(plot, x, kw)
    else
        error("don't know how to add a $(modeltype(x).name) to a plot")
    end
end

function _plot!(plot::ModelInstance, t::ModelType, kw::Vector{Kwarg})
    checkmodelinstance(plot, Plot)
    if issubmodeltype(t, Glyph)
        _plot_glyph!(plot, t, kw)
    elseif issubmodeltype(t, Tool)
        _plot_tool!(plot, t, kw)
    elseif issubmodeltype(t, Renderer)
        _plot_renderer!(plot, t, kw)
    else
        error("don't know how to add a $(t.name) to a plot")
    end
end

function _plot_renderer!(plot::ModelInstance, item::ModelInstance; location::String="center")
    checkmodelinstance(plot, Plot)
    checkmodelinstance(item, Renderer)
    if location == "center"
        push!(plot.center, item)
    elseif location == "left"
        push!(plot.left, item)
    elseif location == "right"
        push!(plot.right, item)
    elseif location == "below"
        push!(plot.below, item)
    elseif location == "above"
        push!(plot.above, item)
    elseif location == "renderers"
        push!(plot.renderers, item)
    else
        error("invalid location: $location")
    end
    return item
end

function _plot_renderer!(plot::ModelInstance, item::ModelInstance, kw::Vector{Kwarg})
    location = "center"
    for (k,v) in kw
        if k == :location
            v isa String || error("location must be a string")
            location = v
        else
            error("invalid argument: $k")
        end
    end
    _plot_renderer!(plot, item; location)
end

function _plot_renderer!(plot::ModelInstance, type::ModelType, kw::Vector{Kwarg})
    checkmodelinstance(plot, Plot)
    checkmodeltype(type, Renderer)
    kw, oldkw = Kwarg[], kw
    location = "center"
    for (k, v) in oldkw
        if k == :location
            location = v
        else
            push!(kw, Kwarg(k, v))
        end
    end
    item = ModelInstance(type, kw)
    _plot_renderer!(plot, item, [Kwarg(:location, location)])
    return item
end

function _plot_glyph!(plot::ModelInstance, glyph::ModelInstance, kw::Vector{Kwarg})
    checkmodelinstance(plot, Plot)
    checkmodelinstance(glyph, Glyph)
    # process the kwargs
    kw, oldkw = [Kwarg(:glyph, glyph)], kw
    legend_kwarg = nothing
    for (k, v) in oldkw
        if k in (:source, :data_source)
            # source -> data_source
            if v === Undefined() || v isa ModelInstance
                push!(kw, Kwarg(:data_source, v))
            else
                push!(kw, Kwarg(:data_source, ColumnDataSource(data=v)))
            end
        elseif haskey(GlyphRenderer.propdescs, k)
            # arguments for the renderer
            push!(kw, Kwarg(k, v))
        elseif k == :filters
            push!(kw, Kwarg(k, v))
        elseif k in (:legend_label, :legend_field, :legend_group)
            legend_kwarg === nothing || error("$(legend_kwarg[1]) and $k are mutually exclusive")
            legend_kwarg = Kwarg(k, v)
        else
            error("invalid argument $k")
        end
    end
    # make the renderer
    renderer = _glyph_renderer(kw)
    # handle the legend
    if legend_kwarg !== nothing
        let (k, v) = legend_kwarg
            # get or create the legend
            legends = plot.legends
            if isempty(legends)
                legend = plot!(plot, Legend)
            elseif length(legends) == 1
                legend = legends[1]::ModelInstance
            else
                error("$k: more than one legend in use")
            end
            # update the legend
            if k == :legend_label
                v isa AbstractString || error("$k: expecting a string")
                v = convert(String, v)::String
                label = Value(v)
                found = false
                for item in legend.items
                    if item.label == label
                        push!(item.renderers, renderer)
                        found = true
                        break
                    end
                end
                if !found
                    item = LegendItem(label=label, renderers=[renderer])
                    push!(legend.items, item)
                end
            elseif k == :legend_field
                v isa AbstractString || error("$k: expecting a string")
                v = convert(String, v)::String
                label = Field(v)
                found = false
                for item in legend.items
                    if item.label == label
                        push!(item.renderers, renderer)
                        found = true
                        break
                    end
                end
                if !found
                    item = LegendItem(label=label, renderers=[renderer])
                    push!(legend.items, item)
                end
            elseif k == :legend_group
                v isa AbstractString || error("$k: expecting a string")
                v = convert(String, v)::String
                source = renderer.data_source
                if source === Undefined()
                    error("$k: requires source to be set")
                end
                source::ModelInstance
                if !(hasproperty(source, :column_names) && v in source.column_names)
                    error("$k: source does not contain column $(repr(vstr))")
                end
                column = source.data[v]
                uniq = Dict(x=>(i-1) for (i,x) in enumerate(column))
                for (val, ind) in uniq
                    label = Value(string(val))
                    item = LegendItem(label=label, renderers=[renderer], index=ind)
                    push!(legend.items, item)
                end
            else
                @assert false
            end
        end
    end
    # finally add the renderer
    push!(plot.renderers, renderer)
    return renderer
end

function _plot_glyph!(plot::ModelInstance, type::ModelType, kw::Vector{Kwarg})
    checkmodelinstance(plot, Plot)
    checkmodeltype(type, Glyph)
    # process the kwargs
    kw, oldkw = Kwarg[], kw
    kw0 = Kwarg[] # properties that should appear first
    rkw = Kwarg[]
    have_source = false
    for (k, v) in oldkw
        if k in (:source, :data_source)
            # source -> data_source
            have_source = true
            if v === Undefined() || v isa ModelInstance
                push!(rkw, Kwarg(:data_source, v))
            else
                push!(rkw, Kwarg(:data_source, ColumnDataSource(data=v)))
            end
        elseif haskey(type.propdescs, k)
            # arguments for the glyph
            push!(kw, Kwarg(k, v))
        elseif k == :color
            # color -> fill_color, etc
            for k2 in (:fill_color, :line_color, :hatch_color, :text_color)
                haskey(type.propdescs, k2) && push!(kw0, Kwarg(k2, v))
            end
        elseif k == :alpha
            # alpha -> fill_alpha, etc
            for k2 in (:fill_alpha, :line_alpha, :hatch_alpha, :text_alpha)
                haskey(type.propdescs, k2) && push!(kw0, Kwarg(k2, v))
            end
        elseif k == :palette && haskey(type.propdescs, :color_mapper)
            # palette -> color_mapper
            push!(kw, Kwarg(:color_mapper, LinearColorMapper(palette=v)))
        else
            push!(rkw, Kwarg(k, v))
        end
    end
    kw = vcat(kw0, kw)
    # if we haven't seen a source argument, create one by collecting all the dataspec
    # arguments which are vectors, replacing the argument with a Field.
    if !have_source
        kw, oldkw = Kwarg[], kw
        data = Dict{String,AbstractVector}()
        for (k, v) in oldkw
            d = get(type.propdescs, k, nothing)
            if d isa PropDesc && d.kind == TYPE_K && (d.type::PropType).prim == DATASPEC_T && v isa AbstractVector
                data[string(k)] = v
                push!(kw, Kwarg(k, Field(string(k))))
            else
                push!(kw, Kwarg(k, v))
            end
        end
        source = ColumnDataSource(data=data)
        push!(rkw, Kwarg(:data_source, source))
    end
    # make the glyph and renderer
    glyph = ModelInstance(type, kw)
    return _plot_glyph!(plot, glyph, rkw)
end

function _glyph_renderer(kw::Vector{Kwarg})
    kw, oldkw = Kwarg[], kw
    filters = Undefined()
    for (k, v) in oldkw
        if k == :filters
            filters = v
        elseif k == :source
            push!(kw, Kwarg(:data_source, v))
        else
            push!(kw, Kwarg(k, v))
        end
    end
    renderer = ModelInstance(GlyphRenderer, kw)
    if renderer.view === Undefined()
        renderer.view = ModelInstance(CDSView, [Kwarg(:source, renderer.data_source), Kwarg(:filters, filters)])
    end
    return renderer
end

function _plot_tool!(plot::ModelInstance, tool::ModelInstance; activate::Bool=false)
    checkmodelinstance(plot, Plot)
    checkmodelinstance(tool, Tool)
    toolbar = plot.toolbar::ModelInstance
    push!(plot.toolbar.tools, tool)
    if activate
        if ismodelinstance(tool, Drag)
            toolbar.active_drag = tool
        elseif ismodelinstance(tool, InspectTool)
            oldtool = toolbar.active_inspect
            if oldtool isa ModelInstance
                toolbar.active_inspect = [oldtool, tool]
            elseif oldtool isa AbstractVector
                push!(oldtool, tool)
            else
                toolbar.active_inspect = tool
            end
        elseif ismodelinstance(tool, Scroll)
            toolbar.active_scroll = tool
        elseif ismodelinstance(tool, Tap)
            toolbar.active_tap = tool
        elseif ismodelinstance(tool, GestureTool)
            toolbar.active_multi = tool
        else
            error("cannot activate a $(type.name)")
        end
    end
    return tool
end

function _plot_tool!(plot::ModelInstance, tool::ModelInstance, kw::Vector{Kwarg})
    activate = false
    for (k, v) in kw
        if k == :activate
            v isa Bool || error("activate must be a bool")
            activate = v
        else
            error("invalid argument: $k")
        end
    end
    return _plot_tool!(plot, tool; activate)
end

function _plot_tool!(plot::ModelInstance, type::ModelType, kw::Vector{Kwarg})
    checkmodelinstance(plot, Plot)
    checkmodeltype(type, Tool)
    kw, oldkw = Kwarg[], kw
    activate = false
    for (k, v) in oldkw
        if k == :activate
            v isa Bool || error("activate must be a bool")
            activate = v
        else
            push!(kw, Kwarg(k, v))
        end
    end
    tool = ModelInstance(type, kw)
    return _plot_tool!(plot, tool; activate)
end

### LAYOUT

_layoutdom_has_auto_sizing(x) = x.sizing_mode === nothing && x.width_policy == "auto" && x.height_policy == "auto"

function _rowcol_handle_child_sizing(children, sizing_mode)
    for child in children
        ismodelinstance(child, LayoutDOM) || error("child must be a LayoutDOM, got a $(modeltype(child).name)")
        if sizing_mode !== Undefined() && sizing_mode !== nothing && _layoutdom_has_auto_sizing(child)
            child.sizing_mode = sizing_mode
        end
    end
end

"""
    row(items; ...)
    row(items...; ...)

Create a new [`Row`](@ref) with the given items.
"""
function row(children::AbstractVector; sizing_mode=Undefined(), kw...)
    all(m->ismodelinstance(m, LayoutDOM)) || error("all children must be LayoutDOM instances")
    _rowcol_handle_child_sizing(children, sizing_mode)
    return Row(; children, sizing_mode, kw...)
end
row(children::ModelInstance...; kw...) = row(collect(ModelInstance, children); kw...)

"""
    column(items; ...)
    column(items...; ...)

Create a new [`Column`](@ref) with the given items.
"""
function column(children::AbstractVector; sizing_mode=Undefined(), kw...)
    all(m->ismodelinstance(m, LayoutDOM)) || error("all children must be LayoutDOM instances")
    _rowcol_handle_child_sizing(children, sizing_mode)
    return Column(; children, sizing_mode, kw...)
end
column(children::ModelInstance...; kw...) = column(collect(ModelInstance, children); kw...)

"""
    widgetbox(items; ...)
    widgetbox(items...; ...)

Create a new [`WidgetBox`](@ref) with the given items.
"""
function widgetbox(children::AbstractVector; sizing_mode=Undefined(), kw...)
    all(m->ismodelinstance(m, Widget)) || error("all children must be Widget instances")
    _rowcol_handle_child_sizing(children, sizing_mode)
    return WidgetBox(; children, sizing_mode, kw...)
end

"""
    gridplot(items; ...)
    gridplot(items...; ...)

Arrange the given `items` into a grid.

The `items` must be a matrix or vector of layoutable models (such as plots). An item may
also be `nothing` to skip that cell.

### Keyword arguments
- `merge_tools=true`: When true, toolbars of constituent plots are merged into one.
- `toolbar_location="above"`: Where to place the merged toolbar. May be `nothing`.
- `toolbar_options`: A named tuple of options for the merged toolbar.
- `sizing_mode`: The sizing mode of the resulting grid.
- `width`: The width of each item.
- `height`: The height of each item.
- `ncols`: When `items` is a vector, they are arranged into a grid with this number of columns.
"""
function gridplot(
    items::AbstractMatrix;
    merge_tools=true,
    width=nothing,
    height=nothing,
    sizing_mode=Undefined(),
    toolbar_location="above",
    toolbar_options=NamedTuple(),
)
    toolbars = ModelInstance[]
    children = Tuple{ModelInstance,Int,Int}[]
    for (i, row) in enumerate(eachrow(items))
        for (j, item) in enumerate(row)
            if item === nothing
                continue
            elseif ismodelinstance(item, LayoutDOM)
                if merge_tools && ismodelinstance(item, Plot)
                    # TODO: implement select, so we can find all subplots
                    push!(toolbars, item.toolbar)
                    item.toolbar_location = nothing
                end
                if width !== nothing
                    item.width = width
                end
                if height !== nothing
                    item.height = height
                end
                if sizing_mode !== Undefined() && _layoutdom_has_auto_sizing(item)
                    item.sizing_mode = sizing_mode
                end
                push!(children, (item, i-1, j-1))
            else
                error("items[$j, $i]: expecting a LayoutDOM or nothing")
            end
        end
    end
    if !merge_tools || toolbar_location === nothing
        return GridBox(; children, sizing_mode)
    else
        grid = GridBox(; children)
        tools = [tool for toolbar in toolbars for tool in toolbar.tools]
        toolbar = ProxyToolbar(; toolbars, tools, toolbar_options...)
        toolbar = ToolbarBox(; toolbar, toolbar_location)
        if toolbar_location == "above"
            return Column(; children=[toolbar, grid], sizing_mode)
        elseif toolbar_location == "below"
            return Column(; children=[grid, toolbar], sizing_mode)
        elseif toolbar_location == "left"
            return Row(; children=[toolbar, grid], sizing_mode)
        elseif toolbar_location == "right"
            return Row(; children=[grid, toolbar], sizing_mode)
        else
            error("toolbar_location: expecting \"above\", \"below\", \"left\" or \"right\"")
        end
    end
end
function gridplot(children::AbstractVector; ncols=1, kw...)
    nrows = cld(length(children), ncols)
    grid = Matrix{Union{Nothing,ModelInstance}}(nothing, nrows, ncols)
    for (i, item) in enumerate(children)
        grid[div(i-1, ncols)+1, mod(i-1, ncols)+1] = item
    end
    return gridplot(grid; kw...)
end
function gridplot(children::Union{Nothing,ModelInstance}...; kw...)
    return gridplot(collect(Union{Nothing,ModelInstance}, children); kw...)
end
