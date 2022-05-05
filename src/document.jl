Document() = Document([])
Document(m::Model) = Document([m])

function root_ids_json(doc::Document)
    return [modelid(model) for model in doc.roots]
end

function refs_json(doc::Document)
    ser = Serializer()
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

function docs_autoload_js(docs, elementid; kw...)
    template_autoload_js(
        code = template_onload_js(
            code = template_doc_js(
                docs_json = tojson(docs_json(docs)),
                render_items = tojson(docs_render_items_json(docs; elementid))
            )
        ),
        elementid = elementid;
        kw...
    )
end

function doc_autoload_js(doc, elementid; kw...)
    docs_autoload_js([new_global_id() => doc], elementid; kw...)
end

function doc_autoload_js_html(doc, src; elementid=new_global_id(), kw...)
    return (
        doc_autoload_js(doc, elementid; kw...),
        template_autoload_tag_html(src_path=src, elementid=elementid)
    )
end

function doc_autoload_inline_html(doc; elementid=new_global_id(), kw...)
    template_autoload_tag_inline_html(
        code = doc_autoload_js(doc, elementid; kw...),
        elementid = elementid,
    )
end

function doc_standalone_html(doc; kw...)
    """
    <!DOCTYPE html>
    <html>
        <head>
            <meta charset="utf8" />
            <title>Bokeh Plot</title>
        </head>
        <body>
            $(indent(doc_autoload_inline_html(doc; kw...), 8))
        </body>
    </html>
    """
end

function Base.show(io::IO, ::MIME"text/html", doc::Document)
    write(io, doc_autoload_inline_html(doc; bundle=BUNDLE_BOKEH_CDN_NOMIN))
    return
end
