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

_is_factor(x) = false
_is_factor(x::AbstractString) = true
_is_factor(x::Symbol) = true

function plotdata(data)
    # deconstruct data into table, source and columns
    if data isa Data
        table = data.table
        source = data.source
        columns = data.columns
    else
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
            source = Bokeh.ColumnDataSource()
        else
            throw(ArgumentError("expecting a table, got a $(typeof(data))"))
        end
        columns = Dict{String,DataInfo}()
        data = Data(; source, table, columns)
    end
    # set column info
    if table !== nothing
        # iterate over columns
        tablecols = Tables.columns(table)
        for name in Tables.columnnames(tablecols)
            # get the column
            col = Tables.getcolumn(tablecols, name)
            # get existing column info
            info = get(columns, String(name), nothing)
            if info === nothing
                datatype = nothing
                factors = nothing
                label = nothing
                has_other = false
                has_missing = false
            else
                datatype = info.datatype
                factors = info.factors
                label = info.label
                has_other = info.has_other
                has_missing = info.has_missing
            end
            # get a label
            if label === nothing
                if DataAPI.colmetadatasupport(typeof(table)).read
                    label = DataAPI.colmetadata(table, name, "label", nothing)
                else
                    label = nothing
                end
            end
            # get the datatype
            if datatype === nothing
                if all(x -> x === missing || _is_factor(x), col)
                    datatype = FACTOR_DATA
                elseif all(x -> x === missing || (x isa Tuple && length(x) == 2 && all(_is_factor, x)), col)
                    datatype = FACTOR2_DATA
                elseif all(x -> x === missing || (x isa Tuple && length(x) == 3 && all(_is_factor, x)), col)
                    datatype = FACTOR3_DATA
                else
                    datatype = NUMBER_DATA
                end
            end
            # get the factors
            if datatype ∈ ANY_FACTOR_DATA && factors === nothing
                factors = sort(unique(skipmissing(col)))
            end
            # get has_other
            if datatype ∈ ANY_FACTOR_DATA && !has_other
                has_other = any(x -> x !== missing && x ∉ factors, col)
            end
            # get has_missing
            if !has_missing
                has_missing = any(x -> x === missing, col)
            end
            # set the column info
            columns[String(name)] = DataInfo(; datatype, factors, label, has_other, has_missing)
        end
    end
    return Layer(; data)
end
