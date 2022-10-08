const DEFAULT_THEME = Dict{String,Any}(
    "categorical_palette" => "Dark2",
    "continuous_palette" => "Viridis",
    "markers" => ["circle", "square", "triangle"],
    "hatch_patterns" => ["/", "\\", "+", ".", "o"],
    "legend_location" => "right",
    "x_axis_location" => "below",
    "y_axis_location" => "left",
)

const BOKEH_THEME = Bokeh.Theme([
    "Algebrokeh" => DEFAULT_THEME,
    "Plot" => Pair[
        "width" => 1000,
    ],
    "Legend" => Pair[
        "title_text_font_style" => "bold",
    ],
    "Axis" => Pair[
        "axis_label_text_font_style" => "bold",
    ],
])

function _as_theme(xs)
    if xs isa Dict{String,Any}
        theme = xs
    else
        theme = Dict{String,Any}()
        if xs !== nothing
            for (k, v) in xs
                theme[String(k)] = v
            end
        end
    end
    return theme
end

function _get_theme(themes, k)
    for theme in themes
        if haskey(theme, k)
            return theme[k]
        end
    end
    return DEFAULT_THEME[k]
end
