module BokehBlink

import Base64
import Blink
import Bokeh

const _curwin = Ref{Union{Nothing,Blink.Window}}(nothing)

const _hiddenwin = Ref{Union{Nothing,Blink.Window}}(nothing)

const _opts = Dict{String,Any}(
    "title" => "Bokeh.jl",
    "alwaysOnTop" => true,
    "width" => 600,
    "height" => 600,
    "useContentSize" => true,
)

function data_url(mime, data)
    return "data:$mime;base64,$(Base64.base64encode(data))"
end

function load_bundle(window, bundle=Bokeh.bundle())
    for url in bundle.js_urls
        Blink.loadjs!(window, url)
    end
    for code in bundle.js_raw
        Blink.loadjs!(window, data_url("text/javascript", code))
    end
    for url in bundle.css_urls
        Blink.loadcss!(window, url)
    end
    for code in bundle.css_raw
        Blink.loadcss!(window, data_url("text/css", code))
    end
end

function newwin()
    window = Blink.Window(_opts)
    load_bundle(window)
    _curwin[] = window
    return window
end

function curwin()
    window = _curwin[]
    if window === nothing || !Blink.active(window)
        window = newwin()
    end
    return window
end

function hiddenwin()
    window = _hiddenwin[]
    if window === nothing || !Blink.active(window)
        window = Blink.Window(Dict("show"=>false, "paintWhenInitiallyHidden"=>true))
        load_bundle(window)
        _hiddenwin[] = window
    end
    return window
end

"""
    display(doc_or_plot; window=curwin())

Displays a Bokeh document or plot in the given Blink window.
"""
function display(doc::Bokeh.Document; window=curwin())
    Blink.body!(window, Bokeh.doc_inline_html(doc))
    return
end

function display(plot::Bokeh.ModelInstance; kw...)
    Bokeh.ismodelinstance(plot, Bokeh.LayoutDOM) || error("plot must be a LayoutDOM")
    return display(Bokeh.Document(plot); kw...)
end

### DISPLAY BACKEND

struct BlinkDisplayBackend <: Bokeh.AbstractDisplayBackend end

function Bokeh.backend_display(::BlinkDisplayBackend, doc::Bokeh.Document)
    display(doc)
    return
end

function __init__()
    Bokeh.register_display_backend(:blink, BlinkDisplayBackend())
end

### SAVE

function get_image_url(; window=curwin(), mime="image/png")
    return Blink.@js(window, document.getElementsByTagName("canvas")[0].toDataURL($mime))::String
end

function get_image_url(plot; mime="image/png")
    window = hiddenwin()
    display(plot; window)
    # TODO: a more robust way to wait for the plot to be plotted
    sleep(1.0)
    return get_image_url(; window, mime)
end

function data_url_to_bytes(url, mime)
    prefix = "data:$mime;base64,"
    if !startswith(url, prefix)
        error("expecting data URL to start with $(repr(prefix)), actually starts with $(repr(url[1:min(lastindex(url),lastindex(prefix))]))")
    end
    return Base64.base64decode(SubString(url, sizeof(prefix)+1))
end

function get_image_bytes(; window=curwin(), mime="image/png")
    url = get_image_url(; window, mime)
    return data_url_to_bytes(url, mime)
end

function get_image_bytes(plot; mime="image/png")
    url = get_image_url(plot; mime)
    return data_url_to_bytes(url, mime)
end

"""
    save(io_or_filename, [plot]; mime="image/png")

Save a screenshot of the current plot or the given plot.

!!! warning

    This is an experimental feature and likely to be buggy, particularly the version taking
    a `plot` argument.
"""
function save(io::IO, args...; kw...)
    write(io, get_image_bytes(args...; kw...))
    return
end

function save(filename::AbstractString, args...; kw...)
    open(io->save(io, args...; kw...), filename, write=true)
    return
end

end # module
