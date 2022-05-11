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

function Base.show(io::IO, x::Field)
    show(io, typeof(x))
    print(io, "(")
    show(io, x.name)
    if x.transform !== nothing
        print(io, ", transform=")
        show(io, x.transform)
    end
    print(io, ")")
end

function Base.show(io::IO, x::Value)
    show(io, typeof(x))
    print(io, "(")
    show(io, x.value)
    if x.transform !== nothing
        print(io, ", transform=")
        show(io, x.transform)
    end
    print(io, ")")
end


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
