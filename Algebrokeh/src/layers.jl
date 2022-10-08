Base.zero(::Type{Layers}) = Layers(Layer[])

Base.one(::Type{Layers}) = Layers([Layer()])

Base.:(+)(xs::Layers, ys::Layers) = Layers(vcat(xs.layers, ys.layers))

Base.:(*)(xs::Layers, y::Layer) = Layers([x*y for x in xs.layers])
Base.:(*)(xs::Layers, ys::Layers) = Layers([x*y for x in xs.layers for y in ys.layers])
function Base.:(*)(x::Layer, y::Layer)
    data = y.data !== nothing ? y.data : x.data
    transforms = y.data !== nothing ? y.transforms : vcat(x.transforms, y.transforms)
    glyph = y.glyph !== nothing ? y.glyph : x.glyph
    properties = merge(x.properties, y.properties)
    return Layer(; data, transforms, glyph, properties)
end

"""
    plot(args...; kw...)

Create an Algebrokeh plot.
"""
function plot(args...; kw...)
    layers = one(Layers)
    for arg in args
        if arg isa Layer || arg isa Layers
            layers *= arg
        elseif arg isa AbstractVector
            layers *= Layers([layer for x in arg for layer in plot(x).layers])
        elseif arg isa Function
            layers *= Layer(; transforms=[arg])
        elseif arg isa Bokeh.ModelType && Bokeh.issubmodeltype(arg, Bokeh.Glyph)
            layers *= Layer(; glyph=arg)
        elseif arg isa Data || Bokeh.ismodelinstance(arg, Bokeh.DataSource) || Tables.istable(arg)
            layers *= plotdata(arg)
        else
            throw(ArgumentError("invalid argument of type $(typeof(arg))"))
        end
    end
    if !isempty(kw)
        layers *= Layer(; properties=Dict{Symbol,Any}(k => maybe_parse_mapping(k, v) for (k, v) in kw))
    end
    return layers
end

function plotdata(data)
    if !isa(data, Data)
        if Bokeh.ismodelinstance(data, Bokeh.ColumnDataSource)
            table = DataFrame(data.data)
            source = data
        elseif Bokeh.ismodelinstance(data, Bokeh.DataSource)
            table = nothing
            source = data
        elseif Bokeh.ismodelinstance(data)
            throw(ArgumentError("expecting a DataSource, got a $(Bokeh.modeltype(data).name)"))
        elseif Tables.istable(data)
            table = data
            source = Bokeh.ColumnDataSource(; data)
        else
            throw(ArgumentError("expecting a table, got a $(typeof(data))"))
        end
        columns = Dict{String,DataInfo}()
        if table !== nothing
            tablecols = Tables.columns(table)
            for name in Tables.columnnames(tablecols)
                col = Tables.getcolumn(tablecols, name)
                if DataAPI.colmetadatasupport(typeof(table)).read
                    label = DataAPI.colmetadata(table, name, "label", nothing)
                else
                    label = nothing
                end
                if !isempty(col) && all(x->isa(x, Factor), col)
                    datatype = FACTOR_DATA
                    factors = sort(unique(col))
                else
                    datatype = NUMBER_DATA
                    factors = []
                end
                columns[String(name)] = DataInfo(; datatype, factors, label)
            end
        end
        data = Data(; source, table, columns)
    end
    return Layer(; data)
end
