mutable struct Settings
    offline::Bool
    use_browser::Bool
    browser_cmd::Union{Nothing,Cmd}
    tempdir::Union{Nothing,String}
    # theme?
end

const SETTINGS = Settings(false, false, nothing, nothing)

function settings!(;
    offline::Union{Nothing,Bool}=nothing,
    use_browser::Union{Nothing,Bool}=nothing,
    browser_cmd::Union{Cmd,Nothing}=nothing,
    tempdir::Union{Nothing,String}=nothing,
)
    if offline !== nothing
        SETTINGS.offine = offline
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
end

function setting(k::Symbol)
    if k == :browser_cmd
        let
            ans = SETTINGS.browser_cmd
            if ans === nothing
                ans = Sys.iswindows() ? `cmd /c start` : Sys.isapple() ? `open` : `xdg-open`
                SETTINGS.browser_cmd = ans
            end
            return ans
        end
    elseif k == :tempdir
        let
            ans = SETTINGS.tempdir
            if ans === nothing
                ans = mktempdir()
                SETTINGS.tempdir = ans
            end
            return ans
        end
    else
        getproperty(SETTINGS, k)
    end
end
