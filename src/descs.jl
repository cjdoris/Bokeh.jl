PropDesc(kind::PropKind;
    type=nothing,
    getter=nothing,
    setter=nothing,
    doc=Markdown.MD([]),
) = PropDesc(kind, type, getter, setter, doc)

PropDesc(base::PropDesc;
    type=base.type,
    getter=base.getter,
    setter=base.setter,
    doc=base.doc,
) = PropDesc(base.kind, type, getter, setter, doc)

PropDesc(type::PropType; doc=Markdown.MD([])) = PropDesc(TYPE_K; type, doc)

GetSetT(getter=nothing, setter=nothing; doc=Markdown.MD([])) = PropDesc(GETSET_K; getter, setter, doc)
