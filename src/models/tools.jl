const Tool = ModelType("Tool";
    abstract = true,
)

const ActionTool = ModelType("ActionTool";
    abstract = true,
    bases = [Tool],
)

const GestureTool = ModelType("GestureTool";
    abstract = true,
    bases = [Tool],
)

const Drag = ModelType("Drag";
    abstract = true,
    bases = [GestureTool],
)

const Scroll = ModelType("Scroll";
    abstract = true,
    bases = [GestureTool],
)

const Tap = ModelType("Tap";
    abstract = true,
    bases = [GestureTool],
)

const SelectTool = ModelType("SelectTool";
    abstract = true,
    bases = [GestureTool],
)

const InspectTool = ModelType("InspectTool";
    abstract = true,
    bases = [GestureTool],
)

const PanTool = ModelType("PanTool";
    bases = [Drag],
)

const RangeTool = ModelType("RangeTool";
    bases = [Drag],
)

const WheelPanTool = ModelType("WheelPanTool";
    bases = [Scroll],
)

const WheelZoomTool = ModelType("WheelZoomTool";
    bases = [Scroll],
)

const CustomAction = ModelType("CustomAction";
    bases = [ActionTool],
)

const SaveTool = ModelType("SaveTool";
    bases = [ActionTool],
)

const ResetTool = ModelType("ResetTool";
    bases = [ActionTool],
)

const TapTool = ModelType("TapTool";
    bases = [Tap, SelectTool],
)

const CrosshairTool = ModelType("CrosshairTool";
    bases = [InspectTool],
)

const BoxZoomTool = ModelType("BoxZoomTool";
    bases = [Drag],
)

const ZoomInTool = ModelType("ZoomInTool";
    bases = [ActionTool],
)

const ZoomOutTool = ModelType("ZoomOutTool";
    bases = [ActionTool],
)

const BoxSelectTool = ModelType("BoxSelectTool";
    bases = [Drag, SelectTool],
)

const LassoSelectTool = ModelType("LassoSelectTool";
    bases = [Drag, SelectTool],
)

const PolySelectTool = ModelType("PolySelectTool";
    bases = [Tap, SelectTool],
)

const CustomJSHover = ModelType("CustomJSHover")

const HoverTool = ModelType("HoverTool";
    bases = [InspectTool],
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
    bases = [ActionTool]
)

const UndoTool = ModelType("UndoTool";
    bases = [ActionTool]
)

const RedoTool = ModelType("RedoTool";
    bases = [ActionTool]
)

const EditTool = ModelType("EditTool";
    abstract = true,
    bases = [GestureTool]
)

const PolyTool = ModelType("PolyTool";
    abstract = true,
    bases = [EditTool]
)

const BoxEditTool = ModelType("BoxEditTool";
    bases = [EditTool, Drag, Tap]
)

const PointDrawTool = ModelType("PointDrawTool";
    bases = [EditTool, Drag, Tap]
)

const PolyDrawTool = ModelType("PolyDrawTool";
    bases = [PolyTool, Drag, Tap],
)

const FreehandDrawTool = ModelType("FreehandDrawTool";
    bases = [EditTool, Drag, Tap],
)

const PolyEditTool = ModelType("PolyEditTool";
    bases = [PolyTool, Drag, Tap],
)

const LineEditTool = ModelType("LineEditTool";
    bases = [EditTool, Drag, Tap],
)
