const Mapper = ModelType("Mapper";
    abstract = true,
    bases = [Transform],
)

const ColorMapper = ModelType("ColorMapper";
    abstract = true,
    bases = [Mapper],
    props = [
        :palette => PaletteT(),
        :nan_color => ColorT() |> DefaultT("gray"),
    ],
)

const CategoricalMapper = ModelType("CategoricalMapper";
    abstract = true,
    bases = [Mapper],
    props = [
        :factors => FactorSeqT(),
        :start => IntT() |> DefaultT(0),
        :end => IntT() |> NullableT,
    ],
)

const CategoricalColorMapper = ModelType("CategoricalColorMapper";
    bases = [ColorMapper, CategoricalMapper],
)

const CategoricalMarkerMapper = ModelType("CategoricalMarkerMapper";
    bases = [CategoricalMapper],
    props = [
        :markers => ListT(MarkerT()),
        :default_value => MarkerT() |> DefaultT("circle"),
    ]
)

const CategoricalPatternMapper = ModelType("CategoricalPatternMapper";
    bases = [CategoricalMapper],
)

const ContinuousColorMapper = ModelType("ContinuousColorMapper";
    abstract = true,
    bases = [ColorMapper],
)

const LinearColorMapper = ModelType("LinearColorMapper";
    bases = [ContinuousColorMapper],
)

const LogColorMapper = ModelType("LogColorMapper";
    bases = [ContinuousColorMapper],
)
