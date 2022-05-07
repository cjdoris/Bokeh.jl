Invalid(msg) = Invalid(msg, 1)

const _next_id = Ref(0)

function new_id()
    n = _next_id[] + 1
    _next_id[] = n
    return string(n)
end

function new_global_id()
    return UUIDs.uuid4()
end

Base.:(==)(x::Field, y::Field) = x.name == y.name
Base.:(==)(x::Value, y::Value) = x.value == y.value


### PROPVECTOR

# abstract array interface
Base.parent(x::PropVector) = getfield(x, :parent)
Base.length(x::PropVector) = length(parent(x))
Base.size(x::PropVector) = size(parent(x))
Base.getindex(x::PropVector, i::Int) = getindex(parent(x), i)
Base.setindex!(x::PropVector, v, i::Int) = (setindex!(parent(x), v, i); x)

# property access broadcasts over all elements
Base.getproperty(x::PropVector, k::Symbol) = PropVector([getproperty(x, k) for x in x])
function Base.setproperty!(x::PropVector, k::Symbol, v)
    for x in x
        setproperty!(x, k, v)
    end
    return x
end
Base.hasproperty(x::PropVector, k::Symbol) = all(hasproperty(x, k) for x in x)
function Base.propertynames(x::PropVector)
    ans = Symbol[]
    for (i, x) in enumerate(x)
        if i == 1
            append!(ans, propertynames(x))
        else
            intersect!(ans, propertynames(x))
        end
    end
    return ans
end
