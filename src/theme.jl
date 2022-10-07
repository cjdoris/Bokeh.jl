"""
    Theme(source)

Construct a theme from the given source, which is either:
- The name of a [builtin theme](@ref themes).
- The name of a JSON or YAML file.
- An iterator of the form `[type => [attr => value, ...], ...]`.

For example, here is a theme which overrides some attributes on all figures, axes, grids
and titles:
```julia
Theme([
    "Figure" => [
        "background_fill_color" => "#2F2F2F",
        "border_fill_color" => "#2F2F2F",
        "outline_line_color" => "#444444",
    ],
    "Axis" => [
        "axis_line_color" => nothing,
    ],
    "Grid" => [
        "grid_line_dash" => [6, 4],
        "grid_line_alpha" => 0.3,
    ],
    "Title" => [
        "text_color" => "white",
    ],
])
```

You can apply a theme globally using [`Bokeh.settings!`](@ref) or on a particular plot by
wrapping it into a [`Document`](@ref).
"""
function Theme(attrs)
    ans = Theme()
    for (k, v) in attrs
        ans.attrs[Symbol(k)] = Dict{Symbol,Any}(Symbol(k) => v for (k,v) in v)
    end
    return ans
end

function Theme(name::AbstractString)
    if any(in(('.', '/', '\\')), name)
        return load_theme(name)
    else
        return named_theme(name)
    end
end

function Theme(theme::Theme)
    return theme
end

function named_theme(name::AbstractString)
    theme = get(THEMES, name, nothing)
    theme === nothing && error("no such builtin theme: $(repr(name)), expecting one of $(join(sort([repr(k) for k in keys(THEMES)]), ", ", " or "))")
    return deepcopy(theme)  # so we can modify it
end

"""
    load_theme(filename)

Load a theme from the given file.

The format (JSON or YAML) is deduced from the file name.
"""
function load_theme(filename::AbstractString)
    ext = lowercase(splitext(filename)[2])
    if ext == ".json"
        data = open(JSON3.read, filename)
        return Theme(data["attrs"])
    elseif ext in (".yml", ".yaml")
        error("loading themes from YAML is not implemented")
    else
        error("themes must be in JSON or YAML format")
    end
end

"""
    save_theme(filename, [theme])

Save the given theme to the given file.

If `theme` is not given, the default theme is saved.

The format (JSON or YAML) is deduced from the file name.
"""
function save_theme(filename::AbstractString, theme::Theme=setting(:theme))
    json = Dict(:attrs => theme.attrs)
    ext = lowercase(splitext(filename)[2])
    if ext == ".json"
        open(filename, "w") do io
            JSON3.write(io, json)
        end
    elseif ext in (".yml", ".yaml")
        error("saving themes as YAML is not implemented")
    else
        error("themes can only be saved to JSON or YAML format")
    end
    return
end

"""
    theme!([theme], "Type.attr" => value, ...)

Modify the `theme` with the given key-value pairs.

If `theme` is not given, the default theme is modified.

For example, here we change the default height and width of all plots:
```
Bokeh.theme!("Plot.width"=>1000, "Plot.height"=>800)
```
"""
function theme!(theme::Theme, attrs::Pair...)
    for (k, v) in attrs
        k = String(k)
        '.' in k || error("each attr must be of the form \"Type.attribute\"")
        t, a = split(k, '.', limit=2)
        dict = get!(valtype(theme.attrs), theme.attrs, Symbol(t))
        dict[Symbol(a)] = v
    end
end
function theme!(attrs::Pair...)
    theme!(setting(:theme), attrs...)
end

function Base.show(io::IO, ::MIME"text/plain", theme::Theme)
    show(io, typeof(theme))
    print(io, ":")
    isblank = true
    if !isempty(theme.attrs)
        isblank = false
        for t in sort!(collect(keys(theme.attrs)))
            for k in sort!(collect(keys(theme.attrs[t])))
                println(io)
                print(io, "  ", t, ".", k, ": ")
                show(io, theme.attrs[t][k])
            end
        end
    end
    if isblank
        print(io, " (empty)")
    end
    return
end

generate_themes()
SETTINGS.theme = THEMES["default"]
