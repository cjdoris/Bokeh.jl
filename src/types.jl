PropType(prim::PrimType;
    default=Undefined(),
    validate=nothing,
    params=nothing,
    enumvals=nothing,
    regex=nothing,
    result_type=nothing,
    model_type=nothing,
    serialize=nothing,
    strings_are_fields=false,
) = PropType(prim, default, validate, params, enumvals, regex, result_type, model_type, serialize, strings_are_fields)

PropType(
    base::PropType;
    default=base.default,
    validate=base.validate,
    params=base.params,
    enumvals=base.enumvals,
    regex=base.regex,
    result_type=base.result_type,
    model_type=base.model_type,
    serialize=base.serialize,
    strings_are_fields=base.strings_are_fields,
) = PropType(base.prim, default, validate, params, enumvals, regex, result_type, model_type, serialize, strings_are_fields)

function Base.show(io::IO, t::PropType)
    show(io, typeof(t))
    print(io, "(")
    show(io, t.prim)
    print(io, "; ...)")
end

struct DefaultT{T} <: Function
    value::T
end

DefaultT(t::PropType, x) = PropType(t; default=x)
(d::DefaultT)(t) = DefaultT(t, d.value)

NullableT(t::PropType; default=nothing, kw...) = EitherT(NullT(), t; default, kw...)

function enum_summary(vs)
    ws = String[]
    for v in vs
        if length(ws) ≥ 5
            push!(ws, "...")
            break
        else
            push!(ws, repr(v))
        end
    end
    return join(ws, ", ", " or ")
end

function validate(t::PropType, x; detail::Bool=true)
    level = 1
    prim = t.prim
    if prim == NULL_T
        x isa Nothing || return Invalid(detail ? "expecting nothing" : "", level)
        level += 1
    elseif prim == BOOL_T
        x isa Bool || return Invalid(detail ? "expecting true or false" : "", level)
        level += 1
    elseif prim == INT_T
        x isa Integer || return Invalid(detail ? "expecting an integer" : "", level)
        x = convert(Int, x)
        level += 1
    elseif prim == FLOAT_T
        x isa Real || return Invalid(detail ? "expecting a number" : "", level)
        x = convert(Float64, x)
        level += 1
    elseif prim == STRING_T
        x isa AbstractString || return Invalid(detail ? "expecting a string" : "", level)
        x = convert(String, x)
        level += 1
        enumvals = t.enumvals
        if enumvals !== nothing
            level += 1
            x in enumvals || return Invalid(detail ? "expecting $(enum_summary(enumvals))" : "", level)
        end
        regex = t.regex
        if regex !== nothing
            level += 1
            occursin(regex, x) || return Invalid(detail ? "expecting $(repr(regex))" : "", level)
        end
    elseif prim == TUPLE_T
        x isa Tuple || return Invalid(detail ? "expecting a tuple" : "", level)
        params = t.params::Vector{PropType}
        length(x) == length(params) || return Invalid(detail ? "expecting a $(length(params))-tuple" : "", level)
        level += 1
        x = validate_tuple(params, x; detail)
        x isa Invalid && return Invalid(x.msg, x.level + level - 1)
    elseif prim == LIST_T
        x isa AbstractVector || return Invalid(detail ? "expecting a vector" : "", level)
        level += 1
        x = validate_list(t.params[1], x; detail)
        x isa Invalid && return Invalid(x.msg, x.level + level - 1)
    elseif prim == DICT_T
        x isa AbstractDict || return Invalid(detail ? "expecting a dict" : "", level)
        level += 1
        x = validate_dict(t.params[1], t.params[2], x; detail)
        x isa Invalid && return Invalid(x.msg, x.level + level - 1)
    elseif prim == DATASPEC_T
        if x isa Value
            level += 1
            x2 = validate(t.params[1], x.value; detail)
            x2 isa Invalid && return Invalid(detail ? ".value: $(x2.msg)" : "", x2.level + level + 1)
            level += 1
            x = Value(x2)
        elseif x isa Field
            level += 1
        elseif x isa Expr
            level += 1
        elseif x isa AbstractString
            if t.strings_are_fields
                x = Field(x)
            else
                level += 1
                x2 = validate(t.params[1], x; detail=false)
                x = x2 isa Invalid ? Field(x) : Value(x2)
            end
        else
            x2 = validate(t.params[1], x; detail)
            x2 isa Invalid && return Invalid(detail ? "$(x2.msg)" : "", x2.level + level + 1)
            level += 1
            x = Value(x2)
        end
    elseif prim == EITHER_T
        x = validate_either(t.params, x; detail)
        x isa Invalid && return Invalid(x.msg, x.level + level - 1)
    elseif prim == INSTANCE_T
        result_type = t.result_type::Type
        x isa result_type || return Invalid(detail ? "expecting a $result_type" : "", level)
        level += 1
    elseif prim == MODELINSTANCE_T
        model_type = t.model_type::ModelType
        ismodelinstance(x, model_type) || return Invalid(detail ? "expecting a $(model_type.name)" : "", level)
        level += 1
    else
        @assert prim == ANY_T
    end
    # extra validation
    xvalidate = t.validate
    if xvalidate !== nothing
        x = xvalidate(x; detail)
        if x isa Invalid
            x = Invalid(x.msg, x.level + level-1)
        end
    end
    # all done
    return x
end

function validate_list(t::PropType, xs::AbstractVector, ::Type{T}=result_type(t); detail) where {T}
    x2s = T[]
    for (i, x) in pairs(xs)
        x2 = validate(t, x; detail)
        if x2 isa Invalid
            return Invalid(detail ? "[$i]: $(x2.msg)" : "", x2.level + 1)
        else
            push!(x2s, x2)
        end
    end
    return x2s
end

function validate_dict(kt::PropType, vt::PropType, xs::AbstractDict, ::Type{K}=result_type(kt), ::Type{V}=result_type(vt); detail) where {K,V}
    x2s = Dict{K,V}()
    for (k, v) in pairs(xs)
        k2 = validate(kt, k; detail)
        k2 isa Invalid && return Invalid(detail ? "[$k]: (key) $(k2.msg)" : "")
        v2 = validate(vt, v; detail)
        v2 isa Invalid && return Invalid(detail ? "[$k]: $(v2.msg)" : "")
        x2s[k2] = v2
    end
    return x2s
end

function validate_tuple(ts::Vector{PropType}, xs::Tuple; detail)
    x2s = ntuple(i->validate(ts[i], xs[i]; detail), length(xs))
    for (i, x2) in pairs(x2s)
        x2 isa Invalid && return Invalid(detail ? "[$i]: $(x2.msg)" : "", x2.level + 1)
    end
    return x2s
end

function validate_either(ts::Vector{PropType}, x; detail)
    msgs = detail ? String[] : nothing
    toplevel = 0
    for t2 in ts
        x2 = validate(t2, x; detail)
        if x2 isa Invalid
            if x2.level > toplevel
                toplevel = x2.level
                detail && empty!(msgs)
            end
            if x2.level ≥ toplevel
                detail && push!(msgs, x2.msg)
            end
        else
            return x2
        end
    end
    @assert toplevel > 0
    return Invalid(detail ? join(unique(msgs), " / ") : "", toplevel)
end

function result_type(t::PropType)
    ans = t.result_type
    if ans === nothing
        if t.prim == NULL_T
            ans = Nothing
        elseif t.prim == BOOL_T
            ans = Bool
        elseif t.prim == INT_T
            ans = Int
        elseif t.prim == FLOAT_T
            ans = Float64
        elseif t.prim == STRING_T
            ans = String
        elseif t.prim == TUPLE_T
            ans = Tuple{map(result_type, t.params)...}
        elseif t.prim == LIST_T
            ans = Vector{result_type(t.params[1])}
        elseif t.prim == DICT_T
            ans = Dict{result_type(t.params[1]), result_type(t.params[2])}
        elseif t.prim == DATASPEC_T
            Union{Field,Value,Expr}
        elseif t.prim == EITHER_T
            ans = Union{map(result_type, t.params)...}
        elseif t.prim == MODELINSTANCE_T
            ans = ModelInstance
        else
            @assert t.prim == ANY_T
            ans = Any
        end
        t.result_type = ans
    end
    return ans
end


### PRIMITIVE

NullT(; kw...) = PropType(NULL_T; kw...)

StringT(; kw...) = PropType(STRING_T; kw...)

AnyT(; kw...) = PropType(ANY_T; kw...)

EnumT(enumvals; kw...) = PropType(STRING_T; enumvals, kw...)

RegexT(regex::Regex; kw...) = PropType(STRING_T; regex, kw...)

DataSpecT(t::PropType; kw...) = PropType(DATASPEC_T; params=[t], kw...)

function EitherT(ts::PropType...; kw...)
    params = PropType[]
    for t in ts
        if t.prim == EITHER_T && t.validate === nothing
            append!(params, t.params)
        else
            push!(params, t)
        end
    end
    return PropType(EITHER_T; params, kw...)
end

InstanceT(T::Type; kw...) = PropType(INSTANCE_T; result_type=T, kw...)
InstanceT(t::ModelType; kw...) = PropType(MODELINSTANCE_T; model_type=t, kw...)


### NUMERIC

BoolT(; kw...) = PropType(BOOL_T; kw...)

IntT(; kw...) = PropType(INT_T; kw...)

FloatT(; kw...) = PropType(FLOAT_T; kw...)

ByteT(; kw...) = IntT(; validate=(x; detail) -> (0 ≤ x ≤ 255 ? x : Invalid(detail ? "must be between 0 and 255" : "")), kw...)

NonNegativeIntT(; kw...) = IntT(; validate=(x; detail) -> (0 ≤ x ? x : Invalid(detail ? "must be at least 0" : "")), kw...)

PositiveIntT(; kw...) = IntT(; validate=(x; detail) -> (1 ≤ x ? x : Invalid(detail ? "must be at least 1" : "")), kw...)

PercentT(; kw...) = FloatT(; validate=(x; detail) -> (0 ≤ x ≤ 1 ? x : Invalid(detail ? "must be between 0 and 1" : "")), kw...)

SizeT(; kw...) = FloatT(; validate=(x; detail) -> (0 ≤ x ? x : Invalid(detail ? "must be at least 0" : "")), kw...)

DateT(; kw...) = InstanceT(Dates.Date; kw...)

DatetimeT(; kw...) = InstanceT(Dates.DateTime; kw...)

TimeDeltaT(; kw...) = InstanceT(Dates.Period; kw...)


### STRINGS

Base64StringT(; kw...) = StringT(; validate=(x; detail)->Base64.base64encode(x), kw...)

# TODO: validate
JSONT(; kw...) = StringT(; kw...)


### CONTAINERS

ListT(t::PropType, ::Type{T}=result_type(t); kw...) where {T} = PropType(LIST_T; params=[t], default=()->T[], kw...)

SeqT(t::PropType; kw...) = ListT(t; kw...)

TupleT(ts::PropType...; kw...) = PropType(TUPLE_T; params=collect(PropType, ts), kw...)

DictT(k::PropType, v::PropType, ::Type{K}=result_type(k), ::Type{V}=result_type(v); kw...) where {K,V} = PropType(DICT_T; params=[k,v], default=()->Dict{K,V}(), kw...)

function validate_column_data(x; detail)
    if x isa AbstractDict && all(k isa AbstractString && v isa AbstractVector for (k, v) in x)
        return Dict{String,AbstractVector}(x)
    elseif Tables.istable(x)
        t = Tables.dictcolumntable(x)
        return Dict{String,AbstractVector}(string(c) => Tables.getcolumn(t, c) for c in Tables.columnnames(t))
    else
        return Invalid(detail ? "expecting a dict mapping strings to vectors / expecting a table" : "", 1)
    end
end

function try_serialize_ndarray(x::AbstractArray{T}) where {T}
    # TODO: convert datetime/timedelta
    # TODO: convert Integer -> Int32
    # TODO: convert Real -> Float64
    if T == Float64
        dtype = "float64"
    elseif T == Float32
        dtype = "float32"
    elseif T == UInt8
        dtype = "uint8"
    elseif T == UInt16
        dtype = "uint16"
    elseif T == UInt32
        dtype = "uint32"
    elseif T == Int8
        dtype = "int8"
    elseif T == Int16
        dtype = "int16"
    elseif T == Int32
        dtype = "int32"
    else
        return nothing
    end
    return Dict(
        "__ndarray__" => Base64.base64encode(convert(Array, x)::Array),
        "shape" => reverse!(collect(Int, size(x))),
        "dtype" => dtype,
        "order" => Base.ENDIAN_BOM == 0x04030201 ? "little" : "big",
    )
end

function serialize_column_data(s::Serializer, x::Dict{String,AbstractVector})
    ans = Dict{String,Any}()
    for (k, v) in x
        k2 = serialize(s, k)
        v2 = try_serialize_ndarray(v)
        if v2 === nothing
            v2 = map(v) do z
                z2 = z isa AbstractArray ? try_serialize_ndarray(z) : nothing
                return z2 === nothing ? serialize(s, z) : z2
            end
        end
        ans[k2] = v2
    end
    return ans
end

ColumnDataT(; kw...) = AnyT(;
    validate = validate_column_data,
    serialize = serialize_column_data,
    result_type = Dict{String,AbstractVector},
    kw...
)

function ListOrSingleT(t::PropType, ::Type{T}=result_type(t); kw...) where {T}
    lt = ListT(t)
    st = PropType(t;
        validate = (x; detail) -> T[x],
        result_type = result_type(lt),
    )
    return EitherT(lt, st; default=lt.default, kw...)
end


### VISUAL

function validate_color(x; detail)
    if !(x isa String)
        if x isa Colors.Colorant
            c = x
        elseif x isa Tuple{Integer,Integer,Integer}
            c = Colors.RGB(map(x->reinterpret(Colors.N0f8, UInt8(x)), x)...)
        elseif x isa Tuple{Integer,Integer,Integer,Real}
            c = Colors.RGBA(map(x->reinterpret(Colors.N0f8, UInt8(x)), x[1:3])..., x[4])
        else
            error()
        end
        x = "#$(Colors.hex(c))"
    else
        x = get(NAMED_COLORS, x, x)
    end
    return lowercase(x)
end

const CSS_COLOR_REGEX = r"(^#[0-9a-fA-F]{3}$)|(^#[0-9a-fA-F]{4}$)|(^#[0-9a-fA-F]{6}$)|(^#[0-9a-fA-F]{8}$)|(^rgba\(((25[0-5]|2[0-4]\d|1\d{1,2}|\d\d?)\s*,\s*?){2}(25[0-5]|2[0-4]\d|1\d{1,2}|\d\d?)\s*,\s*([01]\.?\d*?)\))|(^rgb\(((25[0-5]|2[0-4]\d|1\d{1,2}|\d\d?)\s*,\s*?){2}(25[0-5]|2[0-4]\d|1\d{1,2}|\d\d?)\s*?\))"

ColorT(; kw...) = EitherT(
    EnumT(NAMED_COLOR_ENUM),
    RegexT(CSS_COLOR_REGEX),
    TupleT(ByteT(), ByteT(), ByteT()),
    TupleT(ByteT(), ByteT(), ByteT(), PercentT()),
    InstanceT(Colors.Colorant);
    validate = validate_color,
    result_type = String,
    kw...
)

function serialize_colorhex(s::Serializer, x::String)
    x = get(NAMED_COLORS, x, x)
    if startswith(x, "#")
        return x
    else
        error("not implemented: converting rgb literals to hex (specify colors by name, hex string or RGB(A) tuple instead)")
    end
end

ColorHexT(; kw...) = ColorT(serialize=serialize_colorhex)

AlphaT(; kw...) = PercentT(; default=1.0, kw...)

PaletteT(; kw...) = EitherT(
    EnumT(
        PALETTE_ENUM;
        validate = (x; detail) -> PALETTES[x],
        result_type = Vector{String},
    ),
    ListT(ColorT());
    kw...
)

const FONT_SIZE_REGEX = r"^[0-9]+(.[0-9]+)?(%|em|ex|ch|ic|rem|vw|vh|vi|vb|vmin|vmax|cm|mm|q|in|pc|pt|px)$"i

FontSizeT(; kw...) = RegexT(FONT_SIZE_REGEX; kw...)

DashPatternT(; kw...) = EitherT(
    EnumT(
        DASH_PATTERN_ENUM;
        validate = (x; detail) -> DASH_PATTERNS[x],
        result_type = Vector{Int},
    ),
    RegexT(
        r"^(\d+(\s+\d+)*)?$";
        validate = (x; detail) -> Int[parse(Int, x) for x in split(x)],
        result_type = Vector{Int},
    ),
    SeqT(IntT());
    kw...
)

# TODO: accept more image types
ImageT(; kw...) = RegexT(r"^data:image/"; kw...)


### FACTORS

L1FactorT(; kw...) = StringT(; kw...)

L2FactorT(; kw...) = TupleT(StringT(), StringT(); kw...)

L3FactorT(; kw...) = TupleT(StringT(), StringT(), StringT(); kw...)

FactorT(; kw...) = EitherT(L1FactorT(), L2FactorT(), L3FactorT(); kw...)

FactorSeqT(; kw...) = EitherT(SeqT(L1FactorT()), SeqT(L2FactorT()), SeqT(L3FactorT()); kw...)



### DATASPECS

NumberSpecT(; kw...) = DataSpecT(FloatT(); kw...)

StringSpecT(; kw...) = DataSpecT(StringT(); strings_are_fields=true, kw...)

NullStringSpecT(; kw...) = DataSpecT(NullableT(StringT()); strings_are_fields=true, kw...)

AngleSpecT(; kw...) = DataSpecT(FloatT(); kw...) # TODO: units

DistanceSpecT(; kw...) = DataSpecT(SizeT(); kw...) # TODO: units

NullDistanceSpecT(; kw...) = DataSpecT(NullableT(SizeT()); kw...) # TODO: units


### OTHER ENUMS

const AUTO_ENUM = Set(["auto"])

AutoT(; kw...) = EnumT(AUTO_ENUM; kw...)

HatchPatternT(; kw...) = EnumT(HATCH_PATTERN_ENUM; kw...)


### MISC

TitleT(; kw...) = EitherT(
    InstanceT(Title),
    StringT(
        validate = (x; detail) -> Title(text=x),
        result_type = ModelInstance,
    );
    kw...
)

MarginT(; kw...) = EitherT(
    TupleT(IntT(), IntT(), IntT(), IntT()),
    TupleT(IntT(), IntT();
        validate = (x; detail) -> (x[1], x[2], x[1], x[2]),
        result_type = NTuple{4,Integer},
    ),
    IntT(
        validate = (x; detail) -> (x, x, x, x),
        result_type = NTuple{4,Integer},
    );
    kw...
)

MathStringT(; kw...) = StringT(; kw...)

TickerT(; kw...) = EitherT(
    InstanceT(Ticker),
    SeqT(FloatT();
        validate = (x; detail) -> FixedTicker(ticks=x),
        result_type = ModelInstance,
    );
    kw...
)
