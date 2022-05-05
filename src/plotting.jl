### TRANSFORMS

factor_mark(field, markers, factors; kw...) = Field(field, transform=CategoricalMarkerMapper(; markers, factors, kw...))
export factor_mark

factor_cmap(field, palette, factors; kw...) = Field(field, transform=CategoricalColorMapper(; palette, factors, kw...))
export factor_cmap


### FIGURE

function get_range(range)
    if range === nothing
        return DataRange1d()
    elseif range isa Model && ismodelinstance(range, Range)
        return range
    elseif range isa Union{Tuple,AbstractVector}
        if all(x isa AbstractString for x in range)
            return FactorRange(factors=collect(String, range))
        elseif length(x) == 2
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
    if range isa Model && (ismodelinstance(range, DataRange1d) || ismodelinstance(range, Range1d))
        if (axis_type===nothing || axis_type in ("linear", "datetime", "mercator", "auto"))
            return LinearScale()
        elseif axis_type == "log"
            return LogScale()
        end
    elseif range isa Model && ismodelinstance(range, FactorRange)
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
        if rng isa Model && ismodelinstance(rng, FactorRange)
            return CategoricalAxis()
        elseif rng isa Model && ismodelinstance(rng, Range1d)
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
        add_renderer!(plot, :center, grid)
        if axis_location !== nothing
            add_renderer!(plot, Symbol(axis_location), axis)
        end
    end
end

function figure(; x_range=nothing, y_range=nothing, x_axis_type="auto", y_axis_type="auto", x_axis_location="below", y_axis_location="left", x_minor_ticks="auto", y_minor_ticks="auto", x_axis_label="", y_axis_label="", tools=nothing, kw...)
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

    return fig
end
export figure

### PLOTS

function add_renderer!(plot::Model, loc::Symbol, renderer::Model)
    ismodelinstance(plot, Plot) || error("plot must be a Plot")
    ismodelinstance(renderer, Renderer) || error("renderer must be a Renderer")
    loc in (:renderers, :left, :right, :above, :below, :center) || error("loc must be :left, :right, :above, :below, :center or :renderers")
    push!(getproperty(plot, loc), renderer)
    return plot
end
export add_renderer!

function add_glyph!(plot::Model, source::Model, glyph::Model; kw...)
    ismodelinstance(plot, Plot) || error("plot must be a Plot")
    ismodelinstance(source, DataSource) || error("source must be a DataSource")
    ismodelinstance(glyph, Glyph) || error("glyph must be a Glyph")
    renderer = GlyphRenderer(; data_source=source, glyph=glyph, kw...)
    if renderer.view === Undefined()
        renderer.view = CDSView(source=source)
    end
    push!(plot.renderers, renderer)
    return plot
end
export add_glyph!

function add_tools!(plot::Model, tools; active::Bool=false)
    ismodelinstance(plot, Plot) || error("plot must be a Plot")
    toolbar = plot.toolbar::Model
    for tool in collect(Model, tools)
        ismodelinstance(tool, Tool) || error("tool must be a Tool")
        push!(toolbar.tools, tool)
        if active
            if ismodelinstance(tool, Drag)
                toolbar.active_drag = tool
            elseif ismodelinstance(tool, InspectTool)
                oldtool = toolbar.active_inspect
                if oldtool isa Model
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
add_tools!(plot::Model, tools::Model...; kw...) = add_tools!(plot, tools; kw...)
export add_tools!

for t in [:Scatter]
    f = Symbol(lowercase(string(t)), "!")
    @eval function $f(plot::Model, source::Model;
            color=Undefined(),
            line_color=color,
            fill_color=color,
            hatch_color=color,
            alpha=Undefined(),
            line_alpha=alpha,
            fill_alpha=alpha,
            hatch_alpha=alpha,
            kw...,
        )
        glyph = $t(; line_color, fill_color, hatch_color, line_alpha, fill_alpha, hatch_alpha, kw...)
        add_glyph!(plot, source, glyph)
        return glyph
    end
    @eval export $f
end

for t in [:Line]
    f = Symbol(lowercase(string(t)), "!")
    @eval function $f(plot::Model, source::Model;
            color=Undefined(),
            line_color=color,
            alpha=Undefined(),
            line_alpha=alpha,
            kw...,
        )
        glyph = $t(; line_color, line_alpha, kw...)
        add_glyph!(plot, source, glyph)
        return glyph
    end
    @eval export $f
end

for t in [:LinearAxis, :LogAxis, :CategoricalAxis, :DateTimeAxis, :MercatorAxis]
    f = Symbol(lowercase(string(t)), "!")
    @eval function $f(plot::Model, loc::Symbol; kw...)
        axis = $t(; kw...)
        add_renderer!(plot, loc, axis)
        return axis
    end
    @eval export $f
end

for t in [:Grid]
    f = Symbol(lowercase(string(t)), "!")
    @eval function $f(plot::Model, axis::Model, dimension::Integer; kw...)
        grid = $t(; axis, dimension, kw...)
        add_renderer!(plot, :center, grid)
        return grid
    end
    @eval export $f
end

for t in [:PanTool, :RangeTool, :WheelPanTool, :WheelZoomTool, :SaveTool, :ResetTool,
    :TapTool, :CrosshairTool, :BoxZoomTool, :ZoomInTool, :ZoomOutTool, :BoxSelectTool,
    :LassoSelectTool, :PolySelectTool, :HelpTool,
]
    f = Symbol(lowercase(string(t)), "!")
    @eval function $f(plot::Model; active::Bool=false, kw...)
        tool = $t(; kw...)
        add_tools!(plot, tool; active)
        return tool
    end
    @eval export $f
end
