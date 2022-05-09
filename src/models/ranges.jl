const Range = ModelType("Range";
    abstract = true,
)

const Range1d = ModelType("Range1d";
    inherits = [Range],
    props = [
        :start => FloatT() |> DefaultT(0.0),
        :end => FloatT() |> DefaultT(1.0),
        :reset_start => EitherT(NullT(), FloatT()) |> DefaultT(nothing),
        :reset_end => EitherT(NullT(), FloatT()) |> DefaultT(nothing),
    ],
)

const DataRange = ModelType("DataRange";
    abstract = true,
    inherits = [Range],
)

const DataRange1d = ModelType("DataRange1d";
    inherits = [Range1d, DataRange],
    props = [
        :range_padding => FloatT(default=0.1),
        :start => EitherT(NullT(), FloatT()),
        :end => EitherT(NullT(), FloatT()),
    ]
)

const FactorRange = ModelType("FactorRange";
    inherits = [Range],
    props = [
        :factors => FactorSeqT(),
    ],
)
