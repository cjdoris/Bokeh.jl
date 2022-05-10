const BaseText = ModelType("BaseText";
    abstract = true,
    props = [
        :text => StringT(),
    ]
)

const MathText = ModelType("MathText";
    abstract = true,
    bases = [BaseText],
)

const Ascii = ModelType("Ascii";
    bases = [MathText],
)

const MathML = ModelType("MathML";
    bases = [MathText],
)

const TeX = ModelType("TeX";
    bases = [MathText],
    props = [
        :macros => DictT(StringT(), EitherT(StringT(), TupleT(StringT(), IntT()))),
        :inline => BoolT(default=false),
    ]
)

const PlainText = ModelType("PlainText";
    bases = [BaseText],
)
