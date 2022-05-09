### SERIALIZE

struct Serializer
    refs::Dict{String,Any}
    refscache::Dict{String,Any}
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
end


### MODELS

mutable struct ModelType
    name::String
    subname::Union{Nothing,String}
    inherits::Vector{ModelType}
    propdescs::Dict{Symbol,PropDesc}
    supers::IdSet{ModelType}
    abstract::Bool
end

const Arg = Any
const Kwarg = Pair{Symbol,Any}

struct Model
    id :: String
    type :: ModelType
    values :: Dict{Symbol,Any}
    function Model(t::ModelType, kw::Vector{Kwarg})
        t.abstract && error("cannot instantiate abstract model type $(t.name)")
        ans = new(new_id(), t, Dict{Symbol,Any}())
        for (k, v) in kw
            setproperty!(ans, k, v)
        end
        return ans
    end
end


### CORE

struct Undefined end

struct Value
    value::Any
    transform::Union{Nothing,Model}
    function Value(value; transform::Union{Nothing,Model}=nothing)
        transform===nothing || ismodelinstance(transform, Transform) || error("transform must be a Transform")
        new(value, transform)
    end
end

struct Field
    name::String
    transform::Union{Nothing,Model}
    function Field(name; transform::Union{Nothing,Model}=nothing)
        transform===nothing || ismodelinstance(transform, Transform) || error("transform must be a Transform")
        new(convert(String, name), transform)
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
    roots::Vector{Model}
end
