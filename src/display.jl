mutable struct BokehDisplay <: Base.Multimedia.AbstractDisplay end

function Base.display(d::BokehDisplay, m::MIME"text/html", x::Document)
    if setting(:use_browser)
        path = joinpath(setting(:tempdir), "plot.html")
        open(path, "w") do io
            write(io, doc_standalone_html(x; bundle=bundle()))
        end
        if is_wsl()
            # It's a bit tricky to resolve WSL path correctly so as a workaround just cd into it
            # https://github.com/fish-shell/fish-shell/issues/6338
            cd(setting(:tempdir)) do
                run(`$(setting(:browser_cmd)) plot.html`)
            end
        else
            run(`$(setting(:browser_cmd)) $(path)`)
        end
        return
    else
        throw(MethodError(display, (d, m, x)))
    end
end

function Base.display(d::BokehDisplay, x::Document)
    return display(d, MIME("text/html"), x)
end

function Base.display(d::BokehDisplay, m::MIME"text/html", x::ModelInstance)
    ismodelinstance(x, LayoutDOM) || throw(MethodError(display, (d, m, x)))
    return display(d, m, Document(x))
end

function Base.display(d::BokehDisplay, x::ModelInstance)
    return display(d, MIME("text/html"), x)
end
