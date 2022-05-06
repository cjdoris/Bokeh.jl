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
