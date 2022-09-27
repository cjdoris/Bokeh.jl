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

function guess_size(sdoc::Bokeh.SerializedDocument; oldsize=nothing)
    w = h = nothing
    fixed_width = false
    fixed_height = false
    for plot in sdoc.doc.roots
        attrs = sdoc.ser.refscache[Bokeh.modelid(plot)]["attributes"]::Dict{String,Any}
        sizing_mode = get(attrs, "sizing_mode", nothing)
        if oldsize === nothing
            ignore_width = sizing_mode ∈ ("stretch_width", "stretch_both")
            ignore_height = sizing_mode ∈ ("stretch_height", "stretch_both")
        else
            ignore_width = sizing_mode ∉ (nothing, "fixed", "stretch_height")
            ignore_height = sizing_mode ∉ (nothing, "fixed", "stretch_width")
        end
        w0 = get(attrs, "width", nothing)
        h0 = get(attrs, "height", nothing)
        if !ignore_width
            fixed_width = true
            if w0 !== nothing
                w0 = convert(Int, w0)::Int
                w = w === nothing ? w0 : max(w, w0)
            end
        end
        if !ignore_height
            fixed_height = true
            if h0 !== nothing
                h0 = convert(Int, h0)::Int
                h = h === nothing ? h0 : max(h, h0)
            end
        end
    end
    if (fixed_width || oldsize === nothing) && w === nothing
        w = oldsize === nothing ? 600 : convert(Int, oldsize[1])
    end
    if (fixed_height || oldsize === nothing) && h === nothing
        h = oldsize === nothing ? 600 : convert(Int, oldsize[2])
    end
    return (w, h)
end

### DISPLAY

mutable struct Window
    blink::Blink.Window
    resources::Vector{Bokeh.Resource}
end

Window(blink::Blink.Window) = Window(blink, Bokeh.Resource[])

const _curwin = Ref{Union{Nothing,Window}}(nothing)

const _hiddenwin = Ref{Union{Nothing,Window}}(nothing)

const _opts = Dict{Symbol,Any}(
    :title => "Bokeh.jl",
    :icon => joinpath(@__DIR__, "bokeh-favicon-32x32.png"),
)

const _theme = Bokeh.Theme(Dict(:Plot=>Dict(:sizing_mode => "stretch_both")))

function load_resources!(window::Window, resources)
    # filter out resources already loaded
    resources = Bokeh.Resource[res for res in resources if res ∉ window.resources]
    bundle = Bokeh.bundle(resources)
    for url in bundle.js_urls
        Blink.loadjs!(window.blink, url)
    end
    for url in bundle.css_urls
        Blink.loadcss!(window.blink, url)
    end
    for code in bundle.js_raw
        Blink.loadjs!(window.blink, data_url("text/javascript", code))
    end
    for code in bundle.css_raw
        Blink.loadcss!(window.blink, data_url("text/css", code))
    end
    append!(window.resources, resources)
    return window
end

function newwin(; size=nothing, sdoc=nothing, title=nothing, always_on_top=nothing)
    opts = copy(_opts)
    if size === nothing && sdoc !== nothing
        size = guess_size(sdoc)
    end
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
    window = Window(Blink.Window(opts))
    _curwin[] = window
    return window::Window
end

function curwin(; resize=true, sdoc=nothing, size=nothing, title=nothing)
    window = _curwin[]
    if !isopen(window)
        window = newwin(; title, size, sdoc)
    else
        if size === nothing && sdoc !== nothing && resize
            oldsize = (
                Blink.@js(window.blink, window.innerWidth)::Int,
                Blink.@js(window.blink, window.innerHeight)::Int,
            )
            size = guess_size(sdoc; oldsize)
        end
        if size !== nothing
            setsize(size...; window)
        end
        if title !== nothing
            settitle(title; window)
        end
    end
    return window::Window
end

function hiddenwin()
    window = _hiddenwin[]
    if !isopen(window)
        window = Window(Blink.Window(Dict("show"=>false, "paintWhenInitiallyHidden"=>true)))
        _hiddenwin[] = window
    end
    return window::Window
end

isopen(::Nothing) = false
isopen(window::Window) = isopen(window.blink)
isopen(window) = Blink.active(window)

function close(window=_curwin[])
    if isopen(window)
        Blink.close(window.blink)
    end
    return
end

function setsize(w, h; window=curwin())
    if isopen(window)
        w === nothing || Blink.@js window.blink window.resizeTo($w + window.outerWidth - window.innerWidth, window.outerHeight)
        h === nothing || Blink.@js window.blink window.resizeTo(window.outerWidth, $h + window.outerHeight - window.innerHeight)
    end
    return
end

function settitle(title; window=curwin())
    if isopen(window)
        Blink.title(window.blink, title)
    end
    return
end

"""
    display(doc_or_plot; window=curwin())

Displays a Bokeh document or plot in the given Blink window.
"""
function display(sdoc::Bokeh.SerializedDocument; resize=true, size=nothing, window=curwin(; resize, size, sdoc))
    load_resources!(window, Bokeh.doc_resources(sdoc))
    Blink.body!(window.blink, Bokeh.doc_inline_html(sdoc))
    return
end

function display(doc::Bokeh.Document; kw...)
    return display(Bokeh.serialize(doc; backend_theme=_theme); kw...)
end

function display(plot::Bokeh.ModelInstance; kw...)
    Bokeh.ismodelinstance(plot, Bokeh.LayoutDOM) || error("plot must be a LayoutDOM")
    return display(Bokeh.Document(plot); kw...)
end

### DISPLAY BACKEND

struct BlinkDisplayBackend <: Bokeh.AbstractDisplayBackend end

function Bokeh.backend_display(::BlinkDisplayBackend, sdoc::Bokeh.SerializedDocument)
    display(sdoc)
    return
end

function Bokeh.backend_theme(::BlinkDisplayBackend)
    return _theme
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
    url = Blink.@js(window.blink, document.getElementsByTagName("canvas")[0].toDataURL($mime, $quality))::String
    image = data_url_to_bytes(url, format)
    write(out, image)
    return
end

end # module
