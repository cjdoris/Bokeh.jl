const BaseText = ModelType("BaseText";
    abstract = true,
    props = [
        :text => StringT(),
    ]
)

const MathText = ModelType("MathText";
    abstract = true,
    inherits = [BaseText],
)

const Ascii = ModelType("Ascii";
    inherits = [MathText],
)

const MathML = ModelType("MathML";
    inherits = [MathText],
)

const TeX = ModelType("TeX";
    inherits = [MathText],
    props = [
        :macros => DictT(StringT(), EitherT(StringT(), TupleT(StringT(), IntT()))),
        :inline => BoolT(default=false),
    ]
)

const PlainText = ModelType("PlainText";
    inherits = [BaseText],
)
