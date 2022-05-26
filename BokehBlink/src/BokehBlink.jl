module BokehBlink

import Base64
import Blink
import Bokeh

### UTILS

function data_url(format, data)
    return "data:image/$format;base64,$(Base64.base64encode(data))"
end

function data_url_to_bytes(url, format)
    prefix = "data:image/$format;base64,"
    if !startswith(url, prefix)
        if startswith(url, "data:image/png;")
            error("unsupported format: $(repr(format))")
        else
            error("expecting data URL to start with $(repr(prefix)), actually starts with $(repr(url[1:min(lastindex(url),lastindex(prefix))]))")
        end
    end
    return Base64.base64decode(SubString(url, sizeof(prefix)+1))
end

function guess_format(filename)
    return split(basename(filename), '.'; limit=2)[end]
end

function guess_size(doc::Bokeh.Document)
    w = h = nothing
    for plot in doc.roots
        w0 = plot.width
        h0 = plot.height
        if w0 !== nothing
            w0 = convert(Int, w0)::Int
            w = w === nothing ? w0 : max(w, w0)
        end
        if h0 !== nothing
            h0 = convert(Int, h0)::Int
            h = h === nothing ? h0 : max(h, h0)
        end
    end
    if w === nothing
        w = 600
    end
    if h === nothing
        h = 600
    end
    return (w, h)
end

### DISPLAY

const _curwin = Ref{Union{Nothing,Blink.Window}}(nothing)

const _hiddenwin = Ref{Union{Nothing,Blink.Window}}(nothing)

const _opts = Dict{Symbol,Any}(
    :title => "Bokeh.jl",
    :icon => joinpath(@__DIR__, "bokeh-favicon-32x32.png"),
)

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

function newwin(; size=nothing, title=nothing, always_on_top=nothing)
    opts = copy(_opts)
    if size !== nothing
        opts[:width], opts[:height] = size
        opts[:useContentSize] = true
    end
    if title !== nothing
        opts[:title] = title
    end
    if always_on_top !== nothing
        opts[:alwaysOnTop] = always_on_top
    end
    window = Blink.Window(opts)
    load_bundle(window)
    _curwin[] = window
    return window
end

function curwin(; size=nothing, title=nothing)
    window = _curwin[]
    if !isopen(window)
        window = newwin(; size, title)
    else
        if size !== nothing
            setsize(size...; window)
        end
        if title !== nothing
            settitle(title; window)
        end
    end
    return window
end

function hiddenwin()
    window = _hiddenwin[]
    if !isopen(window)
        window = Blink.Window(Dict("show"=>false, "paintWhenInitiallyHidden"=>true))
        load_bundle(window)
        _hiddenwin[] = window
    end
    return window
end

isopen(::Nothing) = false
isopen(window) = Blink.active(window)

function close(window=_curwin[])
    if isopen(window)
        Blink.close(window)
    end
    return
end

function setsize(w, h; window=curwin())
    if isopen(window)
        Blink.@js window window.resizeTo($w + window.outerWidth - window.innerWidth, $h + window.outerHeight - window.innerHeight)
    end
    return
end

function settitle(title; window=curwin())
    if isopen(window)
        Blink.title(window, title)
    end
    return
end

"""
    display(doc_or_plot; window=curwin())

Displays a Bokeh document or plot in the given Blink window.
"""
function display(doc::Bokeh.Document; size=guess_size(doc), window=curwin(; size))
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

"""
    save(io, [plot]; ...)
    save(filename, [plot]; ...)

Save a screenshot of the current plot or the given plot.

# Keyword Arguments
- `format`: The output format to use. Valid formats include `"png"`, `"jpeg"` and `"webp"`.
  If `filename` is given, the format is inferred from the extension. Otherwise it defaults
  to `"png"`.
- `quality`: A number between 0 and 1 specifying the quality (compression level) of the
  image.

!!! warning

    This is an experimental feature and likely to be buggy, particularly the version taking
    a `plot` argument.
"""
function save(out::Union{IO,AbstractString}, plot=nothing;
    format = out isa AbstractString ? guess_format(out) : "png",
    window = plot === nothing ? curwin() : hiddenwin(),
    quality = -1,
)
    # normalize the format
    format = lowercase(format)
    if format == "jpg"
        format = "jpeg"
    end
    # display the plot, if given
    if plot !== nothing
        display(plot; window)
        # TODO: a more robust way to wait for the plot to be plotted
        sleep(1.0)
    end
    # get the screenshot
    mime = "image/$format"
    url = Blink.@js(window, document.getElementsByTagName("canvas")[0].toDataURL($mime, $quality))::String
    image = data_url_to_bytes(url, format)
    write(out, image)
    return
end

end # module
