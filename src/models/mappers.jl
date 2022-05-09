const Mapper = ModelType("Mapper";
    abstract = true,
    inherits = [Transform],
)

const ColorMapper = ModelType("ColorMapper";
    abstract = true,
    inherits = [Mapper],
    props = [
        :palette => PaletteT(),
        :nan_color => ColorT() |> DefaultT("gray"),
    ],
)

const CategoricalMapper = ModelType("CategoricalMapper";
    abstract = true,
    inherits = [Mapper],
    props = [
        :factors => FactorSeqT(),
        :start => IntT() |> DefaultT(0),
        :end => IntT() |> NullableT,
    ],
)

const CategoricalColorMapper = ModelType("CategoricalColorMapper";
    inherits = [ColorMapper, CategoricalMapper],
)

const CategoricalMarkerMapper = ModelType("CategoricalMarkerMapper";
    inherits = [CategoricalMapper],
    props = [
        :markers => ListT(MarkerT()),
        :default_value => MarkerT() |> DefaultT("circle"),
    ]
)

const CategoricalPatternMapper = ModelType("CategoricalPatternMapper";
    inherits = [CategoricalMapper],
)

const ContinuousColorMapper = ModelType("ContinuousColorMapper";
    abstract = true,
    inherits = [ColorMapper],
)

const LinearColorMapper = ModelType("LinearColorMapper";
    inherits = [ContinuousColorMapper],
)

const LogColorMapper = ModelType("LogColorMapper";
    inherits = [ContinuousColorMapper],
)
