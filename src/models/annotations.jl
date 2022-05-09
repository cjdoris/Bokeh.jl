const Annotation = ModelType("Renderer";
    abstract = true,
    inherits = [Renderer],
    props = [
        :level => DefaultT("annotation"),
    ]
)

const TextAnnotation = ModelType("TextAnnotation";
    abstract = true,
    inherits = [Annotation],
)

const Title = ModelType("Title";
    inherits = [TextAnnotation],
    props = [
        :text => StringT(default=""),
    ]
)

const LegendItem = ModelType("LegendItem";
    props = [
        :label => NullStringSpecT(),
        :renderers => ListT(InstanceT(GlyphRenderer)),
        :index => NullableT(IntT()),
        :visible => BoolT(default=true),
    ]
)

const Legend = ModelType("Legend",
    inherits = [Annotation],
    props = [
        :location => EitherT(LegendLocationT(), TupleT(FloatT(), FloatT()), default="top_right"),
        :orientation => OrientationT(default="vertical"),
        :title => NullableT(StringT()),
        :title => SCALAR_TEXT_PROPS,
        :title_text_font_size => DefaultT("13px"),
        :title_text_font_style => DefaultT("italic"),
        :title_standoff => IntT(default=5),
        :border => SCALAR_LINE_PROPS,
        :border_line_color => DefaultT("#e5e5e5"),
        :border_line_alpha => DefaultT(0.5),
        :background => SCALAR_FILL_PROPS,
        :inactive => SCALAR_FILL_PROPS,
        :click_policy => LegendClickPolicyT(default="none"),
        :background_fill_color => DefaultT("#ffffff"),
        :background_fill_alpha => DefaultT(0.95),
        :inactive_fill_color => DefaultT("white"),
        :inactive_fill_alpha => DefaultT(0.7),
        :label => SCALAR_TEXT_PROPS,
        :label_text_baseline => DefaultT("middle"),
        :label_text_font_size => DefaultT("13px"),
        :label_standoff => IntT(default=5),
        :label_height => IntT(default=20),
        :label_width => IntT(default=20),
        :glyph_height => IntT(default=20),
        :glyph_width => IntT(default=20),
        :margin => IntT(default=10),
        :padding => IntT(default=10),
        :spacing => IntT(default=3),
        :items => ListT(InstanceT(LegendItem)),
    ]
)
