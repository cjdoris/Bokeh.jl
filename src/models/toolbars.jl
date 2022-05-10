const ToolbarBase = ModelType("ToolbarBase";
    abstract = true,
    props = [
        :logo => NullableT(EnumT(Set(["normal", "grey"])), default="normal"),
        :autohide => BoolT(default=false),
        :tools => ListT(InstanceT(Tool)),
    ]
)

const Toolbar = ModelType("Toolbar";
    bases = [ToolbarBase],
    props = [
        :active_drag => EitherT(NullT(), AutoT(), InstanceT(Drag), default="auto"),
        :active_inspect => EitherT(NullT(), AutoT(), InstanceT(InspectTool), SeqT(InstanceT(InspectTool)), default="auto"),
        :active_scroll => EitherT(NullT(), AutoT(), InstanceT(Scroll), default="auto"),
        :active_tap => EitherT(NullT(), AutoT(), InstanceT(Tap), default="auto"),
        :active_multi => EitherT(NullT(), AutoT(), InstanceT(GestureTool), default="auto"),
    ]
)

const ProxyToolbar = ModelType("ProxyToolbar";
    bases = [ToolbarBase],
    props = [
        :toolbars => ListT(InstanceT(Toolbar)),
    ]
)

const ToolbarBox = ModelType("ToolbarBox";
    bases = [LayoutDOM],
    props = [
        :toolbar_location => LocationT(default="right"),
    ],
)
