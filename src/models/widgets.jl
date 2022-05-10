### WIDGET

const Widget = ModelType("Widget";
    abstract = true,
    bases = [LayoutDOM]
)


### MARKUP

const Markup = ModelType("Markup";
    abstract = true,
    bases = [Widget],
    props = [
        :text => StringT(default=""),
        :style => DictT(StringT(), AnyT()),
        :disable_math => BoolT(default=false),
    ]
)

const Paragraph = ModelType("Paragraph";
    bases = [Markup]
)

const Div = ModelType("Div";
    bases = [Markup],
    props = [
        :render_as_text => BoolT(default=false),
    ]
)

const PreText = ModelType("PreText";
    bases = [Markup]
)
