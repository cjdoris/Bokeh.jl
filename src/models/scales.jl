const Scale = ModelType("Scale";
    abstract = true,
    inherits = [Transform],
)

const ContinuousScale = ModelType("ContinuousScale";
    inherits = [Scale],
)

const LinearScale = ModelType("LinearScale";
    inherits = [ContinuousScale],
)

const LogScale = ModelType("LogScale";
    inherits = [ContinuousScale],
)

const CategoricalScale = ModelType("CategoricalScale";
    inherits = [Scale],
)
