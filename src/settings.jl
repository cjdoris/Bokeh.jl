mutable struct Settings
    display::AbstractDisplayBackend
    offline::Bool
    browser_cmd::Union{Nothing,Cmd}
    tempdir::Union{Nothing,String}
    css_raw::Union{Nothing,Vector{String}}
    css_urls::Union{Nothing,Vector{String}}
    js_raw::Union{Nothing,Vector{String}}
    js_urls::Union{Nothing,Vector{String}}
    # theme?
end

const SETTINGS = Settings(NullDisplayBackend(), false, nothing, nothing, nothing, nothing, nothing, nothing)

"""
    settings!(key=value, ...)

Update the global settings for Bokeh.

- `display`:
  The display backend to use, such as `:browser` or `:blink`.
  Default: `:null`.
- `offline`:
  If set to `true` then any generated plots will work offline.
  Default: `false`.
- `browser_cmd`:
  The command used to open the browser.
  Default: Operating-system dependent.
"""
function settings!(;
    display=nothing,
    offline=nothing,
    browser_cmd=nothing,
    tempdir=nothing,
    css_raw=nothing,
    css_urls=nothing,
    js_raw=nothing,
    js_urls=nothing,
)
    if display !== nothing
        if display isa AbstractDisplayBackend
            SETTINGS.display = display
        elseif display isa Symbol
            display_backend = get(DISPLAY_BACKENDS, display, nothing)
            if display_backend === nothing
                display_package = get(EXTERNAL_DISPLAY_BACKENDS, display, nothing)
                if display_package === nothing
                    error("Unknown display: $display")
                else
                    error("Unknown display: $display (you need to install and import the $display_package module)")
                end
            end
            SETTINGS.display = display_backend
        else
            error("display must be a Symbol")
        end
    end
    if offline !== nothing
        SETTINGS.offline = offline
    end
    if browser_cmd !== nothing
        SETTINGS.browser_cmd = browser_cmd
    end
    if tempdir !== nothing
        SETTINGS.tempdir = tempdir
    end
    if css_raw !== nothing
        SETTINGS.css_raw = css_raw
    end
    if css_urls !== nothing
        SETTINGS.css_urls = css_urls
    end
    if js_raw !== nothing
        SETTINGS.js_raw = js_raw
    end
    if js_urls !== nothing
        SETTINGS.js_urls = js_urls
    end
end

"""
    setting(name::Symbol)

Retrieve the setting with the given name.

See [`settings!`](@ref) for the possible settings.
"""
function setting(k::Symbol)
    ans = getproperty(SETTINGS, k)
    if k == :browser_cmd || ans !== nothing
        return ans
    elseif k == :tempdir
        ans2 = mktempdir()
    elseif k == :css_raw
        ans2 = String[]
    elseif k == :css_urls
        ans2 = String[]
    elseif k == :js_raw
        ans2 = [
            read(joinpath(dirname(@__DIR__), "bokehjs", "bokeh$x-$BOKEH_VERSION.min.js"), String)
            for x in ["", "-gl", "-widgets", "-tables", "-mathjax"]
        ]
    elseif k == :js_urls
        ans2 = [
            "https://cdn.bokeh.org/bokeh/release/bokeh$x-$BOKEH_VERSION.min.js"
            for x in ["", "-gl", "-widgets", "-tables", "-mathjax"]
        ]
    else
        @assert false
    end
    setproperty!(SETTINGS, k, ans2)
    return getproperty(SETTINGS, k)
end

function bundle()
    z = String[]
    if setting(:offline)
        (js_urls=z, js_raw=setting(:js_raw), css_urls=z, css_raw=setting(:css_raw))
    else
        (js_urls=setting(:js_urls), js_raw=z, css_urls=setting(:css_urls), css_raw=z)
    end
end
