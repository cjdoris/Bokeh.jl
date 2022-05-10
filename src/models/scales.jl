const Scale = ModelType("Scale";
    abstract = true,
    bases = [Transform],
)

const ContinuousScale = ModelType("ContinuousScale";
    bases = [Scale],
)

const LinearScale = ModelType("LinearScale";
    bases = [ContinuousScale],
)

const LogScale = ModelType("LogScale";
    bases = [ContinuousScale],
)

const CategoricalScale = ModelType("CategoricalScale";
    bases = [Scale],
)
