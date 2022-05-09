mutable struct BrowserDisplay <: Base.Multimedia.AbstractDisplay
    cmd::Cmd
    enabled::Bool
    path::String
end

function Base.display(d::BrowserDisplay, m::MIME"text/html", x::Document)
    d.enabled || throw(MethodError(display, (d, m, x)))
    open(d.path, "w") do io
        write(io, doc_standalone_html(x; bundle=BUNDLE_BOKEH_CDN))
    end
    run(`$(d.cmd) $(d.path)`)
    return
end

function Base.display(d::BrowserDisplay, x::Document)
    return display(d, MIME("text/html"), x)
end

function Base.display(d::BrowserDisplay, m::MIME"text/html", x::Model)
    ismodelinstance(x, LayoutDOM) || throw(MethodError(display, (d, m, x)))
    return display(d, m, Document(x))
end

function Base.display(d::BrowserDisplay, x::Model)
    return display(d, MIME("text/html"), x)
end

"""
    display_in_browser(; cmd=nothing, enabled=true, path=nothing)

Enable Bokeh to display plots in a browser.

# Arguments
- `cmd`: The command used to open the HTML file. If not given, a suitable default is used.
- `enabled`: Can be set to false to disable this functionality.
- `path`: The HTML file where the plot is saved. If not given, a temporary location is used.
"""
function display_in_browser(; cmd::Union{Cmd,Nothing}=nothing, enabled::Bool=nothing, path::Union{String,Nothing}=nothing)
    # try to update an existing display
    found = false
    for d in Base.Multimedia.displays
        if d isa BrowserDisplay
            if cmd !== nothing
                d.cmd = cmd
            end
            if path !== nothing
                d.path = path
            end
            d.enabled = enabled
        end
    end
    # create a new display
    if !found && enabled
        if cmd === nothing
            if Sys.iswindows()
                if (exe = Sys.which("cmd")) !== nothing
                    cmd = `$exe /D /C start`
                elseif (exe = Sys.which("pwsh")) !== nothing
                    cmd = `$exe -NoProfile -Command Start-Process`
                elseif (exe = Sys.which("powershell")) !== nothing
                    cmd = `$exe -NoProfile -Command Start-Process`
                else
                    error("cannot find a suitable browser launcher (e.g. cmd, pwsh, powershell)")
                end
            elseif Sys.isapple()
                if (exe = Sys.which("open")) !== nothing
                    cmd = `$exe`
                else
                    error("cannot find a suitable brower launcher (e.g. open)")
                end
            else
                if (exe = Sys.which("xdg-open")) !== nothing
                    cmd = `$exe`
                else
                    error("cannot find a suitable browser launcher (e.g. xdg-open)")
                end
            end
        end
        if path === nothing
            path = joinpath(mktempdir(), "plot.html")
        end
        d = BrowserDisplay(cmd, enabled, path)
        pushdisplay(d)
    end
    return
end
