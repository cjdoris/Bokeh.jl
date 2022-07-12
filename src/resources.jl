function Base.show(io::IO, res::Resource)
    show(io, typeof(res))
    print(io, "(type=")
    show(io, res.type)
    print(io, ", name=")
    show(io, res.name)
    print(io, ", url=")
    show(io, res.url)
    print(io, ", ...)")
    return
end

function bundle(resources; offline::Bool=setting(:offline))
    js_urls = String[]
    css_urls = String[]
    js_raw = String[]
    css_raw = String[]
    for res in resources
        if offline
            value = res.raw
            value == "" && error("resource $(repr(res.name)) has no raw value for offline mode")
            israw = true
        else
            value = res.url
            israw = false
            if value == ""
                value = res.raw
                value == "" && error("resource $(repr(res.name)) has no URL or raw value")
                israw = true
            end
        end
        if res.type == "js"
            if israw
                push!(js_raw, value)
            else
                push!(js_urls, value)
            end
        elseif res.type == "css"
            if israw
                push!(css_raw, value)
            else
                push!(css_urls, value)
            end
        end
    end
    return (; js_urls, js_raw, css_urls, css_raw)
end
