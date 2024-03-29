_recpairfirst(x) = x isa Pair ? _recpairfirst(x.first) : x
_flatpair(x) = x isa Pair ? (_flatpair(x.first)..., _flatpair(x.second)...) : (x,)

function maybe_parse_mapping(k, v)
    v0 = _recpairfirst(v)
    if v0 isa AbstractString && startswith(v0, "@")
        return parse_mapping(k, v)
    elseif v0 isa Tuple{Vararg{AbstractString}} && any(x->startswith(x, "@"), v0)
        return parse_mapping(k, v)
    elseif v0 isa Field
        return parse_mapping(k, v)
    else
        return v
    end
end

function parse_mapping(k, v)
    name = String(k)
    # infer the type from the name
    if occursin("color", name)
        type = COLOR_MAP
    elseif occursin("marker", name)
        type = MARKER_MAP
    elseif occursin("hatch_pattern", name)
        type = HATCH_PATTERN_MAP
    else
        type = DATA_MAP
    end
    # flatten any pairs into a tuple
    vs = _flatpair(v)
    # first entry is the field to map
    if vs[1] isa Field
        field = vs[1]
    elseif vs[1] isa AbstractString
        @assert startswith(vs[1], "@")
        field = Field(String(vs[1])[2:end])
    else
        all(x->startswith(x, "@"), vs[1]) || error("invalid hierarchical mapping: $(vs[1])")
        field = Field(map(x->String(x)[2:end], vs[1]))
    end
    # remaining entries define optional info
    transforms = Bokeh.ModelInstance[]
    datainfo = nothing
    label = nothing
    palette = nothing
    markers = nothing
    patterns = nothing
    axis = nothing
    range = nothing
    grid = nothing
    for x in vs[2:end]
        if Bokeh.ismodelinstance(x, Bokeh.Transform)
            push!(transforms, x)
        elseif x isa DataInfo
            datainfo = x
        elseif x isa AbstractString || Bokeh.ismodelinstance(x, Bokeh.BaseText)
            label = x
        elseif x isa NamedTuple
            for (k, v) in pairs(x)
                if k == :palette
                    palette = v
                elseif k == :markers
                    markers = v
                elseif k == :patterns
                    patterns = v
                else
                    # TODO
                    error("not implemented")
                end
            end
        elseif Bokeh.ismodelinstance(x, Bokeh.Axis)
            axis = x
        elseif Bokeh.ismodelinstance(x, Bokeh.Range)
            range = x
        elseif Bokeh.ismodelinstance(x, Bokeh.Grid)
            grid = x
        else
            error("invalid mapping argument of type $(typeof(x))")
        end
    end
    return Mapping(; name, type, field, transforms, datainfo, label, palette, markers, patterns, axis, range, grid)
end
