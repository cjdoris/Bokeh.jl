const RendererGroup = ModelType("RendererGroup";
    props = [
        :visible => BoolT(default=true),
    ]
)

const Renderer = ModelType("Renderer";
    abstract = true,
    props = [
        :level => RenderLevelT(),
        :visible => BoolT() |> DefaultT(true),
        # :coordinates => NullableT(InstanceT(CoordinateMapping)), TODO
        :x_range_name => StringT(default="default"),
        :y_range_name => StringT(default="default"),
        :group => NullableT(InstanceT(RendererGroup)),
    ],
)

const TileRenderer = ModelType("TileRenderer";
    bases = [Renderer],
    props = [
        # TODO
    ]
)

const DataRenderer = ModelType("DataRenderer";
    abstract = true,
    bases = [Renderer],
    props = [
        :level => DefaultT("glyph"),
    ],
)

const GlyphRenderer = ModelType("GlyphRenderer";
    bases = [DataRenderer],
    props = [
        :data_source => InstanceT(DataSource),
        :view => InstanceT(CDSView),
        :glyph => InstanceT(Glyph),
        :selection_glyph => NullableT(EitherT(AutoT(), InstanceT(Glyph)), default="auto"),
        :nonselection_glyph => NullableT(EitherT(AutoT(), InstanceT(Glyph)), default="auto"),
        :hover_glyph => NullableT(InstanceT(Glyph)),
        :muted_glyph => NullableT(EitherT(AutoT(), InstanceT(Glyph)), default="auto"),
        :muted => BoolT(default=false),
    ],
)

const GraphRenderer = ModelType("GraphRenderer";
    bases = [DataRenderer],
    props = [
        # TODO
    ]
)

const GuideRenderer = ModelType("GuideRenderer";
    abstract = true,
    bases = [Renderer],
    props = [
        :level => DefaultT("guide"),
    ]
)
