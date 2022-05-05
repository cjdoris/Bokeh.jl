### MODELTYPE

function ModelType(name, subname=nothing;
    inherits=[BaseModel],
    props=[],
)
    proptypes = Dict{Symbol,PropType}()
    supers = IdSet{ModelType}()
    for t in inherits
        mergeproptypes!(proptypes, t.proptypes)
        push!(supers, t)
        union!(supers, t.supers)
    end
    mergeproptypes!(proptypes, props)
    return ModelType(name, subname, inherits, proptypes, supers)
end

function mergeproptypes!(ts, x; name=nothing)
    if x isa PropType
        ts[name] = x
    elseif x isa Pair
        name = name===nothing ? x.first : Symbol(name, "_", x.first)
        mergeproptypes!(ts, x.second; name)
    elseif x isa Function
        ts[name] = x(ts[name])
    else
        for t in x
            mergeproptypes!(ts, t; name)
        end
    end
end

(t::ModelType)(; kw...) = Model(t; kw...)

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
    # look up the type
    mt = modeltype(m)
    ts = mt.proptypes
    t = get(ts, k, Undefined())
    t === Undefined() && error("$(mt.name): .$k: invalid property")
    # get the default value
    d = t.default
    if d isa Function
        v = vs[k] = d()
    else
        v = d
    end
    return v
end

function Base.setproperty!(m::Model, k::Symbol, x)
    if x === Undefined()
        # delete the value
        vs = modelvalues(m)
        delete!(vs, k)
    else
        # look up the type
        mt = modeltype(m)
        ts = mt.proptypes
        t = get(ts, k, Undefined())
        t === Undefined() && error("$(mt.name): .$k: invalid property")
        # validate the value
        v = validate(t, x)
        v isa Invalid && error("$(mt.name): .$k: $(v.msg)")
        # set it
        vs = modelvalues(m)
        vs[k] = v
    end
    return m
end

function Base.hasproperty(m::Model, k::Symbol)
    ts = modeltype(m).proptypes
    return haskey(ts, k)
end

function Base.propertynames(m::Model)
    ts = modeltype(m).proptypes
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


### SOURCES

const DataSource = ModelType("DataSource")

const ColumnarDataSource = ModelType("ColumnarDataSource";
    inherits = [DataSource],
)

const ColumnDataSource = ModelType("ColumnDataSource";
    inherits = [ColumnarDataSource],
    props = [
        :data => ColumnDataT(),
    ],
)
export ColumnDataSource

const CDSView = ModelType("CDSView";
    props = [
        :filters => ListT(AnyT()),
        :source => ModelInstanceT(ColumnarDataSource),
    ],
)
export CDSView


### LAYOUTS

const LayoutDOM = ModelType("LayoutDOM")


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
        :color_mapper => ModelInstanceT(ColorMapper, default=()->LinearColorMapper(palette="Greys9")),
    ]
)
export Image

const Line = ModelType("Line";
    inherits = [ConnectedXYGlyph, LineGlyph],
    props = [
        :x => NumberSpecT() |> DefaultT(Field("x")),
        :y => NumberSpecT() |> DefaultT(Field("y")),
        SCALAR_LINE_PROPS,
    ],
)
export Line

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
        :data_source => ModelInstanceT(DataSource),
        :view => ModelInstanceT(CDSView),
        :glyph => ModelInstanceT(Glyph),
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
        # :bounds => PropType(Union{Auto,Tuple{Real,Real},Tuple{DateTime,DateTime},Tuple{Date,Date}}; default=Auto()),
        # :ticker => PropType(Any; default=nothing),
        # :formatter => PropType(Any; default=nothing),
        :axis_label => StringT() |> NullableT,
        # :axis_label_standoff => PropType(Any; default=nothing),
        # :axis_label_props => PropType(Any; default=nothing),
        # :axis_label_text_font_size => PropType(Any; default=nothing),
        # :axis_label_text_font_style => PropType(Any; default=nothing),
        # :major_label_standoff => PropType(Any; default=nothing),
        # ETC
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
        :axis => ModelInstanceT(Axis) |> NullableT,
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

const HelpTool = ModelType("HelpTool";
    inherits = [ActionTool],
)
export HelpTool



### TOOLBAR

const ToolbarBase = ModelType("ToolbarBase";
    props = [
        :logo => NullableT(EnumT(Set(["normal", "grey"])), default="normal"),
        :autohide => BoolT(default=false),
        :tools => ListT(ModelInstanceT(Tool)),
    ]
)

const Toolbar = ModelType("Toolbar";
    inherits = [ToolbarBase],
    props = [
        :active_drag => EitherT(NullT(), AutoT(), ModelInstanceT(Drag), default="auto"),
        :active_inspect => EitherT(NullT(), AutoT(), ModelInstanceT(InspectTool), SeqT(ModelInstanceT(InspectTool)), default="auto"),
        :active_scroll => EitherT(NullT(), AutoT(), ModelInstanceT(Scroll), default="auto"),
        :active_tap => EitherT(NullT(), AutoT(), ModelInstanceT(Tap), default="auto"),
        :active_multi => EitherT(NullT(), AutoT(), ModelInstanceT(GestureTool), default="auto"),
    ]
)
export Toolbar

const ProxyToolbar = ModelType("ProxyToolbar";
    inherits = [ToolbarBase],
    props = [
        :toolbars => ListT(ModelInstanceT(Toolbar)),
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

const Plot = ModelType("Plot";
    inherits = [LayoutDOM],
    props = [
        :x_range => ModelInstanceT(Range, default=()->DataRange1d()),
        :y_range => ModelInstanceT(Range, default=()->DataRange1d()),
        :x_scale => ModelInstanceT(Scale, default=()->LinearScale()),
        :y_scale => ModelInstanceT(Scale, default=()->LinearScale()),
        # :x_scale => PropType(Any; default=nothing),
        # :y_scale => PropType(Any; default=nothing),
        # :extra_x_ranges => PropType(Any; default=nothing),
        # :extra_y_ranges => PropType(Any; default=nothing),
        # :extra_x_scales => PropType(Any; default=nothing),
        # :extra_y_scales => PropType(Any; default=nothing),
        :hidpi => BoolT(default=true),
        :title => NullableT(TitleT(), default=()->Title()),
        :title_location => NullableT(LocationT(), default="above"),
        # :outline_props => PropType(Any; default=nothing),
        # :outline_line_color => PropType(Any; default=nothing),
        :renderers => ListT(ModelInstanceT(Renderer)),
        :toolbar => ModelInstanceT(Toolbar, default=()->Toolbar()),
        :toolbar_location => NullableT(LocationT(), default="right"),
        :toolbar_sticky => BoolT(default=true),
        :left => ListT(ModelInstanceT(Renderer)),
        :right => ListT(ModelInstanceT(Renderer)),
        :above => ListT(ModelInstanceT(Renderer)),
        :below => ListT(ModelInstanceT(Renderer)),
        :center => ListT(ModelInstanceT(Renderer)),
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
        # :min_border_top => PropType(Union{Integer,Nothing}; default=nothing),
        # :min_border_bottom => PropType(Union{Integer,Nothing}; default=nothing),
        # :min_border_left => PropType(Union{Integer,Nothing}; default=nothing),
        # :min_border_right => PropType(Union{Integer,Nothing}; default=nothing),
        # :min_border => PropType(Union{Integer,Nothing}; default=nothing),
        # :lod_factor => PropType(Integer; default=10),
        # :lod_threshold => PropType(Union{Integer,Nothing}; default=2000),
        # :lod_interval => PropType(Integer; default=300),
        # :lod_timeout => PropType(Integer; default=500),
        # :output_backend => PropType(Any; default=nothing),
        # :match_aspect => PropType(Bool; default=false),
        # :aspect_scale => PropType(Real; default=1.0),
        # :reset_policy => PropType(AbstractString; default="standard"),
    ],
)
export Plot

### FIGURE

const Figure = ModelType("Plot", "Figure";
    inherits = [Plot],
)
export Figure
