const LabelingPolicy = ModelType("LabelingPolicy";
    abstract = true,
)

const AllLabels = ModelType("LabelingPolicy";
    inherits = [LabelingPolicy],
)

const NoOverlap = ModelType("NoOverlap";
    inherits = [LabelingPolicy],
    props = [
        :min_distance => IntT(default=5),
    ]
)

const CustomLabelingPolicy = ModelType("CustomLabelingPolicy";
    inherits = [LabelingPolicy],
)
