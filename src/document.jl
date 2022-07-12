Document(roots; theme::Theme=setting(:theme)) = Document(roots, theme)
Document(root::ModelInstance; kw...) = Document([root]; kw...)

function doc_resources(doc::Document)
    ans = Resource[]
    ser = Serializer()
    for model in doc.roots
        serialize(ser, model)
    end
    for model in values(ser.refs)
        for t in reverse(modeltype(model).mro)
            union!(ans, t.resources)
        end
    end
    return ans
end

function docs_resources(docs)
    ans = Resource[]
    for (_, doc) in docs
        union!(ans, doc_resources(doc))
    end
    return ans
end

doc_bundle(doc; kw...) = bundle(doc_resources(doc); kw...)

docs_bundle(docs; kw...) = bundle(docs_resources(docs); kw...)

function root_ids_json(doc::Document)
    return [modelid(model) for model in doc.roots]
end

function refs_json(doc::Document)
    ser = Serializer(; theme=doc.theme)
    for model in doc.roots
        serialize(ser, model)
    end
    return collect(values(ser.refscache))
end

function doc_json(doc::Document)
    return Dict{String,Any}(
        "defs" => [],
        "roots" => Dict{String,Any}(
            "references" => refs_json(doc),
            "root_ids" => root_ids_json(doc),
        ),
        "title" => "Bokeh Application",
        "version" => string(BOKEH_VERSION),
    )
end

function docs_json(docs)
    return Dict(doc_id => doc_json(doc) for (doc_id, doc) in docs)
end

function docs_render_items_json(docs; elementid)
    return [
        Dict(
            "docid" => doc_id,
            "root_ids" => root_ids_json(doc),
            "roots" => Dict(
                modelid(model) => elementid
                for model in doc.roots
            ),
        )
        for (doc_id, doc) in docs
    ]
end

function docs_js(docs; elementid, onload=true, autoload=false, bundle=docs_bundle(docs), kw...)
    code = template_doc_js(
        docs_json = tojson(docs_json(docs)),
        render_items = tojson(docs_render_items_json(docs; elementid))
    )
    if onload
        code = template_onload_js(; code)
    end
    if autoload
        code = template_autoload_js(; code, elementid, bundle, kw...)
    end
    return code
end

function doc_js(doc; elementid=new_global_id(), kw...)
    docs_js([elementid => doc]; elementid, kw...)
end

function doc_js_html(doc, src_path; elementid=new_global_id(), kw...)
    return (
        js = doc_js(doc; elementid, kw...),
        html = template_script_tag_html(; src_path, elementid),
    )
end

function doc_inline_html(doc; elementid=new_global_id(), kw...)
    template_inline_script_tag_html(
        code = doc_js(doc; elementid, kw...);
        elementid,
    )
end

function doc_standalone_html(doc; autoload=true, title="Bokeh Plot", kw...)
    """
    <!DOCTYPE html>
    <html>
        <head>
            <meta charset="utf8" />
            <title>$title</title>
        </head>
        <body>
            $(indent(doc_inline_html(doc; autoload, kw...), 8))
        </body>
    </html>
    """
end

function Base.show(io::IO, ::MIME"text/html", doc::Document)
    write(io, doc_inline_html(doc; autoload=true))
    return
end

function Base.show(io::IO, m::MIME"text/html", x::ModelInstance)
    ismodelinstance(x, LayoutDOM) || throw(MethodError(show, (io, m, x)))
    show(io, m, Document(x))
end
