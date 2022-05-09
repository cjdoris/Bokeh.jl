const LayoutDOM = ModelType("LayoutDOM";
    abstract = true,
    props = [
        :disabled => BoolT(default=false),
        :visible => BoolT(default=true),
        :width => NullableT(NonNegativeIntT()),
        :height => NullableT(NonNegativeIntT()),
        :min_width => NullableT(NonNegativeIntT()),
        :min_height => NullableT(NonNegativeIntT()),
        :max_width => NullableT(NonNegativeIntT()),
        :max_height => NullableT(NonNegativeIntT()),
        :margin => NullableT(MarginT(), default=(0,0,0,0)),
        :width_policy => EitherT(AutoT(), SizingPolicyT(), default="auto"),
        :height_policy => EitherT(AutoT(), SizingPolicyT(), default="auto"),
        :aspect_ratio => EitherT(AutoT(), NullT(), FloatT()),
        :sizing_mode => NullableT(SizingModeT()),
        :align => EitherT(AlignT(), TupleT(AlignT(), AlignT()), default="start"),
        :background => NullableT(ColorT()),
        :css_classes => ListT(StringT()),
    ]
)

const HTMLBox = ModelType("HTMLBox";
    abstract = true,
    inherits = [LayoutDOM],
)

const Spacer = ModelType("Spacer";
    inherits = [LayoutDOM]
)

const GridBox = ModelType("GridBox";
    inherits = [LayoutDOM],
)

const Box = ModelType("Box";
    abstract = true,
    inherits = [LayoutDOM],
    props = [
        :children => ListT(InstanceT(LayoutDOM)),
        :spacing => IntT(default=0),
    ]
)

const Row = ModelType("Row";
    inherits = [Box],
    props = [
        :cols => EitherT(QuickTrackSizingT(), DictT(IntOrStringT(), ColSizingT()), default="auto"),
    ]
)

const Column = ModelType("Column";
    inherits = [Box],
    props = [
        :cols => EitherT(QuickTrackSizingT(), DictT(IntOrStringT(), RowSizingT()), default="auto"),
    ]
)
