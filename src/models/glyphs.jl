const Glyph = ModelType("Glyph";
    abstract = true,
)

const XYGlyph = ModelType("XYGlyph";
    abstract = true,
    bases = [Glyph],
)

const ConnectedXYGlyph = ModelType("ConnectedXYGlyph";
    abstract = true,
    bases = [XYGlyph],
)

const LineGlyph = ModelType("LineGlyph";
    abstract = true,
    bases = [Glyph],
)

const FillGlyph = ModelType("FillGlyph";
    abstract = true,
    bases = [Glyph],
)

const TextGlyph = ModelType("TextGlyph";
    abstract = true,
    bases = [Glyph],
)

const HatchGlyph = ModelType("HatchGlyph";
    abstract = true,
    bases = [Glyph],
)

const Marker = ModelType("Marker";
    abstract = true,
    bases = [XYGlyph, LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :hit_dilation => FloatT(default=1.0),
        :size => SizeSpecT(default=4.0),
        :angle => AngleSpecT(default=0.0),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ],
)

const AnnularWedge = ModelType("AnnularWedge";
    bases = [XYGlyph, LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :inner_radius => DistanceSpecT(default="inner_radius"),
        :outer_radius => DistanceSpecT(default="outer_radius"),
        :start_angle => AngleSpecT(default="start_angle"),
        :end_angle => AngleSpecT(default="end_angle"),
        :direction => DirectionT(default="anticlock"),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const Annulus = ModelType("Annulus";
    bases = [XYGlyph, LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :inner_radius => DistanceSpecT(default="inner_radius"),
        :outer_radius => DistanceSpecT(default="outer_radius"),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const Arc = ModelType("Arc";
    bases = [XYGlyph, LineGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :radius => DistanceSpecT(default="inner_radius"),
        :start_angle => AngleSpecT(default="start_angle"),
        :end_angle => AngleSpecT(default="end_angle"),
        :direction => DirectionT(default="anticlock"),
        LINE_PROPS,
    ]
)

const Bezier = ModelType("Bezier";
    bases = [LineGlyph],
    props = [
        :x0 => NumberSpecT(default="x0"),
        :y0 => NumberSpecT(default="y0"),
        :x1 => NumberSpecT(default="x1"),
        :y1 => NumberSpecT(default="y1"),
        :cx0 => NumberSpecT(default="cx0"),
        :cy0 => NumberSpecT(default="cy0"),
        :cx1 => NumberSpecT(default="cx1"),
        :cy1 => NumberSpecT(default="cy1"),
        LINE_PROPS,
    ]
)

const Circle = ModelType("Circle";
    bases = [Marker],
    props = [
        :radius => NullDistanceSpecT(),
        :radius_dimension => EnumT(Set(["x", "y", "max", "min"])),
    ]
)

const Ellipse = ModelType("Ellipse";
    bases = [XYGlyph, LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :width => DistanceSpecT(default="width"),
        :height => DistanceSpecT(default="height"),
        :angle => AngleSpecT(default="angle"),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const HArea = ModelType("HArea";
    bases = [FillGlyph, HatchGlyph],
    props = [
        :x1 => NumberSpecT(default="x1"),
        :x2 => NumberSpecT(default="x2"),
        :y => NumberSpecT(default="y"),
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const HBar = ModelType("HBar";
    bases = [LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :y => NumberSpecT(default="y"),
        :height => NumberSpecT(default="height"),
        :left => NumberSpecT(default="left"),
        :right => NumberSpecT(default="right"),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const HexTile = ModelType("HexTile";
    bases = [LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :size => FloatT(default=1.0),
        :r => NumberSpecT(default="r"),
        :q => NumberSpecT(default="q"),
        :scale => NumberSpecT(default="scale"),
        :orientation => StringT(default="pointytop"),
        LINE_PROPS,
        :line_color => DefaultT(nothing),
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const Image = ModelType("Image";
    bases = [XYGlyph],
    props = [
        :image => NumberSpecT(default="image"),
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :dw => DistanceSpecT(default="dw"),
        :dh => DistanceSpecT(default="dh"),
        :global_alpha => NumberSpecT(default=1.0),
        :dilate => BoolT(default=false),
        :color_mapper => InstanceT(ColorMapper, default=()->LinearColorMapper(palette="Greys9")),
    ]
)

const ImageRGBA = ModelType("ImageRGBA";
    bases = [XYGlyph],
    props = [
        :image => NumberSpecT(default="image"),
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :dw => DistanceSpecT(default="dw"),
        :dh => DistanceSpecT(default="dh"),
        :global_alpha => NumberSpecT(default=1.0),
        :dilate => BoolT(default=false),
    ]
)

const ImageURL = ModelType("ImageURL";
    bases = [XYGlyph],
    props = [
        :url => StringSpecT(default=Field("url")),
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :w => NullDistanceSpecT(default="w"),
        :h => NullDistanceSpecT(default="h"),
        :angle => AngleSpecT(default="angle"),
        :global_alpha => NumberSpecT(default=1.0),
        :dilate => BoolT(default=false),
        :anchor => AnchorT(),
        :retry_attempts => IntT(default=0),
        :retry_timeout => IntT(default=0),
    ]
)

const Line = ModelType("Line";
    bases = [ConnectedXYGlyph, LineGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        SCALAR_LINE_PROPS,
    ],
)

const MultiLine = ModelType("MultiLine";
    bases = [LineGlyph],
    props = [
        :xs => NumberSpecT(default="xs"),
        :ys => NumberSpecT(default="ys"),
        LINE_PROPS,
    ]
)

const MultiPolygons = ModelType("MultiPolygons";
    bases = [LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :xs => NumberSpecT(default="xs"),
        :ys => NumberSpecT(default="ys"),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const Oval = ModelType("Oval";
    bases = [XYGlyph, LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :width => DistanceSpecT(default="width"),
        :height => DistanceSpecT(default="height"),
        :angle => AngleSpecT(default="angle"),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const Patch = ModelType("Patch";
    bases = [ConnectedXYGlyph, LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        SCALAR_LINE_PROPS,
        SCALAR_FILL_PROPS,
        SCALAR_HATCH_PROPS,
    ]
)

const Patches = ModelType("Patches";
    bases = [XYGlyph, LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :xs => NumberSpecT(default="xs"),
        :ys => NumberSpecT(default="ys"),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const Quad = ModelType("Quad";
    bases = [LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :left => NumberSpecT(default="left"),
        :right => NumberSpecT(default="right"),
        :bottom => NumberSpecT(default="bottom"),
        :top => NumberSpecT(default="top"),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const Quadratic = ModelType("Quadratic";
    bases = [LineGlyph],
    props = [
        :x0 => NumberSpecT(default="x0"),
        :y0 => NumberSpecT(default="y0"),
        :x1 => NumberSpecT(default="x1"),
        :y1 => NumberSpecT(default="y1"),
        :cx => NumberSpecT(default="cx"),
        :cy => NumberSpecT(default="cy"),
        LINE_PROPS,
    ]
)

const Ray = ModelType("Ray";
    bases = [XYGlyph, LineGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :angle => AngleSpecT(default=0.0),
        :length => DistanceSpecT(default=0.0),
        LINE_PROPS,
    ]
)

const Rect = ModelType("Rect";
    bases = [XYGlyph, LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :width => DistanceSpecT(default="width"),
        :height => DistanceSpecT(default="height"),
        :angle => AngleSpecT(default=0.0),
        :dilate => BoolT(default=false),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const Scatter = ModelType("Scatter";
    bases = [Marker],
    props = [
        :marker => MarkerSpecT(default="circle"),
    ],
)

const Segment = ModelType("Segment";
    bases = [LineGlyph],
    props = [
        :x0 => NumberSpecT(default="x0"),
        :y0 => NumberSpecT(default="y0"),
        :x1 => NumberSpecT(default="x1"),
        :y1 => NumberSpecT(default="y1"),
        LINE_PROPS,
    ]
)

const Step = ModelType("Step";
    bases = [XYGlyph, LineGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        LINE_PROPS,
        :mode => StepModeT(default="before"),
    ]
)

const Text = ModelType("Text";
    bases = [XYGlyph, TextGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :text => StringSpecT(default=Field("text")),
        :angle => AngleSpecT(default=0.0),
        :x_offset => NumberSpecT(default=0.0),
        :y_offset => NumberSpecT(default=0.0),
        TEXT_PROPS,
    ]
)

const VArea = ModelType("VArea";
    bases = [FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y1 => NumberSpecT(default="y1"),
        :y2 => NumberSpecT(default="y2"),
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const VBar = ModelType("VBar";
    bases = [LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :width => NumberSpecT(default=1.0),
        :bottom => NumberSpecT(default=0.0),
        :top => NumberSpecT(default="top"),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)

const Wedge = ModelType("Wedge";
    bases = [XYGlyph, LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default="x"),
        :y => NumberSpecT(default="y"),
        :radius => DistanceSpecT(default="radius"),
        :start_angle => AngleSpecT(default="start_angle"),
        :end_angle => AngleSpecT(default="start_angle"),
        :direction => DirectionT(default="anticlock"),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)
