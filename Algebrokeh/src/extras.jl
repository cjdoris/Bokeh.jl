function linesby(cols...; kw...)
    cols = collect(String, cols)
    function tr(data::Data)
        table0 = data.table
        table0 === nothing && error("linesby() requires data to be specified explicitly")
        df = DataFrame(table0)
        table = combine(groupby(df, cols), [c => (c in cols ? (x -> [first(x)]) : (x -> [x])) => c for c in names(df)])
        columns = copy(data.columns)
        return Data(; table, columns)
    end
    return plot(tr, Bokeh.MultiLine; kw...)
end

# # ### VSTACK

# function stack(k1, k2, fields; kw...)
#     haskey(kw, k1) && error("invalid argument $k1")
#     haskey(kw, k2) && error("invalid argument $k2")
#     fields = collect(String, fields)
#     layers = Layer[]
#     x1 = Bokeh.Expr(Bokeh.Stack(fields=[]))
#     for i in 1:length(fields)
#         x2 = Bokeh.Expr(Bokeh.Stack(fields=fields[1:i]))
#         properties = Dict{Symbol,Any}()
#         for (k, v) in kw
#             if v isa AbstractVector
#                 properties[k] = v[i]
#             else
#                 properties[k] = v
#             end
#         end
#         properties[k1] = x1
#         properties[k2] = x2
#         layer = Layer(; properties)
#         push!(layers, layer)
#         x1 = x2
#     end
#     return Layers(layers)
# end

# function vstack(fields; kw...)
#     return stack(:bottom, :top, fields; kw...)
# end

# function hstack(fields; kw...)
#     return stack(:left, :right, fields; kw...)
# end

# function histby(xcol, ncol; kw...)
#     xcol = convert(String, xcol)
#     ncol = convert(String, ncol)
#     tr = let xcol = xcol, ncol = ncol
#         datat() do df
#             return combine(groupby(df, xcol), [xcol => (x->[first(x)]) => xcol, nrow => ncol])
#         end
#     end
#     return tr * glyph(Bokeh.VBar; kw...) * mapping(xcol, ncol)
# end
# export histby

function plotvbar(args...; x, y, dodge=nothing, kw...)
    dodge === nothing && return plot(args..., Bokeh.VBar; x, y, kw...)
    dodgemap = maybe_parse_mapping(:dodge, dodge)
    dodgemap isa Mapping || error("expecting dodge to be a mapping")
    xmap = maybe_parse_mapping(:x, x)
    xmap isa Mapping || error("expecting x to be a mapping")
    ymap = maybe_parse_mapping(:y, y)
    ymap isa Mapping || error("expecting y to be a mapping")
    xcol = xmap.field.names
    xcol isa String || error("x can only map a single column")
    dodgecol = dodgemap.field.names
    dodgecol isa String || error("dodge can only map a single column")
    width = get(kw, :width, nothing)
    newxcol = string(gensym("dodge#$xcol#$dodgecol"))
    xdatainfo = xmap.datainfo
    if xdatainfo === nothing
        newxdatainfo = nothing
    else
        xdatainfo.datatype == FACTOR_DATA || error("x should be a single-level factor")
        newxdatainfo = DataInfo(xdatainfo; FACTOR_DODGE_DATA)
    end
    newxmap = Mapping(xmap; datainfo=newxdatainfo, field=Field(newxcol))
    function tr(data::Data)
        table0 = data.table
        table0 === nothing && error("linesby() requires data to be specified explicitly")
        table = DataFrame(table0)
        # TODO: the list of factors should be defined somewhere extrinsic - maybe use DataFrames metadata?
        facidxs = Dict(x=>i for (i, x) in enumerate(data.columns[dodgecol].factors))
        nfacs = length(facidxs)
        if nfacs > 0
            w = width isa Real ? width : 1/nfacs
            table[!, newxcol] = [(a, (facidxs[x] - (nfacs + 1) / 2) * w) for (a, x) in zip(table[!, xcol], table[!, dodgecol])]
        else
            table[!, newxcol] = []
        end        
        columns = copy(data.columns)
        columns[newxcol] = DataInfo(columns[xcol], datatype=FACTOR_DODGE_DATA)
        return Data(; table, columns)
    end
    return plot(args..., Bokeh.VBar, tr; x=newxmap, y=ymap, kw...)
end
export plotvbar
