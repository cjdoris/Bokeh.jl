mutable struct Settings
    offline::Bool
    use_browser::Bool
    browser_cmd::Union{Nothing,Cmd}
    tempdir::Union{Nothing,String}
    css_raw::Union{Nothing,Vector{String}}
    css_urls::Union{Nothing,Vector{String}}
    js_raw::Union{Nothing,Vector{String}}
    js_urls::Union{Nothing,Vector{String}}
    # theme?
end

const SETTINGS = Settings(false, false, nothing, nothing, nothing, nothing, nothing, nothing)

"""
    settings!(key=value, ...)

Update the global settings for Bokeh.

- `offline`:
  If set to `true` then any generated plots will work offline.
  Default: `false`.
- `use_browser`:
  If set to `true` then plots will be displayed by opening a browser.
  Default: `false`.
- `browser_cmd`:
  The command used to open the browser.
  Default: `xdg-open`, `open` or `cmd /c start` depending on your operating system.
"""
function settings!(;
    offline=nothing,
    use_browser=nothing,
    browser_cmd=nothing,
    tempdir=nothing,
    css_raw=nothing,
    css_urls=nothing,
    js_raw=nothing,
    js_urls=nothing,
)
    if offline !== nothing
        SETTINGS.offline = offline
    end
    if use_browser !== nothing
        SETTINGS.use_browser = use_browser
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
    ans === nothing || return ans
    if k == :browser_cmd
        ans2 = Sys.iswindows() ? `cmd /c start` : Sys.isapple() ? `open` : `xdg-open`
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
