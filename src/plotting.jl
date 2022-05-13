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
    if range === nothing
        return DataRange1d()
    elseif range isa ModelInstance && ismodelinstance(range, Range)
        return range
    elseif range isa Union{Tuple,AbstractVector}
        if all(x isa AbstractString for x in range)
            return FactorRange(factors=collect(String, range))
        elseif all(x isa Tuple{Vararg{AbstractString}} for x in range)
            return FactorRange(factors=collect(Tuple{Vararg{String}}, range))
        elseif length(range) == 2
            x0, x1 = x
            if x0 === nothing
                x0 = Undefined()
            end
            if x1 === nothing
                x1 = Undefined()
            end
            return Range1d(; :start=>x0, :end=>x1)
        end
    end
    error("unrecognized range input: $range")
end

function get_scale(range, axis_type)
    if range isa ModelInstance && (ismodelinstance(range, DataRange1d) || ismodelinstance(range, Range1d))
        if (axis_type===nothing || axis_type in ("linear", "datetime", "mercator", "auto"))
            return LinearScale()
        elseif axis_type == "log"
            return LogScale()
        end
    elseif range isa ModelInstance && ismodelinstance(range, FactorRange)
        return CategoricalScale()
    end
    error("unable to determine proper scale for $range")
end

function get_axis(axis_type, rng, dim)
    if axis_type === nothing
        return nothing
    elseif axis_type == "linear"
        return LinearAxis()
    elseif axis_type == "log"
        return LogAxis()
    elseif axis_type == "datetime"
        return DatetimeAxis()
    elseif axis_type == "mercator"
        return MercatorAxis(dimension= dim==0 ? "lon" : "lat")
    elseif axis_type == "auto"
        if rng isa ModelInstance && ismodelinstance(rng, FactorRange)
            return CategoricalAxis()
        elseif rng isa ModelInstance && ismodelinstance(rng, Range1d)
            # TODO: maybe a datetime axis
            return LinearAxis()
        else
            return LinearAxis()
        end
    else
        error("invalid axis type: $(repr(axis_type))")
    end
end

function process_axis_and_grid(plot, axis_type, axis_location, minor_ticks, axis_label, rng, dim)
    axis = get_axis(axis_type, rng, dim)
    if axis !== nothing
        # TODO: ticker
        if axis_label !== nothing && axis_label != ""
            axis.axis_label = axis_label
        end
        grid = Grid(dimension=dim, axis=axis)
        add_layout!(plot, grid)
        if axis_location !== nothing
            add_layout!(plot, axis; location=axis_location)
        end
    end
end

"""
    figure(; ...)

Create a new [`Figure`](@ref) and return it.

Acceptable keyword arguments are:
- Anything taken by [`Figure`](@ref).
- `x_range`/`y_range`: Sets the x/y-range. May be a vector of factors or a 2-tuple representing an interval.
- `x_axis_type`/`y_axis_type`: The type of axis. One of `"linear"`, `"log"`, `"datetime"`, `"mercator"`, `"auto"` or `nothing` (for no axis).
- `x_axis_location`/`y_axis_location`: Where to put the axis. One of `"left"`, `"right"`, `"above"` or `"below"`.
- `x_axis_label`/`y_axis_label`: The label to show on the axis.
- `tools`: Optional list of tools to create a toolbar from.
- `tooltips`: If given, add a [`HoverTool`](@ref) with these tooltips.
"""
function figure(;
    x_range=nothing,
    y_range=nothing,
    x_axis_type="auto",
    y_axis_type="auto",
    x_axis_location="below",
    y_axis_location="left",
    x_minor_ticks="auto",
    y_minor_ticks="auto",
    x_axis_label="",
    y_axis_label="",
    tools=nothing,
    tooltips=nothing,
    kw...,
)
    fig = Figure(; kw...)
    # ranges
    fig.x_range = get_range(x_range)
    fig.y_range = get_range(y_range)
    # scales
    fig.x_scale = get_scale(fig.x_range, x_axis_type)
    fig.y_scale = get_scale(fig.y_range, y_axis_type)
    # axes/grids
    process_axis_and_grid(fig, x_axis_type, x_axis_location, x_minor_ticks, x_axis_label, fig.x_range, 0)
    process_axis_and_grid(fig, y_axis_type, y_axis_location, y_minor_ticks, y_axis_label, fig.y_range, 1)
    # tools
    if tools === nothing
        add_tools!(fig, PanTool(), BoxZoomTool(), WheelZoomTool(), SaveTool(), ResetTool(), HelpTool())
    else
        add_tools!(fig, tools)
    end
    if tooltips !== nothing
        add_tools!(fig, HoverTool(tooltips=tooltips))
    end

    return fig
end


### RENDERERS

function add_layout!(plot::ModelInstance, renderer::ModelInstance; location="center")
    ismodelinstance(plot, Plot) || error("plot must be a Plot")
    ismodelinstance(renderer, Renderer) || error("renderer must be a Renderer")
    if location == "left"
        push!(plot.left, renderer)
    elseif location == "right"
        push!(plot.right, renderer)
    elseif location == "below"
        push!(plot.below, renderer)
    elseif location == "above"
        push!(plot.above, renderer)
    elseif location == "center"
        push!(plot.center, renderer)
    else
        error("invalid location")
    end
    return renderer
end

for (t, f) in [
    (LinearAxis, :linear_axis!),
    (LogAxis, :log_axis!),
    (CategoricalAxis, :categorical_axis!),
    (DatetimeAxis, :datetime_axis!),
    (MercatorAxis, :mercator_axis!),
]
    @eval function $f(plot::ModelInstance; location, kw...)
        axis = $t(; kw...)
        add_layout!(plot, axis; location)
        return axis
    end
    @eval @doc $("""
        $f(plot; location, ...)

    Add a [`$(t.name)`](@ref) to the given plot and return it.

    The `location` must be one of `"left"`, `"right"`, `"above"` or `"below"`.
    """) $f
    @eval export $f
end

for (t, f) in [
    (Grid, :grid!)
]
    @eval function $f(plot::ModelInstance; axis::ModelInstance, dimension::Integer, kw...)
        grid = $t(; axis, dimension, kw...)
        add_layout!(plot, grid)
        return grid
    end
    @eval @doc $("""
        $f(plot; axis, dimension, ...)

    Add a [`$(t.name)`](@ref) to the given plot and return it.

    You must specify the `axis` and `dimension` (0 for x, 1 for y) it relates to.
    """) $f
    @eval export $f
end

for (t, f) in [
    (PanTool, :pan_tool!),
    (RangeTool, :range_tool!),
    (WheelPanTool, :wheelpan_tool!),
    (WheelZoomTool, :wheelzoom_tool!),
    (SaveTool, :save_tool!),
    (ResetTool, :reset_tool!),
    (TapTool, :tap_tool!),
    (CrosshairTool, :crosshair_tool!),
    (BoxZoomTool, :boxzoom_tool!),
    (ZoomInTool, :zoomin_tool!),
    (ZoomOutTool, :zoomout_tool!),
    (BoxSelectTool, :boxselect_tool!),
    (LassoSelectTool, :lassoselect_tool!),
    (PolySelectTool, :polyselect_tool!),
    (HelpTool, :help_tool!),
]
    @eval function $f(plot::ModelInstance; active::Bool=false, kw...)
        tool = $t(; kw...)
        add_tools!(plot, tool; active)
        return tool
    end
    @eval @doc $("""
        $f(plot; active=false, ...)

    Add a [`$(t.name)`](@ref) to the given plot and return it.

    If `active=true` then the tool becomes the active one of its kind.
    """) $f
    @eval export $f
end


### GLYPHS

function _glyph_renderer_kw(glyph::ModelInstance, kw::Vector{Kwarg})
    ismodelinstance(glyph, Glyph) || error("glyph must be a Glyph")
    filters = Undefined()
    for (k, v) in (oldkw=kw; kw=Kwarg[]; oldkw)
        if k == :filters
            filters = v
        elseif k == :source
            push!(kw, Kwarg(:data_source, v))
        else
            push!(kw, Kwarg(k, v))
        end
    end
    renderer = ModelInstance(GlyphRenderer, [Kwarg(:glyph, glyph); kw])
    if renderer.view === Undefined()
        renderer.view = ModelInstance(CDSView, [Kwarg(:source, renderer.data_source), Kwarg(:filters, filters)])
    end
    return renderer
end

function add_glyph_kw!(plot::ModelInstance, glyph::ModelInstance, kw::Vector{Kwarg})
    ismodelinstance(plot, Plot) || error("plot must be a Plot")
    renderer = _glyph_renderer_kw(glyph, kw)
    push!(plot.renderers, renderer)
    return renderer
end

function add_glyph_kw!(plot::ModelInstance, type::ModelType, kw::Vector{Kwarg})
    ismodelinstance(plot, Plot) || error("plot must be a Plot")
    issubmodeltype(type, Glyph) || error("type must be a subtype of Glyph")
    # process the kwargs
    kw, oldkw = Kwarg[], kw
    rkw = Kwarg[]
    have_source = false
    legend_kwarg = nothing
    for (k, v) in oldkw
        if k in (:source, :data_source)
            # source -> data_source
            have_source = true
            if v === Undefined() || v isa ModelInstance
                push!(rkw, Kwarg(:data_source, v))
            else
                push!(rkw, Kwarg(:data_source, ColumnDataSource(data=v)))
            end
        elseif haskey(GlyphRenderer.propdescs, k)
            # arguments for the renderer
            push!(rkw, Kwarg(k, v))
        elseif haskey(type.propdescs, k)
            # arguments for the glyph
            push!(kw, Kwarg(k, v))
        elseif k == :filters
            push!(rkw, Kwarg(k, v))
        elseif k == :color
            # color -> fill_color, etc
            for k2 in (:fill_color, :line_color, :hatch_color)
                haskey(type.propdescs, k2) && push!(kw, Kwarg(k2, v))
            end
        elseif k == :alpha
            # alpha -> fill_alpha, etc
            for k2 in (:fill_alpha, :line_alpha, :hatch_alpha)
                haskey(type.propdescs, k2) && push!(kw, Kwarg(k2, v))
            end
        elseif k == :palette && haskey(type.propdescs, :color_mapper)
            # palette -> color_mapper
            push!(kw, Kwarg(:color_mapper, LinearColorMapper(palette=v)))
        elseif k in (:legend_label, :legend_field, :legend_group)
            legend_kwarg === nothing || error("$(legend_kwarg[1]) and $k are mutually exclusive")
            legend_kwarg = Kwarg(k, v)
        else
            error("invalid argument $k")
        end
    end
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
    renderer = _glyph_renderer_kw(glyph, rkw)
    # handle the legend
    if legend_kwarg !== nothing
        let (k, v) = legend_kwarg
            # get or create the legend
            legends = plot.legends
            if isempty(legends)
                legend = Legend()
                add_layout!(plot, legend)
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

function add_glyph!(plot::ModelInstance, glyph::ModelInstance; kw...)
    @nospecialize
    return add_glyph_kw!(plot, glyph, collect(Kwarg, kw))
end

function add_glyph!(plot::ModelInstance, type::ModelType; kw...)
    @nospecialize
    return add_glyph_kw!(plot, type, collect(Kwarg, kw))
end

for (f, t) in [
    (:annular_wedge!, AnnularWedge),
    (:annulus!, Annulus),
    (:arc!, Arc),
    (:bezier!, Bezier),
    (:circle!, Circle),
    (:ellipse!, Ellipse),
    (:harea!, HArea),
    (:hbar!, HBar),
    (:hextile!, HexTile),
    (:image!, Image),
    (:image_rgba!, ImageRGBA),
    (:image_url!, ImageURL),
    (:line!, Line),
    (:multi_line!, MultiLine),
    (:multi_polygons!, MultiPolygons),
    (:oval!, Oval),
    (:patch!, Patch),
    (:patches!, Patches),
    (:quad!, Quad),
    (:quadratic!, Quadratic),
    (:ray!, Ray),
    (:rect!, Rect),
    (:scatter!, Scatter),
    (:segment!, Segment),
    (:step!, Step),
    (:text!, Text),
    (:varea!, VArea),
    (:vbar!, VBar),
    (:wedge!, Wedge),
]
    @eval function $f(plot::ModelInstance; kw...)
        @nospecialize
        return add_glyph_kw!(plot, $t, collect(Kwarg, kw))
    end
    @eval export $f
    @eval @doc $("""
        $f(plot; kw...)

    Adds a [`$(t.name)`](@ref) to the given `plot`.

    If you do not specify any `source` data, then a data source is created from all the
    data arguments which are vectors.

    # Keyword arguments
    - Anything accepted by [`$(t.name)`](@ref).
    - Anything accepted by [`GlyphRenderer`](@ref).
    - `source`: Shorthand for `data_source`. May be a [`ColumnDataSource`](@ref), `Dict` or
      Tables.jl-compatible table.
    - `color`: Shorthand for all `*_color` properties.
    - `alpha`: Shorthand for all `*_alpha` properties.
    - `palette`: Sets a color mapper with this palette.
    - `legend_label`: Adds an item to the legend with the given label.
    - `legend_field`: Adds items to the legend from the given field.
    - `legend_group`: Adds items to the legend grouping on the given field.
    - `filters`: A vector of filters to select a subset of the data.
    """) $f
end

function add_tools!(plot::ModelInstance, tools::Vector{ModelInstance}; active::Bool=false)
    ismodelinstance(plot, Plot) || error("plot must be a Plot")
    toolbar = plot.toolbar::ModelInstance
    for tool in tools
        ismodelinstance(tool, Tool) || error("tool must be a Tool")
        push!(toolbar.tools, tool)
        if active
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
                toolbar.active_scroll = tool
            elseif ismodelinstance(tool, GestureTool)
                toolbar.active_scroll = tool
            else
                @warn "cannot automatically activate $(modeltype(tool).name) tool"
            end
        end
    end
    return plot
end
add_tools!(plot::ModelInstance, tools; kw...) = add_tools!(plot, collect(ModelInstance, tools); kw...)
add_tools!(plot::ModelInstance, tools::ModelInstance...; kw...) = add_tools!(plot, collect(ModelInstance, tools); kw...)


### LAYOUT

_layoutdom_has_auto_sizing(x) = x.sizing_mode === nothing && x.width_policy == "auto" && x.height_policy == "auto"

function _rowcol_handle_child_sizing(children, sizing_mode)
    for child in children
        ismodelinstance(child, LayoutDOM) || error("child must be a LayoutDOM, got a $(modeltype(child).name)")
        if sizing_mode !== nothing && _layoutdom_has_auto_sizing(child)
            child.sizing_mode = sizing_mode
        end
    end
end

"""
    row(items; ...)
    row(items...; ...)

Create a new [`Row`](@ref) with the given items.
"""
function row(children; sizing_mode=nothing, kw...)
    children = collect(ModelInstance, children)
    _rowcol_handle_child_sizing(children, sizing_mode)
    return Row(; children, sizing_mode, kw...)
end
row(children::ModelInstance...; kw...) = row(children; kw...)

"""
    column(items; ...)
    column(items...; ...)

Create a new [`Column`](@ref) with the given items.
"""
function column(children; sizing_mode=nothing, kw...)
    children = collect(ModelInstance, children)
    _rowcol_handle_child_sizing(children, sizing_mode)
    return Column(; children, sizing_mode, kw...)
end
column(children::ModelInstance...; kw...) = column(children; kw...)
