const LINE_PROPS = [
    :line_color => ColorSpecT() |> DefaultT("black"),
    :line_alpha => AlphaSpecT(),
    :line_width => SizeSpecT() |> DefaultT(1.0),
    # :line_join => linejoinspec(DefaultT="bevel"),
    # :line_cap => linecapspec(DefaultT="butt"),
    # :line_dash => dashpatternspec(DefaultT=()->[]),
    :line_dash_offset => IntSpecT() |> DefaultT(0),
]

const SCALAR_LINE_PROPS = [
    :line_color => ColorT() |> NullableT |> DefaultT("black"),
    :line_alpha => AlphaT(),
    :line_width => FloatT() |> DefaultT(1.0),
    # :line_join => linejoinprop(DefaultT="bevel"),
    # :line_cap => linecapspec(DefaultT="butt"),
    # :line_dash => dashpatternprop(DefaultT=()->[]),
    :line_dash_offset => IntT() |> DefaultT(0),
]

const FILL_PROPS = [
    :fill_color => ColorSpecT() |> DefaultT("gray"),
    :fill_alpha => AlphaSpecT(),
]

const SCALAR_FILL_PROPS = [
    :fill_color => ColorT() |> NullableT |> DefaultT("gray"),
    :fill_alpha => AlphaT(),
]

const HATCH_PROPS = [
    :hatch_color => ColorSpecT() |> DefaultT("black"),
    :hatch_alpha => AlphaSpecT(),
    :hatch_scale => SizeSpecT() |> DefaultT(12.0),
    # :hatch_pattern => hatchpatternspec(DefaultT=nothing),
    :hatch_weight => SizeSpecT() |> DefaultT(1.0),
    :hatch_extra => DictT(StringT(), AnyT()),
]

const SCALAR_HATCH_PROPS = [
    :hatch_color => ColorSpecT() |> DefaultT("black"),
    :hatch_alpha => AlphaT(),
    :hatch_scale => SizeT() |> DefaultT(12.0),
    # :hatch_pattern => hatchpatternprop(DefaultT=nothing),
    :hatch_weight => SizeT() |> DefaultT(1.0),
    :hatch_extra => DictT(StringT(), AnyT()),
]

const TEXT_PROPS = [
    :text_color => ColorSpecT(default=Value("#444444")),
    :text_alpha => AlphaSpecT(),
    :text_font => StringSpecT(default=Value("helvetica")),
    :text_font_size => FontSizeSpecT(default=Value("16px")),
    :text_font_style => FontStyleSpecT(default=Value("normal")),
    :text_align => TextAlignSpecT(default=Value("left")),
    :text_baseline => TextBaselineSpecT(default=Value("bottom")),
    :text_line_height => NumberSpecT(default=Value(1.2)),
]

const SCALAR_TEXT_PROPS = [
    :text_color => NullableT(ColorT(), default="#444444"),
    :text_alpha => AlphaT(),
    :text_font => StringT(default="helvetica"),
    :text_font_size => FontSizeT(default="16px"),
    :text_font_style => FontStyleT(default="normal"),
    :text_align => TextAlignT(default="left"),
    :text_baseline => TextBaselineT(default="bottom"),
    :text_line_height => FloatT(default=1.2),
]
