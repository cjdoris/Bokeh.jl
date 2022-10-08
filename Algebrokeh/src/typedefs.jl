@enum DataType NUMBER_DATA FACTOR_DATA FACTOR2_DATA FACTOR3_DATA FACTOR_DODGE_DATA FACTOR2_DODGE_DATA FACTOR3_DODGE_DATA

const ANY_FACTOR_DATA = (FACTOR_DATA, FACTOR2_DATA, FACTOR3_DATA)
const ANY_FACTOR_DODGE_DATA = (FACTOR_DODGE_DATA, FACTOR2_DODGE_DATA, FACTOR3_DODGE_DATA)

@enum MappingType COLOR_MAP MARKER_MAP HATCH_PATTERN_MAP DATA_MAP

"""
Holds information about a collection of data, such as a column in a DataSource.
"""
@kwdef struct DataInfo
    datatype::DataType = NUMBER_DATA
    factors::Union{Nothing,Vector} = nothing
    has_other::Bool = false
    has_missing::Bool = false
    label::Any = nothing
end
DataInfo(src::DataInfo; datatype=src.datatype, factors=src.factors, has_other=src.has_other, has_missing=src.has_missing, label=src.label) = DataInfo(; datatype, factors, has_other, has_missing, label)

"""
A DataSource, plus information about the data in its columns.
"""
@kwdef struct Data
    source::Union{Bokeh.ModelInstance} = Bokeh.ColumnDataSource()
    table::Any
    columns::Dict{String,DataInfo}
end

"""
A specifier for a field. Can also be a collection of 2 or 3 fields, to treat them as a
hierarchical factor.
"""
struct Field
    names::Union{String,Tuple{String,String},Tuple{String,String,String}}
end

"""
A mapping value, which defines some connection between a field of data and a visual
property, such as color, marker or location.
"""
@kwdef struct Mapping
    name::String
    type::MappingType
    field::Field
    transforms::Vector{Bokeh.ModelInstance} = Bokeh.ModelInstance[]
    datainfo::Union{DataInfo,Nothing} = nothing
    # optional display information for the mapping
    label::Any = nothing
    palette::Any = nothing
    markers::Any = nothing
    patterns::Any = nothing
    axis::Union{Nothing,Bokeh.ModelInstance} = nothing
    range::Union{Nothing,Bokeh.ModelInstance} = nothing
    grid::Union{Nothing,Bokeh.ModelInstance} = nothing
end
Mapping(src::Mapping; name=src.name, type=src.type, field=src.field,
    transforms=src.transforms, datainfo=src.datainfo, label=src.label, palette=src.palette,
    markers=src.markers, patterns=src.patterns, axis=src.axis, range=src.range,
    grid=src.grid,
) = Mapping(; name, type, field, transforms, datainfo, label, palette, markers, patterns,
    axis, range, grid,
)

"""
A plotting layer, consisting of some combination of data, transforms to apply to the data,
the glyph to use to plot the data, and properties of that glyph including mappings from
data columns to visual attributes.

Any properties which are not [`Mapping`](@ref) are passed through to Bokeh unchanged.
"""
@kwdef struct Layer
    data::Union{Nothing,Data} = nothing
    transforms::Vector{Any} = []
    glyph::Union{Nothing,Bokeh.ModelType} = nothing
    properties::Dict{Symbol,Any} = Dict{Symbol,Any}()
end

"""
A collection of layers, stacked one on top of the next. This is returned by [`plot`](@ref).
"""
struct Layers
    layers::Vector{Layer}
end

@kwdef struct ResolvedProperty
    orig::Any
    value::Any
    label::Any = nothing
    field::Union{Field,Nothing} = nothing
    fieldname::Union{String,Nothing} = nothing
    datainfo::Union{DataInfo,Nothing} = nothing
    mapper::Union{Bokeh.ModelInstance,Nothing} = nothing
end

@kwdef struct ResolvedLayer
    orig::Layer
    data::Data
    props::Dict{Symbol,ResolvedProperty}
    renderer::Bokeh.ModelInstance
end
