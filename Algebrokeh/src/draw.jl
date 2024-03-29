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

_factor_str(x::AbstractString) = x
_factor_str(x::Symbol) = String(x)
_factor_str(x) = string(x)

function _populate_data_source(data::Data, cols=nothing; theme)
    mv = _get_theme(theme, :missing_label)
    ov = _get_theme(theme, :other_label)
    columns = Tables.columns(data.table)
    scolumns = data.source.data
    for name in (cols === nothing ? keys(data.columns) : cols)
        info = data.columns[name]
        column = Tables.getcolumn(columns, Symbol(name))
        datatype = info.datatype
        factors = info.factors
        if datatype == FACTOR_DATA
            scolumn = [x === missing ? mv : x in factors ? _factor_str(x) : ov for x in column]
        elseif datatype == FACTOR2_DATA
            scolumn = [x === missing ? (mv, mv) : x in factors ? map(_factor_str, x) : (ov, ov) for x in column]
        elseif datatype == FACTOR3_DATA
            scolumn = [x === missing ? (mv, mv, mv) : x in factors ? map(_factor_str, x) : (ov, ov, ov) for x in column]
        else
            scolumn = [x for x in column]
        end
        scolumns[name] = scolumn
    end
    return
end

function _get_data(data, transforms; cache, theme)
    get!(cache, (data, transforms)) do 
        # apply transforms
        if isempty(transforms)
            ans = data::Data
        else
            ans = transforms[end](_get_data(data, transforms[begin:end-1]; cache, theme))::Data
        end
        # populate the data source
        if ans.table !== nothing
            _populate_data_source(ans; theme)
        end
        return ans
    end
end

function _get_property(v; data::Data, theme)
    if v isa Mapping
        # field
        field = v.field
        fieldnames = field.names
        if fieldnames isa String
            fieldname = fieldnames
        else
            Bokeh.ismodelinstance(data.source, Bokeh.ColumnDataSource) || error("hierarchical fields require a ColumnDataSource")
            n = length(fieldnames)
            @assert n ∈ (2, 3)
            data.table isa DataFrame || error("hierarchical fields require a DataFrame")
            fieldname = "##join#" * join(fieldnames, "#")
            if fieldname ∉ names(data.table)
                datainfos = map(n->data.columns[n], fieldnames)
                all(d->d.datatype == FACTOR_DATA, datainfos) || error("components of hierarchical fields must be non-hierarchical")
                newcol = collect(zip(map(n->data.table[!,n], fieldnames)...))
                data.table[!,fieldname] = newcol
                datainfo = DataInfo(;
                    datatype = n == 2 ? FACTOR2_DATA : n == 3 ? FACTOR3_DATA : @assert(false),
                    factors = any(d->d.factors === nothing, datainfos) ? nothing : n == 2 ? [x === missing || y === missing ? missing : (x, y) for x in datainfos[1].factors for y in datainfos[2].factors] : n == 3 ? [x === missing || y === missing || z === missing ? missing : (x, y, z) for x in datainfos[1].factors for y in datainfos[2].factors for z in datainfos[3].factors] : @assert(false),
                    has_other = any(d->d.has_other, datainfos),
                    has_missing = any(d->d.has_missing, datainfos),
                    label = all(d->d.label isa AbstractString, datainfos) ? join(map(d->d.label, datainfos), " / ") : nothing,
                )
                data.columns[fieldname] = datainfo
                _populate_data_source(data, [fieldname]; theme)
            end
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
        has_other = datainfo.has_other
        has_missing = datainfo.has_missing
        factors = datainfo.factors
        nfactors = factors === nothing ? 0 : length(factors) + has_other + has_missing
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
                        mapper.palette = _get_palette(@something(v.palette, _get_theme(theme, :continuous_palette)))
                    end
                end
            else @assert datatype ∈ ANY_FACTOR_DATA
                if mapper === nothing
                    mapper = Bokeh.CategoricalColorMapper()
                    push!(transforms, mapper)
                end
                if Bokeh.ismodelinstance(mapper, Bokeh.CategoricalColorMapper)
                    if mapper.palette === Bokeh.Undefined()
                        mapper.palette = _get_palette(@something(v.palette, _get_theme(theme, :categorical_palette)), nfactors)
                    end
                end
            end
        elseif v.type == MARKER_MAP
            if datatype ∈ ANY_FACTOR_DATA
                if mapper === nothing
                    mapper = Bokeh.CategoricalMarkerMapper()
                    push!(transforms, mapper)
                end
                if Bokeh.ismodelinstance(mapper, Bokeh.CategoricalMarkerMapper)
                    if mapper.markers === Bokeh.Undefined()
                        mapper.markers = _get_markers(@something(v.markers, _get_theme(theme, :markers)), nfactors)
                    end
                end
            else
                error("$(v.name) is a marker mapping but $fieldnames is not categorical")
            end
        else @assert v.type == HATCH_PATTERN_MAP
            if datatype ∈ ANY_FACTOR_DATA
                if mapper === nothing
                    mapper = Bokeh.CategoricalPatternMapper()
                    push!(transforms, mapper)
                end
                if Bokeh.ismodelinstance(mapper, Bokeh.CategoricalPatternMapper)
                    mapper.patterns = _get_hatch_patterns(@something(v.patterns, _get_theme(theme, :hatch_patterns)), nfactors)
                end
            else
                error("$(v.name) is a hatch-pattern mapping but $fieldnames is not categorical")
            end
        end
        if Bokeh.ismodelinstance(mapper, Bokeh.CategoricalMapper)
            if datatype ∈ ANY_FACTOR_DATA && mapper.factors === Bokeh.Undefined()
                mv = _get_theme(theme, :missing_label)
                ov = _get_theme(theme, :other_label)
                if datatype == FACTOR_DATA
                    mapper.factors = map(_factor_str, factors)
                    has_other && push!(mapper.factors, ov)
                    has_missing && push!(mapper.factors, mv)
                elseif datatype == FACTOR2_DATA
                    mapper.factors = map(x->map(_factor_str, x), factors)
                    has_other && push!(mapper.factors, (ov, ov))
                    has_missing && push!(mapper.factors, (mv, mv))
                else @assert datatype == FACTOR3_DATA
                    mapper.factors = map(x->map(_factor_str, x), factors)
                    has_other && push!(mapper.factors, (ov, ov, ov))
                    has_missing && push!(mapper.factors, (mv, mv, mv))
                end
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
        return ResolvedProperty(; orig=v, value, label, field, fieldname, datainfo, mapper)
    else
        return ResolvedProperty(; orig=v, value=v)
    end
end

const PROPERTY_ALIASES = Dict(
    :x => [:xs, :right],
    :y => [:ys, :top],
)

const PROPERTY_GROUPS = Dict(
    :color => [:fill_color, :line_color, :text_color, :hatch_color],
    :alpha => [:fill_alpha, :line_alpha, :text_alpha, :hatch_alpha],
)

function _get_axis_label(layers, keys)
    props = [v for layer in layers for (k, v) in layer.props if k in keys]
    labels = [p.label for p in props if p.label !== nothing]
    if !isempty(labels)
        return first(labels)
    end
    labels = String[p.field.names isa String ? p.field.names : string("(", join(p.field.names, ", "), ")") for p in props if p.field !== nothing]
    if !isempty(labels)
        return join(sort(unique(labels)), " / ")
    end
    return nothing
end

function _get_range_scale_axis_grid(layers, keys, dimension)
    # gather defined information
    props = [v for layer in layers for (k, v) in layer.props if k in keys]
    is_factor = false
    factors = []
    axis = nothing
    scale = nothing
    range = nothing
    grid = nothing
    for v in props
        if (v.datainfo.datatype ∈ ANY_FACTOR_DATA) || (v.datainfo.datatype ∈ ANY_FACTOR_DODGE_DATA)
            is_factor = true
            union!(factors, v.datainfo.factors)
        end
        if v.orig isa Mapping
            if axis === nothing
                axis = v.orig.axis
            end
            if range === nothing
                range = v.orig.range
            end
            if grid === nothing
                grid = v.orig.grid
            end
        end
    end
    # select the range
    if range === nothing
        if is_factor
            range = Bokeh.FactorRange(; factors)
        else
            range = Bokeh.DataRange1d()
        end
    end
    # select scale and axis
    if scale === nothing && axis === nothing
        if is_factor
            scale = Bokeh.CategoricalScale()
            axis = Bokeh.CategoricalAxis()
        else
            scale = Bokeh.LinearScale()
            axis = Bokeh.LinearAxis()
        end
    elseif scale === nothing
        if Bokeh.ismodelinstance(axis, Bokeh.CategoricalAxis)
            scale = Bokeh.CategoricalScale()
        elseif Bokeh.ismodelinstance(axis, Bokeh.LogAxis)
            scale = Bokeh.LogScale()
        else
            scale = Bokeh.LinearScale()
        end
    elseif axis === nothing
        if Bokeh.ismodelinstance(scale, Bokeh.CategoricalScale)
            axis = Bokeh.CategoricalAxis()
        elseif Bokeh.ismodelinstance(scale, Bokeh.LogScale)
            axis = Bokeh.LogAxis()
        else
            axis = Bokeh.LinearAxis()
        end
    end
    if axis.axis_label === nothing
        axis.axis_label = _get_axis_label(layers, keys)
    end
    # select grid (none by default)
    if grid !== nothing
        grid.axis = axis
        grid.dimension = dimension
    end
    return (range, scale, axis, grid)
end

function draw(layers::Layers; theme::ThemeDict=ThemeDict())
    fig = Bokeh.Figure()

    # PLOT/RESOLVE EACH LAYER
    data_cache = Dict{Any,Data}()
    resolved = Vector{ResolvedLayer}()
    for layer in layers.layers
        # get the data
        orig_data = layer.data
        transforms = layer.transforms
        orig_data === nothing && error("no data")
        data = _get_data(orig_data, transforms; cache=data_cache, theme)
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
        props = Dict{Symbol,ResolvedProperty}(k => _get_property(v; data, theme) for (k, v) in props)
        # plot the glyph
        kw = Dict{Symbol,Any}(k => v.value for (k, v) in props)
        renderer = Bokeh.plot!(fig, glyph; source, kw...)
        # save
        push!(resolved, ResolvedLayer(; orig=layer, data, props, renderer))
    end

    # RANGES, SCALES and AXES
    fig.x_range, fig.x_scale, x_axis, x_grid = _get_range_scale_axis_grid(resolved, [:x, :xs, :right, :left], 0)
    fig.y_range, fig.y_scale, y_axis, y_grid = _get_range_scale_axis_grid(resolved, [:y, :ys, :top, :bottom], 1)
    Bokeh.plot!(fig, x_axis, location=_get_theme(theme, :x_axis_location))
    Bokeh.plot!(fig, y_axis, location=_get_theme(theme, :y_axis_location))
    x_grid !== nothing && Bokeh.plot!(fig, x_grid)
    y_grid !== nothing && Bokeh.plot!(fig, y_grid)

    # TOOLS
    fig.toolbar = Bokeh.figure().toolbar

    # COLOR BARS
    legend_location = _get_theme(theme, :legend_location)
    legend_orientation = legend_location in ("above", "below") ? "horizontal" : "vertical"
    # Find all layers+props for continuous color mappings.
    colorbarinfos = Dict()
    for layer in resolved
        for (k, v) in layer.props
            v.datainfo !== nothing || continue
            v.datainfo.datatype == NUMBER_DATA || continue
            m = v.orig
            m isa Mapping || continue
            m.type == COLOR_MAP || continue
            push!(get!(colorbarinfos, (layer.orig.data.source, v.fieldname), []), (layer, v))
        end
    end
    # Generate a colorbar for each unique source+field combination.
    colorbars = []
    for ((source, fieldname), layerprops) in colorbarinfos
        # item = Bokeh.LegendItem(; label=Bokeh.Field(fieldname), renderers=[layer.renderer for (layer, _) in layerprops])
        # items = [item]
        titles = [p.label for (_, p) in layerprops if p.label !== nothing]
        mappers = [p.mapper for (_, p) in layerprops if p.mapper !== nothing]
        mapper = mappers[1]  # TODO: what if there is not exactly one?
        if !isempty(titles)
            title = titles[1]
        else
            title = fieldname
        end
        colorbar = Bokeh.ColorBar(; color_mapper=mapper, title, orientation=legend_orientation)
        push!(colorbars, (fieldname, colorbar))
    end
    # Plot the legends, sorted by title.
    sort!(colorbars, by=x->x[1])
    for (_, colorbar) in colorbars
        Bokeh.plot!(fig, colorbar, location=legend_location)
    end

    # LEGENDS
    # Find all layers+props for categorical mappings.
    legendinfos = Dict()
    for layer in resolved
        for (k, v) in layer.props
            v.datainfo !== nothing || continue
            v.datainfo.datatype ∈ ANY_FACTOR_DATA || continue
            m = v.orig
            m.type in (COLOR_MAP, MARKER_MAP, HATCH_PATTERN_MAP) || continue
            m isa Mapping || continue
            push!(get!(legendinfos, (layer.orig.data.source, v.fieldname), []), (layer, k, v))
        end
    end
    # Generate a legend for each unique source+field combination.
    legends = []
    for ((source, fieldname), layerprops) in legendinfos
        if _get_theme(theme, :better_legends)
            factors = []
            for (_, _, prop) in layerprops
                union!(factors, prop.mapper.factors)
            end
            legend_source = Bokeh.ColumnDataSource(; data=Dict(fieldname=>factors))
            legend_renderers = Bokeh.ModelInstance[]
            legend_view = Bokeh.CDSView(; source=legend_source)
            for layer in Set([layer for (layer, _, _) in layerprops])
                glyph = layer.orig.glyph
                kw = Pair{Symbol,Any}[]
                for (k, prop) in layer.props
                    if prop.orig isa Mapping && (prop.datainfo === nothing || prop.datainfo.datatype ∉ ANY_FACTOR_DATA || prop.orig.type ∉ (COLOR_MAP, MARKER_MAP, HATCH_PATTERN_MAP) || prop.fieldname != fieldname)
                        continue
                    end
                    if haskey(PROPERTY_GROUPS, k)
                        for k2 in PROPERTY_GROUPS[k]
                            if haskey(glyph.propdescs, k2)
                                push!(kw, k2 => prop.value)
                            end
                        end
                    else
                        if haskey(glyph.propdescs, k)
                            push!(kw, k => prop.value)
                        end
                    end                    
                end
                legend_glyph = glyph(; kw...)
                legend_renderer = Bokeh.GlyphRenderer(; glyph=legend_glyph, data_source=legend_source, view=legend_view, visible=false)
                push!(fig.renderers, legend_renderer)
                push!(legend_renderers, legend_renderer)
            end
            items = Bokeh.ModelInstance[]
            for (i, factor) in enumerate(factors)
                item = Bokeh.LegendItem(; label=Bokeh.Value(factor), renderers=legend_renderers, index=i-1)
                push!(items, item)
            end
        else
            item = Bokeh.LegendItem(; label=Bokeh.Field(fieldname), renderers=[layer.renderer for (layer, _, _) in layerprops])
            items = [item]
        end
        titles = [p.label for (_, _, p) in layerprops if p.label !== nothing]
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

    return fig
end

function draw(; kw...)
    return layer -> draw(layer; kw...)
end

function Base.display(d::Bokeh.BokehDisplay, layers::Layers)
    theme = _as_theme(get(Bokeh.setting(:theme).attrs, :Algebrokeh, nothing))
    return display(d, draw(layers; theme))
end
