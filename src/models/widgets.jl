### WIDGET

const Widget = ModelType("Widget";
    abstract = true,
    inherits = [LayoutDOM]
)


### MARKUP

const Markup = ModelType("Markup";
    abstract = true,
    inherits = [Widget],
    props = [
        :text => StringT(default=""),
        :style => DictT(StringT(), AnyT()),
        :disable_math => BoolT(default=false),
    ]
)

const Paragraph = ModelType("Paragraph";
    inherits = [Markup]
)

const Div = ModelType("Div";
    inherits = [Markup],
    props = [
        :render_as_text => BoolT(default=false),
    ]
)

const PreText = ModelType("PreText";
    inherits = [Markup]
)
