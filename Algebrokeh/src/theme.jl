const ThemeDict = Dict{Symbol,Any}

const DEFAULT_THEME = ThemeDict(
    :categorical_palette => "Dark2",
    :continuous_palette => "Viridis",
    :markers => ["circle", "square", "triangle"],
    :hatch_patterns => ["/", "\\", "+", ".", "o"],
    :legend_location => "right",
    :x_axis_location => "below",
    :y_axis_location => "left",
)

const BOKEH_THEME = Bokeh.Theme([
    :Algebrokeh => DEFAULT_THEME,
    :Plot => ThemeDict(
        :width => 1000,
    ),
    :Legend => ThemeDict(
        :title_text_font_style => "bold",
    ),
    :Axis => ThemeDict(
        :axis_label_text_font_style => "bold",
    ),
    :Glyph => ThemeDict(
        :fill_alpha => 0.5,
    ),
    :Marker => ThemeDict(
        :size => 10,
    ),
])

function _as_theme(xs)
    if xs isa ThemeDict
        theme = xs
    else
        theme = ThemeDict()
        if xs !== nothing
            for (k, v) in xs
                theme[Symbol(k)] = v
            end
        end
    end
    return theme
end

function _get_theme(theme, k)
    get(theme, k) do
        DEFAULT_THEME[k]
    end
end
