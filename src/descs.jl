PropDesc(kind::PropKind;
    type=nothing,
    getter=nothing,
    setter=nothing,
) = PropDesc(kind, type, getter, setter)

PropDesc(type::PropType) = PropDesc(TYPE_K; type)

GetSetT(getter=nothing, setter=nothing) = PropDesc(GETSET_K; getter, setter)
