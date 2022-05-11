function load_spec(name)
    open(JSON3.read, joinpath(dirname(@__DIR__), "spec", "$name.json"))
end

function parse_prop_type_expr(ex, ts)
    if ex isa Symbol
        if ex == :Null
            return NullT()
        elseif ex == :Bool
            return BoolT()
        elseif ex == :Int
            return IntT()
        elseif ex == :Float
            return FloatT()
        elseif ex == :String
            return StringT()
        elseif ex == :AnyRef
            return AnyT() # TODO
        elseif ex == :Percent
            return PercentT()
        elseif ex == :Auto
            return AutoT()
        elseif ex == :NonNegativeInt
            return NonNegativeIntT()
        elseif ex == :Color
            return ColorT()
        elseif ex == :Any
            return AnyT()
        elseif ex == :NonNegativeInt
            return NonNegativeIntT()
        elseif ex == :Alpha
            return AlphaT()
        elseif ex == :Size
            return SizeT()
        elseif ex == :MathString
            return MathStringT()
        elseif ex == :FontSize
            return FontSizeT()
        elseif ex == :Angle
            # TODO
            return FloatT()
        elseif ex == :DashPattern
            return DashPatternT()
        elseif ex == :HatchPatternType
            return HatchPatternT()
        elseif ex == :Datetime
            return DatetimeT()
        elseif ex == :TimeDelta
            return TimeDeltaT()
        elseif ex == :Date
            return DateT()
        elseif ex == :PositiveInt
            return PositiveIntT()
        elseif ex == :Base64String
            return Base64StringT()
        elseif ex == :JSON
            return JSONT()
        elseif ex == :Image
            return ImageT()
        elseif ex == :ColorHex
            return ColorHexT()
        end
    end
    if ex isa Expr && ex.head == :call
        if ex == :(Instance(Ticker))
            return TickerT()
        elseif ex == :(Seq(Color))
            return PaletteT()
        elseif ex == :(Instance(Title))
            return TitleT()
        end
        name = ex.args[1]
        args = []
        kw = Dict{Symbol,Any}()
        for a in ex.args[2:end]
            if a isa Expr && a.head == :kw
                @assert length(a.args) == 2
                kw[a.args[1]] = a.args[2]
            else
                push!(args, a)
            end
        end
        nargs = length(args)
        nkw = length(kw)
        if name == :Dict && nargs == 2
            return DictT(parse_prop_type_expr(args[1], ts), parse_prop_type_expr(args[2], ts))
        elseif name == :RestrictedDict && nargs == 2
            # TODO: disallowed keys
            return DictT(parse_prop_type_expr(args[1], ts), parse_prop_type_expr(args[2], ts))
        elseif name == :List && nargs == 1
            return ListT(parse_prop_type_expr(args[1], ts))
        elseif name == :Seq && nargs == 1
            return SeqT(parse_prop_type_expr(args[1], ts))
        elseif name == :Instance && nargs == 1
            iname = string(args[1]::Symbol)
            if haskey(ts, iname)
                t = ts[iname]
            else
                if iname == "Styles"
                    iname2 = "bokeh.models.css.$iname"
                elseif iname in ("DOMNode", "Action", "Template")
                    iname2 = "bokeh.models.dom.$iname"
                else
                    @assert false
                end
                @debug "assuming $iname is $iname2"
                t = ts[iname2]
            end
            return InstanceT(t)
        elseif name == :Nullable && nargs == 1
            return NullableT(parse_prop_type_expr(args[1], ts))
        elseif name in (:Either, :MinMaxBounds)
            return EitherT([parse_prop_type_expr(a, ts) for a in args]...)
        elseif name == :NonNullable && nargs == 1
            # TODO
            return parse_prop_type_expr(args[1], ts)
        elseif name in (:Enum, :MarkerType)
            return EnumT(Set{String}(args))
        elseif name == :Tuple
            return TupleT([parse_prop_type_expr(a, ts) for a in args]...)
        elseif name == :Struct
            # TODO
            return DictT(StringT(), AnyT())
        elseif name == :ColumnData
            return ColumnDataT()
        elseif name == :Readonly && nargs == 1
            # TODO
            return parse_prop_type_expr(args[1], ts)
        elseif name == :Interval && nargs > 0
            # TODO
            return parse_prop_type_expr(args[1], ts)
        elseif name == :Factor
            return FactorT()
        elseif name == :FactorSeq
            return FactorSeqT()
        elseif name == :PositiveInt
            return PositiveIntT()
        elseif name in (:DashPatternSpec, :IntSpec, :LineCapSpec, :LineJoinSpec, :NumberSpec, :ColorSpec, :AlphaSpec, :TextAlignSpec, :TextBaselineSpec, :FontSizeSpec, :FontStyleSpec, :HatchPatternSpec, :SizeSpec, :MarkerSpec) && nargs == 3
            return DataSpecT(parse_prop_type_expr(args[3], ts))
        elseif name == :AngleSpec
            return AngleSpecT()
        elseif name == :StringSpec
            return StringSpecT()
        elseif name == :NullStringSpec
            return NullStringSpecT()
        elseif name == :DistanceSpec
            return DistanceSpecT()
        elseif name == :NullDistanceSpec
            return NullDistanceSpecT()
        elseif name in (:UnitsSpec, :PropertyUnitsSpec)
            # TODO
            return NumberSpecT()
        end
    end
    @assert false
    @debug "cannot parse prop type $ex"
    return AnyT()
end

function parse_prop_default(x, t, mts)
    if x isa AbstractString && x == "<Undefined>"
        return Undefined()
    elseif (t.prim == NULL_T || t.prim == ANY_T) && x isa Nothing
        return x
    elseif (t.prim == BOOL_T || t.prim == ANY_T) && x isa Bool
        return x
    elseif (t.prim == INT_T || t.prim == ANY_T) && x isa Integer
        return convert(Int64, x)
    elseif (t.prim == FLOAT_T || t.prim == ANY_T) && x isa Real
        return convert(Float64, x)
    elseif (t.prim == STRING_T || t.prim == ANY_T) && x isa AbstractString
        return convert(String, x)
    elseif (t.prim == DICT_T || t.prim == ANY_T) && x isa AbstractDict
        if isempty(x)
            return () -> Dict()
        end
    elseif (t.prim == LIST_T || t.prim == ANY_T) && x isa AbstractVector
        ds = map(x->parse_prop_default(x, t.params[1], mts), x)
        if !any(ismissing, ds)
            if !any(d->d isa Function, ds)
                let ds=ds
                    return ()->copy(ds)
                end
            elseif all(d->d isa Function, ds)
                let ds=ds
                    return ()->[d() for d in ds]
                end
            end
        end
    elseif t.prim == TUPLE_T && x isa AbstractVector && length(x) == length(t.params)
        ds = map((x,t)->parse_prop_default(x,t,mts), x, t.params)
        if !any(ismissing, ds)
            if !any(d->d isa Function, ds)
                let d=Tuple(ds)
                    return () -> d
                end
            end
        end
    elseif t.prim == DATASPEC_T
        if x isa AbstractString && t.strings_are_fields
            return Field(x)
        end
        d0 = parse_prop_default(x, t.params[1], mts)
        if d0 === missing
            if x isa AbstractString
                return Field(x)
            elseif x isa AbstractDict && length(x) == 1 && haskey(x, "value")
                d0 = parse_prop_default(x["value"], t.params[1], mts)
                if d0 !== missing
                    if d0 isa Function
                        let d0=d0
                            return () -> Value(d0())
                        end
                    else
                        let d0=d0
                            return Value(d0)
                        end
                    end
                end
            elseif x isa AbstractDict && length(x) == 1 && haskey(x, "field")
                return Field(x["field"])
            end
        elseif d0 isa Function
            let d0=d0
                return () -> Value(d0())
            end
        else
            let d0=d0
                return Value(d0)
            end
        end
    elseif t.prim == EITHER_T
        for t in t.params
            d = parse_prop_default(x, t, mts)
            d === missing || return d
        end
    elseif t.prim == MODELINSTANCE_T
        d = parse_prop_default_modelinstance(x, mts)
        return d === nothing ? missing : d
    end
    return missing
end

function parse_prop_default_modelinstance(x, mts)
    # parse the JSON
    j = try; JSON3.read(x); catch; return; end
    j isa JSON3.Object || return
    # skip anything with nested models
    occursin("\"id\":", x) && return
    occursin("\"value\":", x) && return
    # split into type and kwargs
    kw = Kwarg[]
    tn = nothing
    for (k, v) in j
        if k == :__type__
            tn = v::String
        else
            push!(kw, Kwarg(k, v))
        end
    end
    # get the model type
    t = get(mts, tn, nothing)
    t === nothing && return
    # return the constructor
    let t=t, kw=kw
        return ()->Model(t, kw)
    end
end

function flatten_dag(children)
    children = Dict(k=>Set(vs) for (k,vs) in children)
    T = keytype(children)
    parents = Dict(k=>Set{T}() for k in keys(children))
    for (k, vs) in children
        for v in vs
            push!(parents[v], k)
        end
    end
    todo = Set(k for (k, vs) in children if isempty(vs))
    order = T[]
    while !isempty(todo)
        k = pop!(todo)
        push!(order, k)
        for v in parents[k]
            pop!(children[v], k)
            if isempty(children[v])
                push!(todo, v)
            end
        end
        pop!(parents, k)
    end
    isempty(parents) || error("not a DAG, these have a cycle: $(join(keys(parents), ", "))")
    return order
end

function generate_model_types()
    spec = load_spec("model_types")::JSON3.Array

    # generate blank types
    mspecs = Dict{String,JSON3.Object}()
    for mspec in spec
        @assert !haskey(mspecs, mspec.fullname)
        mspecs[mspec.fullname] = mspec
    end

    # check bases
    missing_bases = Set(bname for mspec in spec for bname in mspec.bases if !haskey(mspecs, bname))
    for bname in missing_bases
        @debug "missing base type $bname (should not be a model)"
    end

    # put the models in dependency order
    order = flatten_dag(Dict(k=>[b for b in v.bases if haskey(mspecs, b)] for (k,v) in mspecs))
    @assert order[1] == "bokeh.model.model.Model"

    # generate types without properties
    mtypes = Dict{String,ModelType}()
    mtypes2 = Dict{String,ModelType}()
    for mfullname in order
        # check the name
        mspec = mspecs[mfullname]
        @assert mspec.fullname == mfullname
        mname = mspec.name
        @assert !haskey(mtypes, mfullname)
        @assert !haskey(mtypes2, mname)
        # docstring
        docstring = mspec.desc::String
        # bases
        bases = ModelType[mtypes[bname] for bname in mspec.bases if haskey(mspecs, bname)]
        # make the type
        mt = ModelType(mname; bases, docstring)
        # save it
        mtypes[mfullname] = mt
        mtypes2[mname] = mt
        # export it
        if '.' ∉ mname
            xname = mname == "Model" ? :BaseModel : Symbol(mname)
            @eval const $xname = $mt
            @eval export $xname
        end
    end

    # properties/defaults which can't be determined automatically from the spec
    extra_props = Dict(
        :LayoutDOM => [
            :margin => NullableT(MarginT(), default=(0,0,0,0)),
        ],
        :Whisker => [
            :upper_head => DefaultT(()->TeeHead(size=10)),
            :lower_head => DefaultT(()->TeeHead(size=10)),
        ],
        :GraphRenderer => [
            :node_renderer => DefaultT(()->GlyphRenderer(glyph=Circle(), data_source=ColumnDataSource(data=Dict("index"=>[])))),
            :edge_renderer => DefaultT(()->GlyphRenderer(glyph=MultiLine(), data_source=ColumnDataSource(data=Dict("start"=>[], "end"=>[])))),
        ],
        :ColumnDataSource => [
            :column_names => GetSetT(x->collect(String,keys(x.data))),
        ],
        :Plot => [
            # sugar
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
            :ranges => GetSetT(m->PropVector([m.x_range::Model, m.y_range::Model])),
            :scales => GetSetT(m->PropVector([m.x_scale::Model, m.y_scale::Model])),
        ],
    )

    # add properties
    for mfullname in order
        mspec = mspecs[mfullname]
        mtype = mtypes[mfullname]
        extras = get(Vector, extra_props, Symbol(mtype.name))
        skippable = Set(k for (k,v) in extras if v isa PropType || v isa PropDesc)
        dskippable = Set(k for (k,v) in extras if v isa DefaultT)
        props = []
        # get props from spec
        for pspec in mspec.props
            # skip properties inherited from a base
            if any(pspec == bspec for bname in mspec.bases if haskey(mspecs, bname) for bspec in mspecs[bname].props)
                continue
            end
            pname = Symbol(pspec.name::String)
            if pname in skippable
                continue
            end
            pexpr = Meta.parse(replace(pspec.type::String, '''=>'"'))
            ptype = parse_prop_type_expr(pexpr, mtypes2)
            if pname ∉ dskippable
                pdflt = parse_prop_default(pspec.default, ptype, mtypes)
                if pdflt === missing
                    @debug "$(mtype.name): $pname: can't parse default=$(pspec.default), assuming Undefined()"
                    pdflt = Undefined()
                end
                ptype = DefaultT(ptype, pdflt)
            end
            docstring = pspec.desc::String
            push!(props, pname => PropDesc(ptype; docstring))
        end
        append!(props, extras)
        init_props!(mtype, props)
    end

    return mtypes
end

function generate_colors()
    data = load_spec("colors")
    colors = Dict(String(k)=>String(v) for (k,v) in data)
    color_enum = Set(keys(colors))
    @eval const NAMED_COLORS = $colors
    @eval const NAMED_COLOR_ENUM = $color_enum
end
generate_colors()

function generate_palettes()
    data = load_spec("palettes")
    Julia4 = ["#4063D8", "#CB3C33", "#389826", "#9558B2", ] # blue, red, green, purple
    Julia3 = Julia4[2:4] # red, green, purple (∴)
    Julia2 = Julia3[2:3] # green, purple
    palettes = Dict(String(k)=>collect(String,v) for (k,v) in data["all"])
    palettes["Julia4"] = Julia4
    palettes["Julia3"] = Julia3
    palettes["Julia2"] = Julia2
    palette_enum = Set(keys(palettes))
    palette_groups = Dict(String(k)=>Dict(parse(Int,String(k))=>collect(String,v) for (k,v) in v) for (k,v) in data["grouped"])
    palette_groups["Julia"] = Dict(2=>Julia2, 3=>Julia3, 4=>Julia4)
    @eval const PALETTES = $palettes
    @eval const PALETTE_ENUM = $palette_enum
    @eval const PALETTE_GROUPS = $palette_groups
end
generate_palettes()

function generate_hatch_patterns()
    data = load_spec("hatch_patterns")
    patterns = Dict(String(k)=>String(v) for (k,v) in data)
    pattern_enum = union(Set(keys(patterns)), Set(values(patterns)))
    @eval const HATCH_PATTERN_ENUM = $pattern_enum
end
generate_hatch_patterns()

function generate_dash_patterns()
    data = load_spec("dash_patterns")
    patterns = Dict(String(k)=>collect(Int,v) for (k,v) in data)
    pattern_enum = Set(keys(patterns))
    @eval const DASH_PATTERN_ENUM = $pattern_enum
    @eval const DASH_PATTERNS = $patterns
end
generate_dash_patterns()
