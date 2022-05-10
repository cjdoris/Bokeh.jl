const LabelingPolicy = ModelType("LabelingPolicy";
    abstract = true,
)

const AllLabels = ModelType("LabelingPolicy";
    bases = [LabelingPolicy],
)

const NoOverlap = ModelType("NoOverlap";
    bases = [LabelingPolicy],
    props = [
        :min_distance => IntT(default=5),
    ]
)

const CustomLabelingPolicy = ModelType("CustomLabelingPolicy";
    bases = [LabelingPolicy],
)
