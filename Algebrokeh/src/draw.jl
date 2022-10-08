function _get_palette(p, n=nothing)
    if p isa AbstractString
        # get a named palette
        pname = p
        p = get(Bokeh.PALETTES, pname, nothing)
        if p === nothing
            # get a named palette group
            pg = get(Bokeh.PALETTE_GROUPS, pname, nothing)
            pg === nothing && error("no such palette: $(pname)")
            isempty(pg) && error("empty palette group: $(pname)")
            p = _get_palette(pg, n)
        end
    elseif p isa AbstractDict
        # palette group (length -> palette)
        pg = p
        isempty(pg) && error("empty palette group")
        pbest = nothing
        nbest = nothing
        for (ncur, pcur) in pg
            if nbest === nothing || ((n === nothing || nbest < n) ? (ncur > nbest) : (n ≤ ncur < nbest))
                nbest = ncur
                pbest = pcur
            end
        end
        @assert nbest !== nothing
        @assert pbest !== nothing
        p = _get_palette(pbest, n)
    else
        p = collect(String, p)
    end
    if n !== nothing
        if length(p) < n
            p = repeat(p, cld(n, length(p)))
        end
        if length(p) > n
            p = p[1:n]
        end
        @assert length(p) == n
    end
    return p
end

function _get_markers(m, n=nothing)
    m = collect(String, m)
    if n !== nothing
        if length(m) < n
            m = repeat(m, cld(n, length(m)))
        end
        if length(m) > n
            m = m[1:n]
        end
        @assert length(m) == n
    end
    return m
end

function _get_hatch_patterns(p, n=nothing)
    return _get_markers(p, n)
end

function _get_data(data, transforms, source_cache)
    if isempty(transforms)
        return data
    else
        return get!(source_cache, (data, transforms)) do 
            data0 = _get_data(data, transforms[begin:end-1], source_cache)
            return transforms[end](data0)
        end
    end
end

function _get_property(v; data::Data, themes)
    if v isa Mapping
        # field
        field = v.field
        fieldnames = field.names
        if fieldnames isa String
            fieldname = fieldnames
        else
            # TODO: add a new combined column
            error("not implemented: hierarchical fields")
        end
        # datainfo
        datainfo = v.datainfo
        if datainfo === nothing
            datainfo = get(data.columns, fieldname, nothing)
            if datainfo === nothing
                error("no DataInfo for column $(repr(field))")
            end
        end
        datatype = datainfo.datatype
        factors = datainfo.factors
        nfactors = length(factors)
        label = v.label
        if label === nothing
            label = datainfo.label
        end
        # transforms
        transforms = copy(v.transforms)
        # mapper
        mapper = isempty(transforms) || !Bokeh.ismodelinstance(last(transforms), Bokeh.Mapper) ? nothing : last(transforms)
        if v.type == DATA_MAP
            # data is not mapped
        elseif v.type == COLOR_MAP
            if datatype == NUMBER_DATA
                if mapper === nothing
                    mapper = Bokeh.LinearColorMapper()
                    push!(transforms, mapper)
                end
                if Bokeh.ismodelinstance(mapper, Bokeh.ContinuousColorMapper)
                    if mapper.palette === Bokeh.Undefined()
                        mapper.palette = _get_palette(_get_theme(themes, "continuous_palette"))
                    end
                end
            else @assert datatype == FACTOR_DATA
                if mapper === nothing
                    mapper = Bokeh.CategoricalColorMapper()
                    push!(transforms, mapper)
                end
                if Bokeh.ismodelinstance(mapper, Bokeh.CategoricalColorMapper)
                    if mapper.palette === Bokeh.Undefined()
                        mapper.palette = _get_palette(_get_theme(themes, "categorical_palette"), nfactors)
                    end
                end
            end
        elseif v.type == MARKER_MAP
            if datatype == FACTOR_DATA
                if mapper === nothing
                    mapper = Bokeh.CategoricalMarkerMapper()
                    push!(transforms, mapper)
                end
                if Bokeh.ismodelinstance(mapper, Bokeh.CategoricalMarkerMapper)
                    if mapper.markers === Bokeh.Undefined()
                        mapper.markers = _get_markers(_get_theme(themes, "markers"), nfactors)
                    end
                end
            else
                error("$(v.name) is a marker mapping but $fields is not categorical")
            end
        else @assert v.type == HATCH_PATTERN_MAP
            if datatype == FACTOR_DATA
                if mapper === nothing
                    mapper = Bokeh.CategoricalPatternMapper()
                    push!(transforms, mapper)
                end
                if Bokeh.ismodelinstance(mapper, Bokeh.CategoricalPatternMapper)
                    mapper.patterns = _get_hatch_patterns(_get_theme(themes, "hatch_patterns"), nfactors)
                end
            else
                error("$(v.name) is a hatch-pattern mapping but $fields is not categorical")
            end
        end
        if Bokeh.ismodelinstance(mapper, Bokeh.CategoricalMapper)
            if mapper.factors === Bokeh.Undefined()
                mapper.factors = factors
            end
        end
        # done
        if length(transforms) == 0
            value = Bokeh.Field(fieldname)
        elseif length(transforms) == 1
            value = Bokeh.transform(fieldname, transforms[1])
        else
            # TODO: https://stackoverflow.com/questions/48772907/layering-or-nesting-multiple-bokeh-transforms
            error("not implemented: multiple transforms (on mapping $(v.name))")
        end
        return ResolvedProperty(; orig=v, value, label, field, fieldname, datainfo)
    else
        return ResolvedProperty(; orig=v, value=v)
    end
end

const PROPERTY_ALIASES = Dict(
    :x => [:xs, :right],
    :y => [:ys, :top],
)

function _get_axis_label(layers, keys)
    props = [v for layer in layers for (k, v) in layer.props if k in keys]
    labels = [p.label for p in props if p.label !== nothing]
    if !isempty(labels)
        return first(labels)
    end
    labels = String[string(p.field.names) for p in props if p.field !== nothing]
    if !isempty(labels)
        return join(sort(unique(labels)), " / ")
    end
    return nothing
end

function _get_range_scale_axis(layers, keys)
    props = [v for layer in layers for (k, v) in layer.props if k in keys]
    is_factor = false
    factors = []
    for v in props
        if v.datainfo.datatype == FACTOR_DATA
            is_factor = true
            union!(factors, v.datainfo.factors)
        end
    end
    if is_factor
        range = Bokeh.FactorRange(; factors)
        scale = Bokeh.CategoricalScale()
        axis = Bokeh.CategoricalAxis()
    else
        range = Bokeh.DataRange1d()
        scale = Bokeh.LinearScale()
        axis = Bokeh.LinearAxis()
    end
    axis.axis_label = _get_axis_label(layers, keys)
    return (range, scale, axis)
end

function draw(layers::Layers; themes=[])
    fig = Bokeh.Figure()

    # PLOT/RESOLVE EACH LAYER
    source_cache = Dict{Any,Data}()
    resolved = Vector{ResolvedLayer}()
    for layer in layers.layers
        # get the data
        orig_data = layer.data
        transforms = layer.transforms
        orig_data === nothing && error("no data")
        data = _get_data(orig_data, transforms, source_cache)
        source = data.source
        # get the glyph
        glyph = layer.glyph
        glyph === nothing && error("no glyph")
        # get the properties actually applicable to this type, resolving aliases too
        props = Dict{Symbol,Any}()
        for (k, v) in layer.properties
            if k in (:color, :alpha) || haskey(glyph.propdescs, k)
                props[k] = v
            elseif haskey(PROPERTY_ALIASES, k)
                for k2 in PROPERTY_ALIASES[k]
                    if haskey(glyph.propdescs, k2)
                        if !haskey(layer.properties, k2)
                            props[k2] = v
                        end
                        break
                    end
                end
            end
        end
        # resolve the properties
        props = Dict{Symbol,ResolvedProperty}(k => _get_property(v; data, themes) for (k, v) in props)
        # plot the glyph
        kw = Dict{Symbol,Any}(k => v.value for (k, v) in props)
        renderer = Bokeh.plot!(fig, glyph; source, kw...)
        # save
        push!(resolved, ResolvedLayer(; orig=layer, data, props, renderer))
    end

    # RANGES, SCALES and AXES
    fig.x_range, fig.x_scale, x_axis = _get_range_scale_axis(resolved, [:x, :xs, :right, :left])
    fig.y_range, fig.y_scale, y_axis = _get_range_scale_axis(resolved, [:y, :ys, :top, :bottom])
    Bokeh.plot!(fig, x_axis, location=_get_theme(themes, "x_axis_location"))
    Bokeh.plot!(fig, y_axis, location=_get_theme(themes, "y_axis_location"))

    # TOOLS
    fig.toolbar = Bokeh.figure().toolbar

    # LEGENDS
    # Find all layers+props for categorical mappings.
    legendinfos = Dict()
    for layer in resolved
        for (k, v) in layer.props
            v.datainfo !== nothing || continue
            v.datainfo.datatype == FACTOR_DATA || continue
            m = v.orig
            m isa Mapping || continue
            m.type in (COLOR_MAP, MARKER_MAP, HATCH_PATTERN_MAP) || continue
            push!(get!(legendinfos, (layer.orig.data.source, v.fieldname), []), (layer, v))
        end
    end
    # Generate a legend for each unique source+field combination.
    legend_location = _get_theme(themes, "legend_location")
    legend_orientation = legend_location in ("above", "below") ? "horizontal" : "vertical"
    legends = []
    for ((source, fieldname), layerprops) in legendinfos
        item = Bokeh.LegendItem(; label=Bokeh.Field(fieldname), renderers=[layer.renderer for (layer, _) in layerprops])
        items = [item]
        titles = [p.label for (_, p) in layerprops if p.label !== nothing]
        if !isempty(titles)
            title = titles[1]
        else
            title = fieldname
        end
        legend = Bokeh.Legend(; items, title, orientation=legend_orientation)
        push!(legends, (fieldname, legend))
    end
    # Plot the legends, sorted by title.
    sort!(legends, by=x->x[1])
    for (_, legend) in legends
        Bokeh.plot!(fig, legend, location=legend_location)
    end

    # TODO: COLOR BARS

    return fig
end

function draw(; kw...)
    return layer -> draw(layer; kw...)
end

function Base.display(d::Bokeh.BokehDisplay, layers::Layers)
    theme = _as_theme(get(Bokeh.setting(:theme).attrs, :Algebrokeh, nothing))
    themes = [theme]
    return display(d, draw(layers; themes))
end
