### MODELTYPE

function ModelType(name, subname=nothing;
    inherits=[BaseModel],
    props=[],
)
    propdescs = Dict{Symbol,PropDesc}()
    supers = IdSet{ModelType}()
    for t in inherits
        mergepropdescs!(propdescs, t.propdescs)
        push!(supers, t)
        union!(supers, t.supers)
    end
    mergepropdescs!(propdescs, props)
    return ModelType(name, subname, inherits, propdescs, supers)
end

function mergepropdescs!(ds, x; name=nothing)
    if x isa PropDesc
        ds[name] = x
    elseif x isa PropType
        ds[name] = PropDesc(x)
    elseif x isa Pair
        name = name===nothing ? x.first : Symbol(name, "_", x.first)
        mergepropdescs!(ds, x.second; name)
    elseif x isa Function
        d = ds[name]
        if d.kind == TYPE_K
            mergepropdescs!(ds, x(d.type); name)
        else
            mergepropdescs!(ds, x(d); name)
        end
    else
        for d in x
            mergepropdescs!(ds, d; name)
        end
    end
end

function (t::ModelType)(; kw...)
    @nospecialize
    Model(t, collect(Kwarg, kw))
end

issubmodeltype(t1::ModelType, t2::ModelType) = t1 === t2 || t2 in t1.supers

function Base.show(io::IO, t::ModelType)
    show(io, typeof(t))
    print(io, "(")
    show(io, t.name)
    print(io, "; ...)")
end


### MODEL

modelid(m::Model) = getfield(m, :id)

modeltype(m::Model) = getfield(m, :type)

modelvalues(m::Model) = getfield(m, :values)

ismodelinstance(m::Model, t::ModelType) = issubmodeltype(modeltype(m), t)

function Base.getproperty(m::Model, k::Symbol)
    # look up the value
    vs = modelvalues(m)
    v = get(vs, k, Undefined())
    v === Undefined() || return v
    # look up the descriptor
    mt = modeltype(m)
    ds = mt.propdescs
    pd = get(ds, k, nothing)
    pd === nothing && error("$(mt.name): .$k: invalid property")
    # branch on the kind of the descriptor
    kd = pd.kind
    if kd == TYPE_K
        # get the default value
        t = pd.type::PropType
        d = t.default
        if d isa Function
            v = vs[k] = d()
        else
            v = d
        end
        return v
    elseif kd == GETSET_K
        f = pd.getter
        f === nothing && error("$(mt.name): .$k: property is not readable")
        return f(m)
    else
        @assert false
    end
end

function Base.setproperty!(m::Model, k::Symbol, x)
    # look up the descriptor
    mt = modeltype(m)
    ds = mt.propdescs
    pd = get(ds, k, nothing)
    pd === nothing && error("$(mt.name): .$k: invalid property")
    # branch on the kind of the descriptor
    kd = pd.kind
    if kd == TYPE_K
        if x === Undefined()
            # delete the value
            vs = modelvalues(m)
            delete!(vs, k)
        else
            # validate the value
            t = pd.type::PropType
            v = validate(t, x)
            v isa Invalid && error("$(mt.name): .$k: $(v.msg)")
            # set it
            vs = modelvalues(m)
            vs[k] = v
        end
    elseif kd == GETSET_K
        f = pd.setter
        f === nothing && error("$(mt.name): .$k: property is not writeable")
        f(m, x)
    else
        @assert false
    end
    return m
end

function Base.hasproperty(m::Model, k::Symbol)
    ts = modeltype(m).propdescs
    return haskey(ts, k)
end

function Base.propertynames(m::Model)
    ts = modeltype(m).propdescs
    return collect(keys(ts))
end

function Base.show(io::IO, m::Model)
    mt = modeltype(m)
    vs = modelvalues(m)
    print(io, mt.name, "(", join(["$k=$(repr(v))" for (k,v) in vs if v !== Undefined()], ", "), ")")
    return
end

Base.show(io::IO, ::MIME"text/plain", m::Model) = _show_indented(io, m)

function _show_indented(io::IO, m::Model, indent=0, seen=IdSet())
    if m in seen
        print(io, "...")
        return
    end
    push!(seen, m)
    mt = modeltype(m)
    vs = sort([x for x in modelvalues(m) if x[2] !== Undefined()], by=x->string(x[1]))
    print(io, mt.name, ":")
    istr = "  " ^ (indent + 1)
    if isempty(vs)
        print(io, " (blank)")
    else
        for (k, v) in vs
            println(io)
            print(io, istr, k, " = ")
            _show_indented(io, v, indent+1, seen)
        end
    end
    return
end

function _show_indented(io::IO, xs::AbstractVector, indent=0, seen=IdSet())
    if xs in seen
        print(io, "...")
        return
    end
    push!(seen, xs)
    if isempty(xs)
        print(io, "[]")
    else
        print(io, "[")
        istr = "  "^indent
        for (n, x) in enumerate(xs)
            println(io)
            print(io, istr, "  ")
            if n > 5
                print(io, "...")
                break
            else
                _show_indented(io, x, indent+1, seen)
            end
        end
        println(io)
        print(io, istr, "]")
    end
end

function _show_indented(io::IO, xs::AbstractDict, indent=0, seen=IdSet())
    if xs in seen
        print(io, "...")
        return
    end
    push!(seen, xs)
    if isempty(xs)
        print(io, "Dict()")
    else
        print(io, "Dict(")
        istr = "  "^indent
        for (n, (k, v)) in enumerate(xs)
            println(io)
            print(io, istr, "  ")
            if n > 5
                print(io, "...")
                break
            else
                show(io, k)
                print(io, " => ")
                _show_indented(io, v, indent+1, seen)
            end
        end
        println(io)
        print(io, istr, ")")
    end
end

function _show_indented(io::IO, x, indent=0, seen=IdSet())
    show(io, x)
end

function serialize(s::Serializer, m::Model)
    serialize_noref(s, m)
    id = modelid(m)
    return Dict("id" => id)
end

function serialize_noref(s::Serializer, m::Model)
    id = modelid(m)
    if get(s.refs, id, nothing) === m
        return s.refscache[id]
    end
    mt = modeltype(m)
    vs = modelvalues(m)
    ans = Dict(
        "type"=>mt.name,
        "id"=>id,
        "attributes"=>Dict{String,Any}(string(k)=>serialize(s,v) for (k,v) in vs if v !== Undefined()),
    )
    s.refs[id] = m
    s.refscache[id] = ans
    return ans
end


### BASE

const BaseModel = ModelType("Model",
    inherits = [],
    props = [
        :name => NullableT(StringT()),
        :tags => ListT(AnyT()),
        :syncable => BoolT() |> DefaultT(true),
    ],
)


### TEXT

const BaseText = ModelType("BaseText";
    props = [
        :text => StringT(),
    ]
)

const MathText = ModelType("MathText";
    inherits = [BaseText],
)

const Ascii = ModelType("Ascii";
    inherits = [MathText],
)
export Ascii

const MathML = ModelType("MathML";
    inherits = [MathText],
)
export MathML

const TeX = ModelType("TeX";
    inherits = [MathText],
    props = [
        :macros => DictT(StringT(), EitherT(StringT(), TupleT(StringT(), IntT()))),
        :inline => BoolT(default=false),
    ]
)
export TeX

const PlainText = ModelType("PlainText";
    inherits = [BaseText],
)


### SOURCES

const DataSource = ModelType("DataSource")

const ColumnarDataSource = ModelType("ColumnarDataSource";
    inherits = [DataSource],
)

const ColumnDataSource = ModelType("ColumnDataSource";
    inherits = [ColumnarDataSource],
    props = [
        :data => ColumnDataT(),
        :column_names => GetSetT(x->collect(String,keys(x.data))),
    ],
)
export ColumnDataSource

const CDSView = ModelType("CDSView";
    props = [
        :filters => ListT(AnyT()),
        :source => InstanceT(ColumnarDataSource),
    ],
)
export CDSView


### TICKERS

const Ticker = ModelType("Ticker")

const ContinuousTicker = ModelType("ContinuousTicker";
    inherits = [Ticker],
)

const FixedTicker = ModelType("FixedTicker";
    inherits = [ContinuousTicker],
    props = [
        :ticks => SeqT(FloatT()),
        :minor_ticks => SeqT(FloatT()),
    ]
)


### LAYOUTS

const LayoutDOM = ModelType("LayoutDOM";
    props = [
        :disabled => BoolT(default=false),
        :visible => BoolT(default=true),
        :width => NullableT(NonNegativeIntT()),
        :height => NullableT(NonNegativeIntT()),
        :min_width => NullableT(NonNegativeIntT()),
        :min_height => NullableT(NonNegativeIntT()),
        :max_width => NullableT(NonNegativeIntT()),
        :max_height => NullableT(NonNegativeIntT()),
        :margin => NullableT(MarginT(), default=(0,0,0,0)),
        :width_policy => EitherT(AutoT(), SizingPolicyT(), default="auto"),
        :height_policy => EitherT(AutoT(), SizingPolicyT(), default="auto"),
        :aspect_ratio => EitherT(AutoT(), NullT(), FloatT()),
        :sizing_mode => NullableT(SizingModeT()),
        :align => EitherT(AlignT(), TupleT(AlignT(), AlignT()), default="start"),
        :background => NullableT(ColorT()),
        :css_classes => ListT(StringT()),
    ]
)

const HTMLBox = ModelType("HTMLBox";
    inherits = [LayoutDOM],
)

const Spacer = ModelType("Spacer";
    inherits = [LayoutDOM]
)
export Spacer

const GridBox = ModelType("GridBox";
    inherits = [LayoutDOM],
)
export GridBox

const Box = ModelType("Box";
    inherits = [LayoutDOM],
    props = [
        :children => ListT(InstanceT(LayoutDOM)),
        :spacing => IntT(default=0),
    ]
)

const Row = ModelType("Row";
    inherits = [Box],
    props = [
        :cols => EitherT(QuickTrackSizingT(), DictT(IntOrStringT(), ColSizingT()), default="auto"),
    ]
)
export Row

const Column = ModelType("Column";
    inherits = [Box],
    props = [
        :cols => EitherT(QuickTrackSizingT(), DictT(IntOrStringT(), RowSizingT()), default="auto"),
    ]
)
export Column



### TRANSFORMS

const Transform = ModelType("Transform")


### MAPPERS

const Mapper = ModelType("Mapper";
    inherits = [Transform],
)

const ColorMapper = ModelType("ColorMapper";
    inherits = [Mapper],
    props = [
        :palette => PaletteT(),
        :nan_color => ColorT() |> DefaultT("gray"),
    ],
)

const CategoricalMapper = ModelType("CategoricalMapper";
    inherits = [Mapper],
    props = [
        :factors => FactorSeqT(),
        :start => IntT() |> DefaultT(0),
        :end => IntT() |> NullableT,
    ],
)

const CategoricalColorMapper = ModelType("CategoricalColorMapper";
    inherits = [ColorMapper, CategoricalMapper],
)
export CategoricalColorMapper

const CategoricalMarkerMapper = ModelType("CategoricalMarkerMapper";
    inherits = [CategoricalMapper],
    props = [
        :markers => ListT(MarkerT()),
        :default_value => MarkerT() |> DefaultT("circle"),
    ]
)
export CategoricalMarkerMapper

const CategoricalPatternMapper = ModelType("CategoricalPatternMapper";
    inherits = [CategoricalMapper],
)
export CategoricalPatternMapper

const ContinuousColorMapper = ModelType("ContinuousColorMapper";
    inherits = [ColorMapper],
)
export ContinuousColorMapper

const LinearColorMapper = ModelType("LinearColorMapper";
    inherits = [ContinuousColorMapper],
)
export LinearColorMapper

const LogColorMapper = ModelType("LogColorMapper";
    inherits = [ContinuousColorMapper],
)
export LogColorMapper



### GLYPHS

const Glyph = ModelType("Glyph")

const XYGlyph = ModelType("XYGlyph";
    inherits = [Glyph],
)

const ConnectedXYGlyph = ModelType("ConnectedXYGlyph";
    inherits = [XYGlyph],
)

const LineGlyph = ModelType("LineGlyph";
    inherits = [Glyph],
)

const FillGlyph = ModelType("FillGlyph";
    inherits = [Glyph],
)

const TextGlyph = ModelType("TextGlyph";
    inherits = [Glyph],
)

const HatchGlyph = ModelType("HatchGlyph";
    inherits = [Glyph],
)

const Marker = ModelType("Marker";
    inherits = [XYGlyph, LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT() |> DefaultT(Field("x")),
        :y => NumberSpecT() |> DefaultT(Field("y")),
        :hit_dilation => FloatT() |> DefaultT(1.0),
        :size => SizeSpecT() |> DefaultT(4.0),
        # :angle => anglespec(default=0.0),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ],
)

const Scatter = ModelType("Scatter";
    inherits = [Marker],
    props = [
        :marker => MarkerSpecT() |> DefaultT("circle"),
    ],
)
export Scatter

const Image = ModelType("Image";
    inherits = [XYGlyph],
    props = [
        :image => NumberSpecT(default=Field("image")),
        :x => NumberSpecT(default=Field("x")),
        :y => NumberSpecT(default=Field("y")),
        :dw => NumberSpecT(default=Field("dw")),
        :dh => NumberSpecT(default=Field("dh")),
        :global_alpha => NumberSpecT(default=1.0),
        :dilate => BoolT(default=false),
        :color_mapper => InstanceT(ColorMapper, default=()->LinearColorMapper(palette="Greys9")),
    ]
)
export Image

const ImageRGBA = ModelType("ImageRGBA";
    inherits = [XYGlyph],
    props = [
        :image => NumberSpecT(default=Field("image")),
        :x => NumberSpecT(default=Field("x")),
        :y => NumberSpecT(default=Field("y")),
        :dw => NumberSpecT(default=Field("dw")),
        :dh => NumberSpecT(default=Field("dh")),
        :global_alpha => NumberSpecT(default=1.0),
        :dilate => BoolT(default=false),
    ]
)
export ImageRGBA

const Line = ModelType("Line";
    inherits = [ConnectedXYGlyph, LineGlyph],
    props = [
        :x => NumberSpecT() |> DefaultT(Field("x")),
        :y => NumberSpecT() |> DefaultT(Field("y")),
        SCALAR_LINE_PROPS,
    ],
)
export Line

const Quad = ModelType("Quad";
    inherits = [LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :left => NumberSpecT(default=Field("left")),
        :right => NumberSpecT(default=Field("right")),
        :bottom => NumberSpecT(default=Field("bottom")),
        :top => NumberSpecT(default=Field("top")),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)
export Quad

const VBar = ModelType("VBar";
    inherits = [LineGlyph, FillGlyph, HatchGlyph],
    props = [
        :x => NumberSpecT(default=Field("x")),
        :width => NumberSpecT(default=1.0),
        :bottom => NumberSpecT(default=0.0),
        :top => NumberSpecT(default=Field("top")),
        LINE_PROPS,
        FILL_PROPS,
        HATCH_PROPS,
    ]
)
export VBar


### RENERERS

const Renderer = ModelType("Renderer";
    props = [
        :level => RenderLevelT(),
        :visible => BoolT() |> DefaultT(true),
        :x_range_name => StringT() |> DefaultT("default"),
        :y_range_name => StringT() |> DefaultT("default"),
    ],
)

const DataRenderer = ModelType("DataRenderer";
    inherits = [Renderer],
    props = [
        :level => DefaultT("glyph"),
    ],
)

const GlyphRenderer = ModelType("GlyphRenderer";
    inherits = [DataRenderer],
    props = [
        :data_source => InstanceT(DataSource),
        :view => InstanceT(CDSView),
        :glyph => InstanceT(Glyph),
        :coordinates => NullT(), # TODO
        :group => NullT(), # TODO
        :hover_glyph => NullT(), # TODO
    ],
)
export GlyphRenderer

const GuideRenderer = ModelType("GuideRenderer";
    inherits = [Renderer],
    props = [
        :level => DefaultT("guide"),
    ]
)


### AXES

const Axis = ModelType("Axis";
    inherits = [GuideRenderer],
    props = [
        :axis_label => NullableT(StringT()),
        :ticker => TickerT(),
        :major_label_overrides => DictT(EitherT(FloatT(), StringT()), TextLikeT()),
    ],
)

const ContinuousAxis = ModelType("ContinuousAxis";
    inherits = [Axis],
)

const LinearAxis = ModelType("LinearAxis";
    inherits = [ContinuousAxis],
)
export LinearAxis

const LogAxis = ModelType("LogAxis";
    inherits = [ContinuousAxis],
)
export LogAxis

const CategoricalAxis = ModelType("CategoricalAxis";
    inherits = [Axis],
)
export CategoricalAxis

const DateTimeAxis = ModelType("DateTimeAxis";
    inherits = [LinearAxis],
)
export DateTimeAxis

const MercatorAxis = ModelType("MercatorAxis";
    inherits = [LinearAxis],
)
export MercatorAxis


### RANGES

const Range = ModelType("Range")

const Range1d = ModelType("Range1d";
    inherits = [Range],
    props = [
        :start => FloatT() |> DefaultT(0.0),
        :end => FloatT() |> DefaultT(1.0),
        :reset_start => EitherT(NullT(), FloatT()) |> DefaultT(nothing),
        :reset_end => EitherT(NullT(), FloatT()) |> DefaultT(nothing),
    ],
)
export Range1d

const DataRange = ModelType("DataRange";
    inherits = [Range],
)

const DataRange1d = ModelType("DataRange1d";
    inherits = [Range1d, DataRange],
    props = [
        :range_padding => FloatT(default=0.1),
        :start => EitherT(NullT(), FloatT()),
        :end => EitherT(NullT(), FloatT()),
    ]
)
export DataRange1d

const FactorRange = ModelType("FactorRange";
    inherits = [Range],
    props = [
        :factors => FactorSeqT(),
    ],
)
export FactorRange


### SCALES

const Scale = ModelType("Scale";
    inherits = [Transform],
)

const ContinuousScale = ModelType("ContinuousScale";
    inherits = [Scale],
)

const LinearScale = ModelType("LinearScale";
    inherits = [ContinuousScale],
)
export LinearScale

const LogScale = ModelType("LogScale";
    inherits = [ContinuousScale],
)
export LogScale

const CategoricalScale = ModelType("CategoricalScale";
    inherits = [Scale],
)
export CategoricalScale


### GRIDS

const Grid = ModelType("Grid";
    inherits = [GuideRenderer],
    props = [
        :dimension => IntT() |> DefaultT(0),
        :axis => InstanceT(Axis) |> NullableT,
        :grid => SCALAR_LINE_PROPS,
        :grid_line_color => DefaultT("#e5e5e5"),
        :minor_grid => SCALAR_LINE_PROPS,
        :minor_grid_line_color => DefaultT(nothing),
        :band => SCALAR_FILL_PROPS,
        :band_fill_alpha => DefaultT(0),
        :band_fill_color => DefaultT(nothing),
        :band => SCALAR_HATCH_PROPS,
        :level => DefaultT("underlay"),
    ],
)
export Grid


### ANNOTATIONS

const Annotation = ModelType("Renderer";
    inherits = [Renderer],
    props = [
        :level => DefaultT("annotation"),
    ]
)

const TextAnnotation = ModelType("TextAnnotation";
    inherits = [Annotation],
)

const Title = ModelType("Title";
    inherits = [TextAnnotation],
    props = [
        :text => StringT(default=""),
    ]
)
export Title

const LegendItem = ModelType("LegendItem";
    props = [
        :label => NullStringSpecT(),
        :renderers => ListT(InstanceT(GlyphRenderer)),
        :index => NullableT(IntT()),
        :visible => BoolT(default=true),
    ]
)
export LegendItem

const Legend = ModelType("Legend",
    inherits = [Annotation],
    props = [
        :location => EitherT(LegendLocationT(), TupleT(FloatT(), FloatT()), default="top_right"),
        :orientation => OrientationT(default="vertical"),
        :title => NullableT(StringT()),
        :title => SCALAR_TEXT_PROPS,
        :title_text_font_size => DefaultT("13px"),
        :title_text_font_style => DefaultT("italic"),
        :title_standoff => IntT(default=5),
        :border => SCALAR_LINE_PROPS,
        :border_line_color => DefaultT("#e5e5e5"),
        :border_line_alpha => DefaultT(0.5),
        :background => SCALAR_FILL_PROPS,
        :inactive => SCALAR_FILL_PROPS,
        :click_policy => LegendClickPolicyT(default="none"),
        :background_fill_color => DefaultT("#ffffff"),
        :background_fill_alpha => DefaultT(0.95),
        :inactive_fill_color => DefaultT("white"),
        :inactive_fill_alpha => DefaultT(0.7),
        :label => SCALAR_TEXT_PROPS,
        :label_text_baseline => DefaultT("middle"),
        :label_text_font_size => DefaultT("13px"),
        :label_standoff => IntT(default=5),
        :label_height => IntT(default=20),
        :label_width => IntT(default=20),
        :glyph_height => IntT(default=20),
        :glyph_width => IntT(default=20),
        :margin => IntT(default=10),
        :padding => IntT(default=10),
        :spacing => IntT(default=3),
        :items => ListT(InstanceT(LegendItem)),
    ]
)
export Legend


### TOOLS

const Tool = ModelType("Tool")

const ActionTool = ModelType("ActionTool";
    inherits = [Tool],
)

const GestureTool = ModelType("GestureTool";
    inherits = [Tool],
)

const Drag = ModelType("Drag";
    inherits = [GestureTool],
)

const Scroll = ModelType("Scroll";
    inherits = [GestureTool],
)

const Tap = ModelType("Tap";
    inherits = [GestureTool],
)

const SelectTool = ModelType("SelectTool";
    inherits = [GestureTool],
)

const InspectTool = ModelType("InspectTool";
    inherits = [GestureTool],
)

const PanTool = ModelType("PanTool";
    inherits = [Drag],
)
export PanTool

const RangeTool = ModelType("RangeTool";
    inherits = [Drag],
)
export RangeTool

const WheelPanTool = ModelType("WheelPanTool";
    inherits = [Scroll],
)
export WheelPanTool

const WheelZoomTool = ModelType("WheelZoomTool";
    inherits = [Scroll],
)
export WheelZoomTool

const CustomAction = ModelType("CustomAction";
    inherits = [ActionTool],
)

const SaveTool = ModelType("SaveTool";
    inherits = [ActionTool],
)
export SaveTool

const ResetTool = ModelType("ResetTool";
    inherits = [ActionTool],
)
export ResetTool

const TapTool = ModelType("TapTool";
    inherits = [Tap, SelectTool],
)
export TapTool

const CrosshairTool = ModelType("CrosshairTool";
    inherits = [InspectTool],
)
export CrosshairTool

const BoxZoomTool = ModelType("BoxZoomTool";
    inherits = [Drag],
)
export BoxZoomTool

const ZoomInTool = ModelType("ZoomInTool";
    inherits = [ActionTool],
)
export ZoomInTool

const ZoomOutTool = ModelType("ZoomOutTool";
    inherits = [ActionTool],
)
export ZoomOutTool

const BoxSelectTool = ModelType("BoxSelectTool";
    inherits = [Drag, SelectTool],
)
export BoxSelectTool

const LassoSelectTool = ModelType("LassoSelectTool";
    inherits = [Drag, SelectTool],
)
export LassoSelectTool

const PolySelectTool = ModelType("PolySelectTool";
    inherits = [Tap, SelectTool],
)
export PolySelectTool

const CustomJSHover = ModelType("CustomJSHover")
export CustomJSHover

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
export HoverTool

const HelpTool = ModelType("HelpTool";
    inherits = [ActionTool]
)
export HelpTool

const UndoTool = ModelType("UndoTool";
    inherits = [ActionTool]
)
export UndoTool

const RedoTool = ModelType("RedoTool";
    inherits = [ActionTool]
)
export RedoTool

const EditTool = ModelType("EditTool";
    inherits = [GestureTool]
)

const PolyTool = ModelType("PolyTool";
    inherits = [EditTool]
)

const BoxEditTool = ModelType("BoxEditTool";
    inherits = [EditTool, Drag, Tap]
)
export BoxEditTool

const PointDrawTool = ModelType("PointDrawTool";
    inherits = [EditTool, Drag, Tap]
)
export PointDrawTool

const PolyDrawTool = ModelType("PolyDrawTool";
    inherits = [PolyTool, Drag, Tap],
)
export PolyDrawTool

const FreehandDrawTool = ModelType("FreehandDrawTool";
    inherits = [EditTool, Drag, Tap],
)
export FreehandDrawTool

const PolyEditTool = ModelType("PolyEditTool";
    inherits = [PolyTool, Drag, Tap],
)
export PolyEditTool

const LineEditTool = ModelType("LineEditTool";
    inherits = [EditTool, Drag, Tap],
)
export LineEditTool





### TOOLBAR

const ToolbarBase = ModelType("ToolbarBase";
    props = [
        :logo => NullableT(EnumT(Set(["normal", "grey"])), default="normal"),
        :autohide => BoolT(default=false),
        :tools => ListT(InstanceT(Tool)),
    ]
)

const Toolbar = ModelType("Toolbar";
    inherits = [ToolbarBase],
    props = [
        :active_drag => EitherT(NullT(), AutoT(), InstanceT(Drag), default="auto"),
        :active_inspect => EitherT(NullT(), AutoT(), InstanceT(InspectTool), SeqT(InstanceT(InspectTool)), default="auto"),
        :active_scroll => EitherT(NullT(), AutoT(), InstanceT(Scroll), default="auto"),
        :active_tap => EitherT(NullT(), AutoT(), InstanceT(Tap), default="auto"),
        :active_multi => EitherT(NullT(), AutoT(), InstanceT(GestureTool), default="auto"),
    ]
)
export Toolbar

const ProxyToolbar = ModelType("ProxyToolbar";
    inherits = [ToolbarBase],
    props = [
        :toolbars => ListT(InstanceT(Toolbar)),
    ]
)
export ProxyToolbar

const ToolbarBox = ModelType("ToolbarBox";
    inherits = [LayoutDOM],
    props = [
        :toolbar_location => LocationT(default="right"),
    ],
)
export ToolbarBox


### PLOT

plot_get_renderers(plot::Model; type, sides, filter=nothing) = Model[m::Model for side in sides for m in getproperty(plot, side) if ismodelinstance(m::Model, type) && (filter === nothing || filter(m::Model))]
plot_get_renderers(; kw...) = (plot::Model) -> plot_get_renderers(plot; kw...)

function plot_get_renderer(plot::Model; plural, kw...)
    ms = plot_get_renderers(plot; kw...)
    if length(ms) == 0
        return Undefined()
    elseif length(ms) == 1
        return ms[1]
    else
        error("multiple $plural defined, consider using .$plural instead")
    end
end
plot_get_renderer(; kw...) = (plot::Model) -> plot_get_renderer(plot; kw...)

const Plot = ModelType("Plot";
    inherits = [LayoutDOM],
    props = [
        :x_range => InstanceT(Range, default=()->DataRange1d()),
        :y_range => InstanceT(Range, default=()->DataRange1d()),
        :x_scale => InstanceT(Scale, default=()->LinearScale()),
        :y_scale => InstanceT(Scale, default=()->LinearScale()),
        :extra_x_ranges => DictT(StringT(), InstanceT(Range)),
        :extra_y_ranges => DictT(StringT(), InstanceT(Range)),
        :extra_x_scales => DictT(StringT(), InstanceT(Scale)),
        :extra_y_scales => DictT(StringT(), InstanceT(Scale)),
        :hidpi => BoolT(default=true),
        :title => NullableT(TitleT(), default=()->Title()),
        :title_location => NullableT(LocationT(), default="above"),
        :outline => SCALAR_LINE_PROPS,
        :outline_line_color => DefaultT("#e5e5e5"),
        :renderers => ListT(InstanceT(Renderer)),
        :toolbar => InstanceT(Toolbar, default=()->Toolbar()),
        :toolbar_location => NullableT(LocationT(), default="right"),
        :toolbar_sticky => BoolT(default=true),
        :left => ListT(InstanceT(Renderer)),
        :right => ListT(InstanceT(Renderer)),
        :above => ListT(InstanceT(Renderer)),
        :below => ListT(InstanceT(Renderer)),
        :center => ListT(InstanceT(Renderer)),
        :width => NullableT(IntT(), default=600),
        :height => NullableT(IntT(), default=600),
        :frame_width => NullableT(IntT()),
        :frame_height => NullableT(IntT()),
        # :inner_width => PropType(Any; default=nothing),
        # :inner_height => PropType(Any; default=nothing),
        # :outer_width => PropType(Any; default=nothing),
        # :outer_height => PropType(Any; default=nothing),
        :background => SCALAR_FILL_PROPS,
        :background_fill_color => DefaultT("#ffffff"),
        :border => SCALAR_FILL_PROPS,
        :border_fill_color => DefaultT("#ffffff"),
        :min_border_top => NullableT(IntT()),
        :min_border_bottom => NullableT(IntT()),
        :min_border_left => NullableT(IntT()),
        :min_border_right => NullableT(IntT()),
        :min_border_top => NullableT(IntT(), default=5),
        :lod_factor => IntT(default=10),
        :lod_threshold => NullableT(IntT(), default=2000),
        :lod_interval => IntT(default=300),
        :lod_timeout => IntT(default=500),
        :output_backend => OutputBackendT(default="canvas"),
        :match_aspect => BoolT(default=false),
        :aspect_scale => FloatT(default=1.0),
        :reset_policy => ResetPolicyT(default="standard"),

        # getters/setters
        :x_axis => GetSetT(plot_get_renderer(type=Axis, sides=[:below,:above], plural=:x_axes)),
        :y_axis => GetSetT(plot_get_renderer(type=Axis, sides=[:left,:right], plural=:y_axes)),
        :axis => GetSetT(plot_get_renderer(type=Axis, sides=[:below,:left,:above,:right], plural=:axes)),
        :x_axes => GetSetT(plot_get_renderers(type=Axis, sides=[:below,:above])),
        :y_axes => GetSetT(plot_get_renderers(type=Axis, sides=[:left,:right])),
        :axes => GetSetT(plot_get_renderers(type=Axis, sides=[:below,:left,:above,:right])),
        :x_grid => GetSetT(plot_get_renderer(type=Grid, sides=[:center], filter=m->m.dimension==0, plural=:x_grids)),
        :y_grid => GetSetT(plot_get_renderer(type=Grid, sides=[:center], filter=m->m.dimension==1, plural=:y_grids)),
        :grid => GetSetT(plot_get_renderer(type=Grid, sides=[:center], plural=:grids)),
        :x_grids => GetSetT(plot_get_renderers(type=Grid, sides=[:center], filter=m->m.dimension==0)),
        :y_grids => GetSetT(plot_get_renderers(type=Grid, sides=[:center], filter=m->m.dimension==1)),
        :grids => GetSetT(plot_get_renderers(type=Grid, sides=[:center])),
        :legend => GetSetT(plot_get_renderer(type=Legend, sides=[:below,:left,:above,:right,:center], plural=:legends)),
        :legends => GetSetT(plot_get_renderers(type=Legend, sides=[:below,:left,:above,:right,:center])),
        :tools => GetSetT((m)->(m.toolbar.tools), (m,v)->(m.toolbar.tools=v)),
    ],
)
export Plot


### FIGURE

const Figure = ModelType("Plot", "Figure";
    inherits = [Plot],
)
export Figure
