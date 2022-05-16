mutable struct BokehDisplay <: Base.Multimedia.AbstractDisplay end

function Base.display(d::BokehDisplay, m::MIME"text/html", x::Document)
    if setting(:use_browser)
        path = joinpath(setting(:tempdir), "plot.html")
        open(path, "w") do io
            write(io, doc_standalone_html(x; bundle=bundle()))
        end
        cmd = setting(:browser_cmd)
        if first(cmd) == "wslview"
            # It's a bit tricky to resolve WSL path correctly so as a workaround just cd into it
            # https://github.com/fish-shell/fish-shell/issues/6338
            run(Cmd(`$cmd plot.html`, dir=setting(:tempdir)))
        else
            run(`$cmd $(path)`)
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
