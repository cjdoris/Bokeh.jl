const Tool = ModelType("Tool";
    abstract = true,
)

const ActionTool = ModelType("ActionTool";
    abstract = true,
    inherits = [Tool],
)

const GestureTool = ModelType("GestureTool";
    abstract = true,
    inherits = [Tool],
)

const Drag = ModelType("Drag";
    abstract = true,
    inherits = [GestureTool],
)

const Scroll = ModelType("Scroll";
    abstract = true,
    inherits = [GestureTool],
)

const Tap = ModelType("Tap";
    abstract = true,
    inherits = [GestureTool],
)

const SelectTool = ModelType("SelectTool";
    abstract = true,
    inherits = [GestureTool],
)

const InspectTool = ModelType("InspectTool";
    abstract = true,
    inherits = [GestureTool],
)

const PanTool = ModelType("PanTool";
    inherits = [Drag],
)

const RangeTool = ModelType("RangeTool";
    inherits = [Drag],
)

const WheelPanTool = ModelType("WheelPanTool";
    inherits = [Scroll],
)

const WheelZoomTool = ModelType("WheelZoomTool";
    inherits = [Scroll],
)

const CustomAction = ModelType("CustomAction";
    inherits = [ActionTool],
)

const SaveTool = ModelType("SaveTool";
    inherits = [ActionTool],
)

const ResetTool = ModelType("ResetTool";
    inherits = [ActionTool],
)

const TapTool = ModelType("TapTool";
    inherits = [Tap, SelectTool],
)

const CrosshairTool = ModelType("CrosshairTool";
    inherits = [InspectTool],
)

const BoxZoomTool = ModelType("BoxZoomTool";
    inherits = [Drag],
)

const ZoomInTool = ModelType("ZoomInTool";
    inherits = [ActionTool],
)

const ZoomOutTool = ModelType("ZoomOutTool";
    inherits = [ActionTool],
)

const BoxSelectTool = ModelType("BoxSelectTool";
    inherits = [Drag, SelectTool],
)

const LassoSelectTool = ModelType("LassoSelectTool";
    inherits = [Drag, SelectTool],
)

const PolySelectTool = ModelType("PolySelectTool";
    inherits = [Tap, SelectTool],
)

const CustomJSHover = ModelType("CustomJSHover")

const HoverTool = ModelType("HoverTool";
    inherits = [InspectTool],
    props = [
        :names => ListT(StringT()),
        :renderers => EitherT(AutoT(), ListT(InstanceT(DataRenderer)), default="auto"),
        # :callback => NullableT(CallbackT()), TODO
        :tooltips => EitherT(
            NullT(),
            # InstanceT(TemplateT()), TODO
            StringT(),
            ListT(TupleT(StringT(), StringT())),
            default = [
                ("index", "\$index"),
                ("data (x, y)", "(\$x, \$y)"),
                ("screen (x, y)", "(\$sx, \$sy)"),
            ],
            result_type = Any,
        )
    ]
)

const HelpTool = ModelType("HelpTool";
    inherits = [ActionTool]
)

const UndoTool = ModelType("UndoTool";
    inherits = [ActionTool]
)

const RedoTool = ModelType("RedoTool";
    inherits = [ActionTool]
)

const EditTool = ModelType("EditTool";
    abstract = true,
    inherits = [GestureTool]
)

const PolyTool = ModelType("PolyTool";
    abstract = true,
    inherits = [EditTool]
)

const BoxEditTool = ModelType("BoxEditTool";
    inherits = [EditTool, Drag, Tap]
)

const PointDrawTool = ModelType("PointDrawTool";
    inherits = [EditTool, Drag, Tap]
)

const PolyDrawTool = ModelType("PolyDrawTool";
    inherits = [PolyTool, Drag, Tap],
)

const FreehandDrawTool = ModelType("FreehandDrawTool";
    inherits = [EditTool, Drag, Tap],
)

const PolyEditTool = ModelType("PolyEditTool";
    inherits = [PolyTool, Drag, Tap],
)

const LineEditTool = ModelType("LineEditTool";
    inherits = [EditTool, Drag, Tap],
)
