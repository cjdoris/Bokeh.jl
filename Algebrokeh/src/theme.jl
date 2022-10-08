const ThemeDict = Dict{Symbol,Any}

const DEFAULT_THEME = ThemeDict(
    :categorical_palette => "Category10",
    :continuous_palette => "Viridis",
    :markers => ["circle", "square", "triangle"],
    :hatch_patterns => ["/", "\\", "+", ".", "o"],
    :legend_location => "right",
    :x_axis_location => "below",
    :y_axis_location => "left",
    :missing_label => "Unknown",
    :other_label => "Other",
)

const BOKEH_THEME = Bokeh.Theme([
    :Algebrokeh => DEFAULT_THEME,
    :Plot => ThemeDict(
        :width => 1000,
        :outline_line_width => 0,
    ),
    :Legend => ThemeDict(
        :title_text_font_size => "14px",
        :title_text_font_style => "bold",
        :border_line_width => 0,
        :glyph_height => 24,
        :glyph_width => 24,
    ),
    :Axis => ThemeDict(
        :axis_label_text_font_size => "14px",
        :axis_label_text_font_style => "bold",
        :axis_line_color => "#aaaaaa",
        :major_label_text_font_size => "13px",
        :major_tick_line_color => "#aaaaaa",
        :major_tick_in => 0,
        :minor_tick_line_color => "#aaaaaa",
    ),
    :ColorBar => ThemeDict(
        :title_text_font_size => "14px",
        :title_text_font_style => "bold",
        :title_standoff => 5,
        :major_label_text_font_size => "13px",
        :major_tick_out => 6,
        :major_tick_in => 0,
        :major_tick_line_color => "black",
    ),
    :Glyph => ThemeDict(
        :fill_alpha => 0.7,
    ),
    :Marker => ThemeDict(
        :size => 10,
    ),
    :Line => ThemeDict(
        :line_width => 3,
    ),
    :MultiLine => ThemeDict(
        :line_width => 3,
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
