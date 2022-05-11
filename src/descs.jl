PropDesc(kind::PropKind;
    type=nothing,
    getter=nothing,
    setter=nothing,
    docstring="",
) = PropDesc(kind, type, getter, setter, docstring)

PropDesc(base::PropDesc;
    type=base.type,
    getter=base.getter,
    setter=base.setter,
    docstring=base.docstring,
) = PropDesc(base.kind, type, getter, setter, docstring)

PropDesc(type::PropType; docstring="") = PropDesc(TYPE_K; type, docstring)

GetSetT(getter=nothing, setter=nothing; docstring="") = PropDesc(GETSET_K; getter, setter, docstring)
