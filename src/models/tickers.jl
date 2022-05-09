const Ticker = ModelType("Ticker";
    abstract = true,
)

const ContinuousTicker = ModelType("ContinuousTicker";
    abstract = true,
    inherits = [Ticker],
    props = [
        :num_minor_ticks => IntT(default=5),
        :desired_num_ticks => IntT(default=6),
    ]
)

const FixedTicker = ModelType("FixedTicker";
    inherits = [ContinuousTicker],
    props = [
        :ticks => SeqT(FloatT()),
        :minor_ticks => SeqT(FloatT()),
    ]
)

const AdaptiveTicker = ModelType("AdaptiveTicker";
    inherits = [ContinuousTicker],
    props = [
        :base => FloatT(default=10.0),
        :mantissas => SeqT(FloatT(), default=()->[1.0, 2.0, 5.0]),
        :min_interval => FloatT(default=0.0),
        :max_interval => NullableT(FloatT()),
    ]
)

const CompositeTicker = ModelType("CompositeTicker";
    inherits = [ContinuousTicker],
    props = [
        :tickers => SeqT(InstanceT(Ticker)),
    ]
)

const SingleIntervalTicker = ModelType("SingleIntervalTicker";
    inherits = [ContinuousTicker],
    props = [
        :interval => FloatT(),
    ]
)

const DaysTicker = ModelType("DaysTicker";
    inherits = [SingleIntervalTicker],
    props = [
        :days => SeqT(IntT()),
        :num_minor_ticks => DefaultT(0),
    ]
)

const MonthsTicker = ModelType("MonthsTicker";
    inherits = [SingleIntervalTicker],
    props = [
        :months => SeqT(IntT()),
    ]
)

const YearsTicker = ModelType("YearsTicker";
    inherits = [SingleIntervalTicker],
)

const BasicTicker = ModelType("BasicTicker";
    inherits = [AdaptiveTicker],
)

const LogTicker = ModelType("LogTicker";
    inherits = [AdaptiveTicker],
    props = [
        :mantissas => DefaultT(()->[1.0, 5.0]),
    ]
)

const MercatorTicker = ModelType("MercatorTicker";
    inherits = [BasicTicker],
    props = [
        :dimension => NullableT(LatLonT()),
    ]
)

const DatetimeTicker = ModelType("DatetimeTicker";
    inherits = [CompositeTicker],
    props = [
        :num_minor_ticks => DefaultT(0),
        :tickers => DefaultT(() -> [
            AdaptiveTicker(
                mantissas = [1, 2, 5],
                base = 10,
                min_interval = 0,
                max_interval = 500,
                num_minor_ticks = 0,
            ),
            AdaptiveTicker(
                mantissas = [1, 2, 5, 10, 15, 20, 30],
                base = 60,
                min_interval = 1000,
                max_interval = 30*60*1000,
                num_minor_ticks = 0,
            ),
            AdaptiveTicker(
                mantissas = [1, 2, 4, 6, 8, 12],
                base = 60,
                min_interval = 60*60*1000,
                max_interval = 12*60*60*1000,
                num_minor_ticks = 0,
            ),
            DaysTicker(days=collect(1:32)),
            DaysTicker(days=collect(1:3:30)),
            DaysTicker(days=[1,8,15,22]),
            DaysTicker(days=[1,15]),
            MonthsTicker(months=collect(0:1:11)),
            MonthsTicker(months=collect(0:2:11)),
            MonthsTicker(months=collect(0:3:11)),
            MonthsTicker(months=collect(0:6:11)),
            YearsTicker(),
        ])
    ]
)

const BinnedTicker = ModelType("BinnedTicker";
    inherits = [Ticker],
    props = [
        # :mapper => InstanceT(ScanningColorMapper), TODO
        :num_major_ticks => EitherT(IntT(), AutoT(), default=8),
    ]
)
