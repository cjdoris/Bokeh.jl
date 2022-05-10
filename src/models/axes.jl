const Axis = ModelType("Axis";
    abstract = true,
    bases = [GuideRenderer],
    props = [
        :bounds => EitherT(AutoT(), TupleT(FloatT(), FloatT())), # TODO datetime
        :ticker => TickerT(),
        :formatter => InstanceT(TickFormatter),
        :axis_label => NullableT(StringT()),
        :axis_label_standoff => IntT(default=5),
        :axis_label => SCALAR_TEXT_PROPS,
        :axis_label_text_font_size => DefaultT("13px"),
        :axis_label_text_font_style => DefaultT("italic"),
        :major_label_standoff => IntT(default=5),
        :major_label_orientation => EitherT(OrientationT(), FloatT()),
        :major_label_overrides => DictT(EitherT(FloatT(), StringT()), TextLikeT()),
        :major_label_policy => InstanceT(LabelingPolicy, default=()->AllLabels()),
        :major_label => SCALAR_TEXT_PROPS,
        :major_label_text_align => DefaultT("center"),
        :major_label_text_baseline => DefaultT("alphabetic"),
        :major_label_text_font_size => DefaultT("11px"),
        :axis => SCALAR_LINE_PROPS,
        :major_tick => SCALAR_LINE_PROPS,
        :major_tick_in => IntT(default=2),
        :major_tick_out => IntT(default=6),
        :minor_tick => SCALAR_LINE_PROPS,
        :minor_tick_in => IntT(default=0),
        :minor_tick_out => IntT(default=4),
        :fixed_location => EitherT(NullT(), FloatT(), FactorT()),
    ],
)

const ContinuousAxis = ModelType("ContinuousAxis";
    abstract = true,
    bases = [Axis],
)

const LinearAxis = ModelType("LinearAxis";
    bases = [ContinuousAxis],
    props = [
        :ticker => DefaultT(()->BasicTicker()),
        :formatter => DefaultT(()->BasicTickFormatter()),
    ]
)

const LogAxis = ModelType("LogAxis";
    bases = [ContinuousAxis],
    props = [
        :ticker => DefaultT(()->LogTicker()),
        :formatter => DefaultT(()->LogTickFormatter()),
    ]
)

const CategoricalAxis = ModelType("CategoricalAxis";
    bases = [Axis],
    props = [
        :ticker => DefaultT(()->CategoricalTicker()),
        :formatter => DefaultT(()->CategoricalTickFormatter()),
        :separator => SCALAR_LINE_PROPS,
        :separator_line_color => DefaultT("lightgrey"),
        :separator_line_width => DefaultT(2),
        :group => SCALAR_TEXT_PROPS,
        :group_label_orientation => EitherT(TickLabelOrientationT(), FloatT(), default="parallel"),
        :group_text_font_size => DefaultT("11px"),
        :group_text_font_style => DefaultT("bold"),
        :group_text_color => DefaultT("grey"),
        :subgroup => SCALAR_TEXT_PROPS,
        :subgroup_label_orientation => EitherT(TickLabelOrientationT(), FloatT(), default="parallel"),
        :subgroup_text_font_size => DefaultT("11px"),
        :subgroup_text_font_style => DefaultT("bold"),
    ]
)

const DatetimeAxis = ModelType("DatetimeAxis";
    bases = [LinearAxis],
    props = [
        :ticker => DefaultT(()->DatetimeTicker()),
        :formatter => DefaultT(()->DatetimeTickFormatter()),
    ]
)

const MercatorAxis = ModelType("MercatorAxis";
    # TODO: the python constructor has a "dimension" argument which sets the dimension on
    # the ticker and formatter
    bases = [LinearAxis],
    props = [
        :ticker => DefaultT(()->MercatorTicker()),
        :formatter => DefaultT(()->MercatorTickFormatter()),
    ]
)
