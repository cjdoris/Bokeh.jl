mutable struct BokehDisplay <: Base.Multimedia.AbstractDisplay end

function Base.display(d::BokehDisplay, m::MIME"text/html", x::Document)
    if setting(:use_browser)
        path = joinpath(setting(:tempdir), "plot.html")
        open(path, "w") do io
            write(io, doc_standalone_html(x; bundle=BUNDLE_BOKEH_CDN))
        end
        run(`$(setting(:browser_cmd)) $(path)`)
        return
    else
        throw(MethodError(display, (d, m, x)))
    end
end

function Base.display(d::BokehDisplay, x::Document)
    return display(d, MIME("text/html"), x)
end

function Base.display(d::BokehDisplay, m::MIME"text/html", x::Model)
    ismodelinstance(x, LayoutDOM) || throw(MethodError(display, (d, m, x)))
    return display(d, m, Document(x))
end

function Base.display(d::BokehDisplay, x::Model)
    return display(d, MIME("text/html"), x)
end
