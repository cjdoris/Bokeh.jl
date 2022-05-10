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
                    iname2 = "Model"
                end
                @debug "cannot find type $iname, assuming $iname2"
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
    @debug "cannot parse prop type $ex"
    return AnyT()
end

function maybe_parse_prop_default(x, t)
    if (t.prim == NULL_T || t.prim == ANY_T) && x isa Nothing
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
        ds = map(x->maybe_parse_prop_default(x, t.params[1]), x)
        if !any(ismissing, ds)
            if !any(d->d isa Function, ds)
                let ds=ds
                    return ()->copy(ds)
                end
            end
        end
    elseif t.prim == TUPLE_T && x isa AbstractVector && length(x) == length(t.params)
        ds = map(maybe_parse_prop_default, x, t.params)
        if !any(ismissing, ds)
            if !any(d->d isa Function, ds)
                let d=Tuple(ds)
                    return () -> d
                end
            end
        end
    elseif t.prim == DATASPEC_T
        d0 = maybe_parse_prop_default(x, t.params[1])
        if d0 === missing
            if x isa AbstractString
                return Field(x)
            elseif x isa AbstractDict && length(x) == 1 && haskey(x, "value")
                d0 = maybe_parse_prop_default(x["value"], t.params[1])
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
            d = maybe_parse_prop_default(x, t)
            d === missing || return d
        end
    elseif t.prim == MODELINSTANCE_T
        # TODO
        # There isn't enough information to recreate the default value.
        # Change gen_spec.py to output the right info.
        @debug "assuming default $x for $(t.model_type) is Undefined"
        return Undefined()
    end
    return missing
end

function parse_prop_default(x, t)
    if x isa AbstractString && x == "<Undefined>"
        return Undefined()
    else
        ans = maybe_parse_prop_default(x, t)
        if ans === missing
            @debug "cannot parse prop default $(repr(x)) for $(repr(t))"
            return Undefined()
        else
            return ans
        end
    end
end

function generate_model_types()
    spec = load_spec("model_types")::JSON3.Array

    # generate blank types
    mtypes = Dict{String,ModelType}()
    mspecs = Dict{String,JSON3.Object}()
    for mspec in spec
        @assert !haskey(mtypes, mspec.fullname)
        @assert !haskey(mspecs, mspec.fullname)
        mtypes[mspec.fullname] = ModelType(mspec.name)
        mspecs[mspec.fullname] = mspec
    end

    # add bases
    for mspec in spec
        mtype = mtypes[mspec.fullname]
        for bname in mspec.bases
            btype = get!(mtypes, bname) do
                if bname == "bokeh.model.model.Model"
                    name = "Model"
                elseif bname == "bokeh.models.widgets.buttons.ButtonLike"
                    name = "ButtonLike"
                else
                    name = bname
                end
                @debug "implicit base type $name"
                ModelType(name, abstract=true)
            end
            push!(mtype.bases, btype)
        end
    end

    # define consts
    for mt in values(mtypes)
        if '.' ∉ mt.name
            name = Symbol(mt.name)
            if name == :Model
                name = :BaseModel
            end
            @eval const $name = $mt
            if !mt.abstract
                @eval export $name
            end
        end
    end

    # overwrite these properties
    extra_props = Dict(
        (:ColorMapper => :palette) => PaletteT(),
        (:Axis => :ticker) => TickerT(),
        (:LinearAxis => :ticker) => TickerT(default=()->BasicTicker()),
        (:LogAxis => :ticker) => TickerT(default=()->LogTicker()),
        (:CategoricalAxis => :ticker) => TickerT(default=()->CategoricalTicker()),
        (:DatetimeAxis => :ticker) => TickerT(default=()->DatetimeTicker()),
        (:MercatorAxis => :ticker) => TickerT(default=()->MercatorTicker()),
        (:LayoutDOM => :margin) => NullableT(MarginT(), default=(0,0,0,0)),
        (:Plot => :title) => TitleT(),
        (:Plot => :toolbar) => InstanceT(Toolbar, default=()->Toolbar()),
        (:Plot => :x_axis) => GetSetT(plot_get_renderer(type=Axis, sides=[:below,:above], plural=:x_axes)),
        (:Plot => :y_axis) => GetSetT(plot_get_renderer(type=Axis, sides=[:left,:right], plural=:y_axes)),
        (:Plot => :axis) => GetSetT(plot_get_renderer(type=Axis, sides=[:below,:left,:above,:right], plural=:axes)),
        (:Plot => :x_axes) => GetSetT(plot_get_renderers(type=Axis, sides=[:below,:above])),
        (:Plot => :y_axes) => GetSetT(plot_get_renderers(type=Axis, sides=[:left,:right])),
        (:Plot => :axes) => GetSetT(plot_get_renderers(type=Axis, sides=[:below,:left,:above,:right])),
        (:Plot => :x_grid) => GetSetT(plot_get_renderer(type=Grid, sides=[:center], filter=m->m.dimension==0, plural=:x_grids)),
        (:Plot => :y_grid) => GetSetT(plot_get_renderer(type=Grid, sides=[:center], filter=m->m.dimension==1, plural=:y_grids)),
        (:Plot => :grid) => GetSetT(plot_get_renderer(type=Grid, sides=[:center], plural=:grids)),
        (:Plot => :x_grids) => GetSetT(plot_get_renderers(type=Grid, sides=[:center], filter=m->m.dimension==0)),
        (:Plot => :y_grids) => GetSetT(plot_get_renderers(type=Grid, sides=[:center], filter=m->m.dimension==1)),
        (:Plot => :grids) => GetSetT(plot_get_renderers(type=Grid, sides=[:center])),
        (:Plot => :legend) => GetSetT(plot_get_renderer(type=Legend, sides=[:below,:left,:above,:right,:center], plural=:legends)),
        (:Plot => :legends) => GetSetT(plot_get_renderers(type=Legend, sides=[:below,:left,:above,:right,:center])),
        (:Plot => :tools) => GetSetT((m)->(m.toolbar.tools), (m,v)->(m.toolbar.tools=v)),
        (:Plot => :ranges) => GetSetT(m->PropVector([m.x_range::Model, m.y_range::Model])),
        (:Plot => :scales) => GetSetT(m->PropVector([m.x_scale::Model, m.y_scale::Model])),
    )

    # get types by name
    mtypes2 = Dict{String,ModelType}()
    for mtype in values(mtypes)
        @assert !haskey(mtypes2, mtype.name)
        mtypes2[mtype.name] = mtype
    end

    # add props
    for mspec in spec
        mtype = mtypes[mspec.fullname]
        for pspec in mspec.props
            # skip properties inherited from a base
            if any(pspec == bspec for bname in mspec.bases if haskey(mspecs, bname) for bspec in mspecs[bname].props)
                continue
            end
            pname = Symbol(pspec.name::String)
            # skip properties we are going to overwrite anyway
            if haskey(extra_props, Symbol(mtype.name) => pname)
                continue
            end
            pexpr = Meta.parse(replace(pspec.type::String, '''=>'"'))
            ptype = parse_prop_type_expr(pexpr, mtypes2)
            pdflt = parse_prop_default(pspec.default, ptype)
            ptype = DefaultT(ptype, pdflt)
            mtype.propdescs[pname] = PropDesc(ptype)
        end
    end

    # override some props
    for ((mname, pname), prop) in extra_props
        mtypes2[string(mname)].propdescs[pname] = prop isa PropDesc ? prop : PropDesc(prop)
    end

    # inherit supers and props
    function inherit!(m::ModelType)
        if isempty(m.supers)
            for b in m.bases
                inherit!(b)
                union!(m.supers, b.supers)
            end
            push!(m.supers, m)
            props = Dict{Symbol,PropDesc}()
            for b in reverse(m.bases)
                merge!(props, b.propdescs)
            end
            merge!(props, m.propdescs)
            merge!(m.propdescs, props)
        end
    end
    for mtype in values(mtypes)
        inherit!(mtype)
    end

    return mtypes
end
