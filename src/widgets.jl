### WIDGET

const Widget = ModelType("Widget";
    inherits = [LayoutDOM]
)


### MARKUP

const Markup = ModelType("Markup";
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
export Paragraph

const Div = ModelType("Div";
    inherits = [Markup],
    props = [
        :render_as_text => BoolT(default=false),
    ]
)
export Div

const PreText = ModelType("PreText";
    inherits = [Markup]
)
export PreText
