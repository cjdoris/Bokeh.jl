### MODELTYPE

function init_props!(t::ModelType, props)
    for b in t.bases
        mergepropdescs!(t.propdescs, b.propdescs)
    end
    mergepropdescs!(t.propdescs, props)
    return t
end

function mergepropdescs!(ds, x; name=nothing)
    if x isa PropType
        x = PropDesc(x)
    end
    if x isa PropDesc
        if isempty(x.doc) && haskey(ds, name) && !isempty(ds[name].doc)
            # keep an existing docstring
            x = PropDesc(x, doc=ds[name].doc)
        end
        ds[name] = x
    elseif x isa Pair
        name = name===nothing ? x.first : Symbol(name, "_", x.first)
        mergepropdescs!(ds, x.second; name)
    elseif x isa Function
        d = ds[name]
        if d.kind == TYPE_K
            mergepropdescs!(ds, x(d.type); name)
        else
            mergepropdescs!(ds, x(d); name)
        end
    else
        for d in x
            mergepropdescs!(ds, d; name)
        end
    end
end

function (t::ModelType)(; kw...)
    @nospecialize
    ModelInstance(t, collect(Kwarg, kw))
end

issubmodeltype(t1::ModelType, t2::ModelType) = t2 in t1.mro

function Base.show(io::IO, t::ModelType)
    show(io, typeof(t))
    print(io, "(")
    show(io, t.name)
    print(io, "; ...)")
end

function Base.Docs.doc(t::ModelType, sig::Type=Union{})
    hdr = Markdown.Paragraph([
        "Bokeh model type ",
        Markdown.Code("$(t.name)"),
        ".",
    ])
    return Markdown.MD([hdr; t.doc.content])
end

function Base.Docs.doc(b::ModelPropBinding, sig::Type=Union{})
    t = b.type
    k = b.name
    d = get(t.propdescs, k, nothing)
    if d === nothing
        hdr = Markdown.Paragraph([
            "Invalid Bokeh model property ",
            Markdown.Code("$(t.name).$(k)"),
            ".",
        ])
        return Markdown.MD([hdr])
    else
        hdr = Markdown.Paragraph([
            "Bokeh model property ",
            Markdown.Code("$(t.name).$(k)"),
            ".",
        ])
        return Markdown.MD([hdr; d.doc])
    end
end

Base.Docs.doc(x::ModelInstance, sig::Type=Union{}) = Base.Docs.getdoc(modeltype(x), sig)
Base.Docs.doc(t::ModelType, k::Symbol) = Base.Docs.doc(ModelPropBinding(t, k))
Base.Docs.doc(x::ModelInstance, k::Symbol) = Base.Docs.doc(modeltype(x), k)

Base.Docs.Binding(t::ModelType, k::Symbol) = ModelPropBinding(t, k)
Base.Docs.Binding(x::ModelInstance, k::Symbol) = Base.Docs.Binding(modeltype(x), k)

Base.Docs.getdoc(t::ModelType, sig=Union{}) = Base.Docs.doc(t, sig)
Base.Docs.getdoc(x::ModelInstance, sig=Union{}) = Base.Docs.doc(x, sig)


### MODEL

modelid(m::ModelInstance) = getfield(m, :id)

modeltype(m::ModelInstance) = getfield(m, :type)

modelvalues(m::ModelInstance) = getfield(m, :values)

ismodelinstance(m) = m isa ModelInstance
ismodelinstance(m, t::ModelType) = ismodelinstance(m) && issubmodeltype(modeltype(m), t)

function _findprop(mt::ModelType, k::Symbol)
    ds = mt.propdescs
    pd = get(ds, k, nothing)
    pd !== nothing && return (pd, k)
    if k == :end_
        # allow end_ to alias for end, since foo(end=12) is not a syntax error
        pd = get(ds, :end, nothing)
        pd !== nothing && return (pd, :end)
    end
    error("$(mt.name): .$k: invalid property")
end

function Base.getproperty(m::ModelInstance, k::Symbol)
    # look up the descriptor
    mt = modeltype(m)
    pd, k = _findprop(mt, k)
    # look up the value
    vs = modelvalues(m)
    v = get(vs, k, Undefined())
    v === Undefined() || return v
    # branch on the kind of the descriptor
    kd = pd.kind
    if kd == TYPE_K
        # get the default value
        t = pd.type::PropType
        d = t.default
        if d === Undefined()
            v = d
        elseif d isa Function
            v = validate(t, d())
            v isa Invalid && error("$(mt.name): .$k: invalid default value: $(v.msg)")
            vs[k] = v
        else
            v = validate(t, d)
            v isa Invalid && error("$(mt.name): .$k: invalid default value: $(v.msg)")
        end
        return v
    elseif kd == GETSET_K
        f = pd.getter
        f === nothing && error("$(mt.name): .$k: property is not readable")
        return f(m)
    else
        @assert false
    end
end

function Base.setproperty!(m::ModelInstance, k::Symbol, x)
    # look up the descriptor
    mt = modeltype(m)
    pd, k = _findprop(mt, k)
    # branch on the kind of the descriptor
    kd = pd.kind
    if kd == TYPE_K
        if x === Undefined()
            # delete the value
            vs = modelvalues(m)
            delete!(vs, k)
        else
            # validate the value
            t = pd.type::PropType
            v = validate(t, x)
            v isa Invalid && error("$(mt.name): .$k: $(v.msg)")
            # set it
            vs = modelvalues(m)
            vs[k] = v
        end
    elseif kd == GETSET_K
        f = pd.setter
        f === nothing && error("$(mt.name): .$k: property is not writeable")
        f(m, x)
    else
        @assert false
    end
    return m
end

function Base.hasproperty(m::ModelInstance, k::Symbol)
    ts = modeltype(m).propdescs
    return haskey(ts, k)
end

function Base.propertynames(m::ModelInstance)
    ts = modeltype(m).propdescs
    return collect(keys(ts))
end

function Base.show(io::IO, m::ModelInstance)
    mt = modeltype(m)
    vs = modelvalues(m)
    print(io, mt.name, "(", join(["$k=$(repr(v))" for (k,v) in vs if v !== Undefined()], ", "), ")")
    return
end

Base.show(io::IO, ::MIME"text/plain", m::ModelInstance) = _show_indented(io, m)

function _show_indented(io::IO, m::ModelInstance, indent=0, seen=IdSet())
    if m in seen
        print(io, "...")
        return
    end
    push!(seen, m)
    mt = modeltype(m)
    vs = sort([x for x in modelvalues(m) if x[2] !== Undefined()], by=x->string(x[1]))
    print(io, mt.name, ":")
    istr = "  " ^ (indent + 1)
    if isempty(vs)
        print(io, " (blank)")
    else
        for (k, v) in vs
            println(io)
            print(io, istr, k, " = ")
            _show_indented(io, v, indent+1, seen)
        end
    end
    return
end

function _show_indented(io::IO, xs::AbstractVector, indent=0, seen=IdSet())
    if xs in seen
        print(io, "...")
        return
    end
    push!(seen, xs)
    if isempty(xs)
        print(io, "[]")
    else
        print(io, "[")
        istr = "  "^indent
        for (n, x) in enumerate(xs)
            println(io)
            print(io, istr, "  ")
            if n > 5
                print(io, "...")
                break
            else
                _show_indented(io, x, indent+1, seen)
            end
        end
        println(io)
        print(io, istr, "]")
    end
end

function _show_indented(io::IO, xs::AbstractDict, indent=0, seen=IdSet())
    if xs in seen
        print(io, "...")
        return
    end
    push!(seen, xs)
    if isempty(xs)
        print(io, "Dict()")
    else
        print(io, "Dict(")
        istr = "  "^indent
        for (n, (k, v)) in enumerate(xs)
            println(io)
            print(io, istr, "  ")
            if n > 5
                print(io, "...")
                break
            else
                show(io, k)
                print(io, " => ")
                _show_indented(io, v, indent+1, seen)
            end
        end
        println(io)
        print(io, istr, ")")
    end
end

function _show_indented(io::IO, x, indent=0, seen=IdSet())
    show(io, x)
end

function serialize(s::Serializer, m::ModelInstance)
    serialize_noref(s, m)
    id = modelid(m)
    return Dict("id" => id)
end

# TODO: cache this on the theme
function modeldefaults(model::ModelInstance, theme::Theme)
    ds = Dict{Symbol,Any}()
    for mt in Iterators.reverse(modeltype(model).mro)
        ds0 = get(theme.attrs, Symbol(mt.name), nothing)
        ds0 === nothing || merge!(ds, ds0)
    end
    return ds
end

function serialize_noref(s::Serializer, m::ModelInstance)
    id = modelid(m)
    if get(s.refs, id, nothing) === m
        return s.refscache[id]
    end
    mt = modeltype(m)
    ds = mt.propdescs
    attrs = Dict{String,Any}()
    for (k, v) in modelvalues(m)
        v === Undefined() && continue
        f = (ds[k].type::PropType).serialize
        k2 = string(k)
        v2 = f === nothing ? serialize(s, v) : f(s, v)
        attrs[k2] = v2
    end
    for theme in reverse(s.themes)
        for (k, v) in modeldefaults(m, theme)
            v === Undefined() && continue
            k2 = string(k)
            haskey(attrs, k2) && continue
            d = get(ds, k, nothing)
            d === nothing && continue
            d.kind == TYPE_K || continue
            t = d.type::PropType
            v2 = validate(t, v)
            v2 isa Invalid && error("Theme: $(mt.name): .$k: $(v2.msg)")
            f = (d.type::PropType).serialize
            v3 = f === nothing ? serialize(s, v2) : f(s, v2)
            attrs[k2] = v3
        end
    end
    ans = Dict{String,Any}(
        "type"=>mt.view_type,
        "id"=>id,
        "attributes"=>attrs,
    )
    if mt.view_subtype !== nothing
        ans["subtype"] = mt.view_subtype
    end
    s.refs[id] = m
    s.refscache[id] = ans
    return ans
end

plot_get_renderers(plot::ModelInstance; type, sides, filter=nothing) = PropVector(ModelInstance[m::ModelInstance for side in sides for m in getproperty(plot, side) if ismodelinstance(m::ModelInstance, type) && (filter === nothing || filter(m::ModelInstance))])
plot_get_renderers(; kw...) = (plot::ModelInstance) -> plot_get_renderers(plot; kw...)

function plot_get_renderer(plot::ModelInstance; plural, kw...)
    ms = plot_get_renderers(plot; kw...)
    if length(ms) == 0
        return Undefined()
    elseif length(ms) == 1
        return ms[1]
    else
        error("multiple $plural defined, consider using .$plural instead")
    end
end
plot_get_renderer(; kw...) = (plot::ModelInstance) -> plot_get_renderer(plot; kw...)

generate_model_types()

const RESOURCES = Dict(
    name => Resource(
        type = "js",
        name = name,
        url = "https://cdn.bokeh.org/bokeh/release/$name-$BOKEH_VERSION.min.js",
        raw = read(joinpath(dirname(@__DIR__), "bokehjs", "$name-$BOKEH_VERSION.min.js"), String),
    )
    for name in ["bokeh", "bokeh-gl", "bokeh-mathjax", "bokeh-widgets", "bokeh-tables"]
)

push!(Model.resources, RESOURCES["bokeh"], RESOURCES["bokeh-gl"], RESOURCES["bokeh-mathjax"])
push!(Widget.resources, RESOURCES["bokeh-widgets"])
push!(TableWidget.resources, RESOURCES["bokeh-tables"])

"""
    js_on_change(model, event, callbacks...)

Attach [`CustomJS`](@ref) callbacks to an arbitrary BokehJS model change event.

Change events for model properties are of the form `"change:property_name"` but as a
convenience you can simply provide `"property_name"`.
"""
function js_on_change(model::ModelInstance, event::AbstractString, callbacks::ModelInstance...)
    # check inputs
    event = convert(String, event)
    all(cb -> ismodelinstance(cb, CustomJS), callbacks) || error("callbacks must be CustomJS instances")

    # convert property_name to change:property_name
    if haskey(modeltype(model).propdescs, Symbol(event))
        event = "change:$event"
    end

    # add the callbacks
    # TODO: the python library does not add a callback already there
    # TODO: trigger a change on js_property_callbacks (when we have triggers)
    cbs = model.js_property_callbacks::Dict{String,Vector{ModelInstance}}
    push!(get!(valtype(cbs), cbs, event), callbacks...)
    return
end

"""
    js_link(model, property, other_model, other_property)

Link two Bokeh model properties via JavaScript.

Whenever `model.property` is changed, then `other_property.other_model` is set to its value.
"""
function js_link(model::ModelInstance, property::String, other::ModelInstance, other_property::String, index=nothing)
    # ensure the properties exist
    haskey(modeltype(model).propdescs, Symbol(property)) || error("$(modeltype(model).name).$(property): invalid property")
    haskey(modeltype(other).propdescs, Symbol(other_property)) || error("$(modeltype(other).name).$(other_property): invalid property")

    # select the index
    selector = index === nothing ? "" : "[$(JSON3.write(index))]"

    # make the callback
    callback = CustomJS(
        args = Dict("other" => other),
        code = "other[$(JSON3.write(other_property))] = this[$(JSON3.write(property))]$selector"
    )

    js_on_change(model, "change:$property", callback)
    return
end

"""
    js_on_event(model, event, callbacks...)

Attach [`CustomJS`](@ref) callbacks to an arbitrary BokehJS model event.
"""
function js_on_event(model::ModelInstance, event::AbstractString, callbacks::ModelInstance...)
    # check inputs
    event = convert(String, event)
    all(cb -> ismodelinstance(cb, CustomJS), callbacks) || error("callbacks must be CustomJS instances")

    # add the callbacks
    # TODO: the python library does not add a callback already there
    # TODO: trigger a change on js_property_callbacks (when we have triggers)
    cbs = model.js_event_callbacks::Dict{String,Vector{ModelInstance}}
    push!(get!(valtype(cbs), cbs, event), callbacks...)
    return
end

const _js_on_click_methods = Dict(
    Button => ((m, cbs...) -> js_on_event(m, "button_click", cbs...)),
    Toggle => ((m, cbs...) -> js_on_change(m, "change:active", cbs...)),
    AbstractGroup => ((m, cbs...) -> js_on_change(m, "change:active", cbs...)),
    Dropdown => ((m, cbs...) -> (js_on_event(m, "button_click", cbs...); js_on_event(m, "menu_item_click", cbs...))),
)

"""
    js_on_click(model, callbacks...)

Attach [`CustomJS`](@ref) callbacks to run when the `model` is clicked.

This applies to button widgets such as [`Button`](@ref), [`Toggle`](@ref) and
[`Dropdown`](@ref). It also includes group widgets such as [`CheckboxGroup`](@ref),
[`RadioGroup`](@ref), [`CheckboxButtonGroup`](@ref) and [`RadioButtonGroup`](@ref).
"""
function js_on_click(model::ModelInstance, callbacks::ModelInstance...)
    # check inputs
    all(cb -> ismodelinstance(cb, CustomJS), callbacks) || error("callbacks must be CustomJS instances")

    # search for the right click method
    for t in modeltype(model).mro
        f = get(_js_on_click_methods, t, nothing)
        if f !== nothing
            f(model, callbacks...)
            return
        end
    end
    error("$(modeltype(model).name): not clickable")
end
