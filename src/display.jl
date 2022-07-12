### ABSTRACT BACKEND

const DISPLAY_BACKENDS = Dict{Symbol,AbstractDisplayBackend}()

const EXTERNAL_DISPLAY_BACKENDS = Dict{Symbol,Symbol}(:blink => :BokehBlink)

function backend_display(::AbstractDisplayBackend, doc::Document)
    @nospecialize
    throw(MethodError(display, (BokehDisplay(), doc)))
end

function register_display_backend(name::Symbol, backend::AbstractDisplayBackend)
    @nospecialize
    DISPLAY_BACKENDS[name] = backend
    return
end

### BROWSER BACKEND

function backend_display(::BrowserDisplayBackend, doc::Document)
    path = joinpath(abspath(setting(:tempdir)), "plot.html")
    open(path, "w") do io
        write(io, doc_standalone_html(doc))
    end
    cmd = setting(:browser_cmd)
    if cmd === nothing
        DefaultApplication.open(path, wait=true)
    else
        run(`$cmd $path`)
    end
    return
end

### DISPLAY

function Base.display(::BokehDisplay, doc::Document)
    backend = setting(:display)::AbstractDisplayBackend
    backend_display(backend, doc)::Nothing
end

function Base.display(::BokehDisplay, x::ModelInstance)
    ismodelinstance(x, LayoutDOM) || throw(MethodError(display, (BokehDisplay(), x)))
    return display(BokehDisplay(), Document(x))
end
