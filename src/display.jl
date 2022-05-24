"""
    BrowserDisplay()

Displays Bokeh plots in the Browser.

Activate with `pushdisplay(Bokeh.BrowserDisplay())`.
"""
struct BrowserDisplay <: Base.Multimedia.AbstractDisplay end

const IS_WSL = Sys.islinux() && isfile("/proc/sys/kernel/osrelease") && occursin(r"microsoft|wsl"i, read("/proc/sys/kernel/osrelease", String))

function Base.display(::BrowserDisplay, ::MIME"text/html", doc::Document)
    path = joinpath(abspath(setting(:tempdir)), "plot.html")
    open(path, "w") do io
        write(io, doc_standalone_html(doc; bundle=bundle()))
    end
    cmd = setting(:browser_cmd)
    if cmd === nothing
        @static if IS_WSL
            # this branch can be removed if DefaultApplication ever supports WSL
            # note: wslview requires a relative path, hence basename/dirname here
            run(Cmd(`wslview $(basename(path))`, dir=dirname(path)))
        else
            DefaultApplication.open(path, wait=true)
        end
    else
        run(`$cmd $path`)
    end
    return
end

function Base.display(d::BrowserDisplay, doc::Document)
    return display(d, MIME("text/html"), doc)
end

function Base.display(d::BrowserDisplay, m::MIME"text/html", x::ModelInstance)
    ismodelinstance(x, LayoutDOM) || throw(MethodError(display, (d, m, x)))
    return display(d, m, Document(x))
end

function Base.display(d::BrowserDisplay, x::ModelInstance)
    return display(d, MIME("text/html"), x)
end
