mutable struct Settings
    display::AbstractDisplayBackend
    offline::Bool
    browser_cmd::Union{Nothing,Cmd}
    tempdir::Union{Nothing,String}
    theme::Theme
end

const SETTINGS = Settings(NullDisplayBackend(), false, nothing, nothing, Theme())

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
- `theme`:
  The [`Theme`](@ref) to apply when displaying plots. May instead be the name of a [builtin
  theme](@ref themes) or a JSON or YAML file.
  Default: `Theme()`.
"""
function settings!(;
    display=nothing,
    offline=nothing,
    browser_cmd=nothing,
    tempdir=nothing,
    theme=nothing,
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
    if theme !== nothing
        SETTINGS.theme = Theme(theme)
    end
    return
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
    else
        @assert false
    end
    setproperty!(SETTINGS, k, ans2)
    return getproperty(SETTINGS, k)
end
