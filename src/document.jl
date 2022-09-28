"""
    Document(plot; [theme])

Construct a new document to render the given `plot`.

The given `theme` (a [`Theme`](@ref)) is used to override attributes of the plot. It takes
precedence over the global theme set using [`Bokeh.settings!`](@ref).
"""
Document(root::ModelInstance; kw...) = Document([root]; kw...)
Document(roots; theme=setting(:theme)) = Document(roots, Theme(theme))

function serialize(doc::Document; backend_theme=Theme(), themes=Theme[backend_theme, setting(:theme), doc.theme])
    ser = Serializer(; themes)
    for model in doc.roots
        serialize(ser, model)
    end
    return SerializedDocument(doc, ser)
end

function doc_resources(sdoc::SerializedDocument)
    ans = Resource[]
    for model in values(sdoc.ser.refs)
        for t in reverse(modeltype(model).mro)
            union!(ans, t.resources)
        end
    end
    return ans
end

function docs_resources(sdocs)
    ans = Resource[]
    for (_, sdoc) in sdocs
        union!(ans, doc_resources(sdoc))
    end
    return ans
end

doc_bundle(sdoc; kw...) = bundle(doc_resources(sdoc); kw...)

docs_bundle(sdocs; kw...) = bundle(docs_resources(sdocs); kw...)

function root_ids_json(sdoc::SerializedDocument)
    return [modelid(model) for model in sdoc.doc.roots]
end

function refs_json(sdoc::SerializedDocument)
    return collect(values(sdoc.ser.refscache))
end

function doc_json(sdoc::SerializedDocument)
    return Dict{String,Any}(
        "defs" => [],
        "roots" => Dict{String,Any}(
            "references" => refs_json(sdoc),
            "root_ids" => root_ids_json(sdoc),
        ),
        "title" => "Bokeh Application",
        "version" => string(BOKEH_VERSION),
    )
end

function docs_json(sdocs)
    return Dict(doc_id => doc_json(sdoc) for (doc_id, sdoc) in sdocs)
end

function docs_render_items_json(sdocs; elementid)
    return [
        Dict(
            "docid" => doc_id,
            "root_ids" => root_ids_json(sdoc),
            "roots" => Dict(
                modelid(model) => elementid
                for model in sdoc.doc.roots
            ),
        )
        for (doc_id, sdoc) in sdocs
    ]
end

function docs_js(sdocs; elementid, onload=true, autoload=false, bundle=docs_bundle(sdocs), kw...)
    code = template_doc_js(
        docs_json = tojson(docs_json(sdocs)),
        render_items = tojson(docs_render_items_json(sdocs; elementid))
    )
    if onload
        code = template_onload_js(; code)
    end
    if autoload
        code = template_autoload_js(; code, elementid, bundle, kw...)
    end
    return code
end

function doc_js(sdoc; elementid=new_global_id(), kw...)
    docs_js([elementid => sdoc]; elementid, kw...)
end

function doc_js_html(sdoc, src_path; elementid=new_global_id(), kw...)
    return (
        js = doc_js(sdoc; elementid, kw...),
        html = template_script_tag_html(; src_path, elementid),
    )
end

function doc_inline_html(sdoc; elementid=new_global_id(), kw...)
    template_inline_script_tag_html(
        code = doc_js(sdoc; elementid, kw...);
        elementid,
    )
end

function doc_standalone_html(sdoc; autoload=true, title="Bokeh Plot", kw...)
    """
    <!DOCTYPE html>
    <html>
        <head>
            <meta charset="utf8" />
            <title>$title</title>
        </head>
        <body>
            $(indent(doc_inline_html(sdoc; autoload, kw...), 8))
        </body>
    </html>
    """
end

function Base.show(io::IO, ::MIME"text/html", doc::Document)
    sdoc = serialize(doc)
    write(io, doc_inline_html(sdoc; autoload=true))
    return
end

function Base.show(io::IO, m::MIME"text/html", x::ModelInstance)
    ismodelinstance(x, LayoutDOM) || throw(MethodError(show, (io, m, x)))
    show(io, m, Document(x))
end
