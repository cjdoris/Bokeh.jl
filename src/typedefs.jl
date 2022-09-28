### THEMES

mutable struct Theme
    attrs::Dict{Symbol,Dict{Symbol,Any}}
    Theme() = new(Dict{Symbol,Dict{Symbol,Any}}())
end


### SERIALIZE

struct Serializer
    refs::Dict{String,Any}
    refscache::Dict{String,Any}
    themes::Vector{Theme}
end


### TYPES

@enum PrimType begin
    NULL_T
    BOOL_T
    INT_T
    FLOAT_T
    STRING_T
    TUPLE_T
    LIST_T
    DICT_T
    ANY_T
    DATASPEC_T
    EITHER_T
    INSTANCE_T
    MODELINSTANCE_T
end

mutable struct PropType
    prim::PrimType
    default::Any
    validate::Union{Nothing,Function}
    params::Union{Nothing,Vector{PropType}}
    enumvals::Union{Nothing,Set{String}}
    regex::Union{Nothing,Regex}
    result_type::Union{Nothing,Type}
    model_type::Any  # want ::Union{Nothing,ModelType} but Julia does not yet support mutually recursive types
    serialize::Union{Nothing,Function}
    strings_are_fields::Bool
end

@enum PropKind begin
    TYPE_K
    GETSET_K
end

mutable struct PropDesc
    kind::PropKind
    type::Union{Nothing,PropType}
    getter::Union{Nothing,Function}
    setter::Union{Nothing,Function}
    doc::Markdown.MD
end


### RESOURCES

Base.@kwdef mutable struct Resource
    type::String = "js"
    name::String = ""
    url::String = ""
    raw::String = ""
end


### MODELS

Base.@kwdef mutable struct ModelType
    name::String = ""
    view_type::String = name
    view_subtype::Union{String,Nothing} = nothing
    bases::Vector{ModelType} = ModelType[]
    mro::Vector{ModelType} = ModelType[]
    propdescs::Dict{Symbol,PropDesc} = Dict{Symbol,PropDesc}()
    doc::Markdown.MD = Markdown.MD([])
    resources::Vector{Resource} = Resource[]
end

const Arg = Any
const Kwarg = Pair{Symbol,Any}

struct ModelInstance
    id :: String
    type :: ModelType
    values :: Dict{Symbol,Any}
    function ModelInstance(t::ModelType, kw::Vector{Kwarg})
        ans = new(new_id(), t, Dict{Symbol,Any}())
        for (k, v) in kw
            setproperty!(ans, k, v)
        end
        return ans
    end
end

struct ModelPropBinding
    type::ModelType
    name::Symbol
end


### CORE

struct Undefined end

struct Value
    value::Any
    transform::Union{Nothing,ModelInstance}
    function Value(value; transform::Union{Nothing,ModelInstance}=nothing)
        transform===nothing || ismodelinstance(transform, Transform) || error("transform must be a Transform")
        return new(value, transform)
    end
end

struct Field
    name::String
    transform::Union{Nothing,ModelInstance}
    function Field(name; transform::Union{Nothing,ModelInstance}=nothing)
        transform===nothing || ismodelinstance(transform, Transform) || error("transform must be a Transform")
        return new(convert(String, name), transform)
    end
end

struct Expr
    expr::ModelInstance
    transform::Union{Nothing,ModelInstance}
    function Expr(expr::ModelInstance; transform::Union{Nothing,ModelInstance}=nothing)
        ismodelinstance(expr, Expression) || error("expr must be an Expression")
        transform===nothing || ismodelinstance(transform, Transform) || error("transform must be a Transform")
        return new(expr, transform)
    end
end

struct Invalid
    msg::String
    level::Int
end

struct PropVector{T} <: AbstractVector{T}
    parent::Vector{T}
end


### DOCUMENT

mutable struct Document
    roots::Vector{ModelInstance}
    theme::Theme
end


## SERIALIZED DOCUMENT

mutable struct SerializedDocument
    doc::Document
    ser::Serializer
end


### DISPLAY

abstract type AbstractDisplayBackend end

struct NullDisplayBackend <: AbstractDisplayBackend end

struct BrowserDisplayBackend <: AbstractDisplayBackend end

struct BokehDisplay <: AbstractDisplay end
