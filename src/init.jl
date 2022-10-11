function __init__()
    pushdisplay(BokehDisplay())
    register_display_backend(:null, NullDisplayBackend())
    register_display_backend(:browser, BrowserDisplayBackend())
    settings!(display="null", offline=false, theme="default")
end
