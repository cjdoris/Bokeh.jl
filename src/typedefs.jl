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
end


### MODELS

mutable struct ModelType
    name::String
    subname::Union{Nothing,String}
    inherits::Vector{ModelType}
    proptypes::Dict{Symbol,PropType}
    supers::IdSet{ModelType}
end

struct Model
    id :: String
    type :: ModelType
    values :: Dict{Symbol,Any}
    function Model(t::ModelType; kw...)
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
export Value

struct Field
    name::String
    transform::Union{Nothing,Model}
    function Field(name; transform::Union{Nothing,Model}=nothing)
        transform===nothing || ismodelinstance(transform, Transform) || error("transform must be a Transform")
        new(convert(String, name), transform)
    end
end
export Field

struct Invalid
    msg::String
    level::Int
end


### DOCUMENT

mutable struct Document
    roots::Vector{Model}
end
export Document
