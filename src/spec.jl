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
    if ex isa Base.Expr && ex.head == :call
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
            if a isa Base.Expr && a.head == :kw
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
    t = mts[tn]
    # return the constructor
    let t=t, kw=kw
        return ()->ModelInstance(t, kw)
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

function parse_doc(text, rich)
    ans = []
    if rich === nothing
        push!(ans, Markdown.Paragraph(["<Could not parse docstring.>"]))
    else
        @assert rich.type == "document"
        for x in rich.children
            parse_doc_top(ans, x)
        end
        # remove any dangling headers
        ans = [ans[i] for i in 1:length(ans) if !(ans[i] isa Markdown.Header && (i == length(ans) || ans[i+1] isa Markdown.Header))]
        return ans
    end
end

function parse_doc_top(ans, x)
    t = x.type
    if t == "paragraph"
        items = []
        for x in x.children
            parse_doc_inline(items, x)
        end
        isempty(items) || push!(ans, Markdown.Paragraph(items))
    elseif t == "note"
        items = []
        for x in x.children
            parse_doc_top(items, x)
        end
        isempty(items) || push!(ans, Markdown.Admonition("note", "Note", items))
    elseif t == "warning"
        items = []
        for x in x.children
            parse_doc_top(items, x)
        end
        isempty(items) || push!(ans, Markdown.Admonition("warning", "Warning", items))
    elseif t == "comment"
        text = join(x.children)
        isempty(text) || push!(ans, Markdown.Admonition("note", "Note", [Markdown.Paragraph(text)]))
    elseif t == "bullet_list"
        items = []
        for x in x.children
            @assert x.type == "list_item"
            items2 = []
            for x in x.children
                parse_doc_top(items2, x)
            end
            push!(items, items2)
        end
        isempty(items) || push!(ans, Markdown.List(items, -1, true))
    elseif t == "literal_block"
        items = []
        for x in x.children
            if x isa AbstractString
                push!(items, convert(String, x))
            elseif x.type == "inline"
                push!(items, join(x.children))
            else
                error("code block item: $(x.type)")
            end
        end
        isempty(items) || push!(ans, Markdown.Code("python", join(items)))
    elseif t == "section"
        for x in x.children
            parse_doc_top(ans, x)
        end
    elseif t == "title"
        push!(ans, Markdown.Header([join(x.children)], 2))
    elseif t == "block_quote"
        items = []
        for x in x.children
            parse_doc_top(items, x)
        end
        isempty(items) || push!(ans, Markdown.BlockQuote(items))
    elseif t in ("definition_list", "field_list")
        items = []
        for x in x.children
            @assert x.type in ("definition_list_item", "field")
            @assert length(x.children) == 2
            xt, xd = x.children
            @assert xt.type in ("term", "field_name")
            @assert xd.type in ("definition", "field_body")
            titems = []
            for x in xt.children
                parse_doc_inline(titems, x)
            end
            ditems = []
            for x in xd.children
                parse_doc_top(ditems, x)
            end
            if isempty(ditems) || !isa(ditems[1], Markdown.Paragraph)
                pushfirst!(ditems, Markdown.Paragraph())
            end
            ditems[1] = Markdown.Paragraph([titems; ": "; ditems[1].content])
            push!(items, ditems)
        end
        isempty(items) || push!(ans, Markdown.List(items, -1, true))
    elseif t == "table"
        rows = []
        @assert length(x.children) == 1
        xg = x.children[1]
        @assert xg.type == "tgroup"
        for x in xg.children
            if x.type == "colspec"
                # skip
            elseif x.type in ("thead", "tbody")
                for x in x.children
                    @assert x.type == "row"
                    row = []
                    for x in x.children
                        @assert x.type == "entry"
                        entry = []
                        for x in x.children
                            @assert x.type == "paragraph"
                            for x in x.children
                                parse_doc_inline(entry, x)
                            end
                        end
                        push!(row, entry)
                    end
                    push!(rows, row)
                end
            else
                @assert false
            end
        end
        isempty(rows) || push!(ans, Markdown.Table(rows, [:l for _ in 1:length(rows[1])]))
    elseif t == "system_message"
        # skip
    else
        items = []
        parse_doc_inline(items, x)
        isempty(items) || push!(ans, Markdown.Paragraph(items))
    end
end

function parse_doc_inline(ans, x)
    if x isa AbstractString
        push!(ans, convert(String, x))
    else
        t = x.type
        if t == "literal"
            push!(ans, Markdown.Code(join(x.children)))
        elseif t == "strong"
            push!(ans, Markdown.Bold(join(x.children)))
        elseif t == "emphasis"
            push!(ans, Markdown.Italic(join(x.children)))
        elseif t == "problematic"
            text = join(x.children)
            if (m = match(r"^:([-a-z]+):`(.*)`$", text)) !== nothing
                push!(ans, Markdown.Code(text))
            else
                @assert false
                push!(ans, Markdown.Code("<Could not parse $text>"))
            end
        elseif t == "reference"
            text = join(x.children)
            push!(ans, text)
            # TODO: resolve references properly
            # push!(ans, Markdown.Link([text], text))
        elseif t in ("substitution_reference", "title_reference")
            text = join(x.children)
            push!(ans, text)
        elseif t in ("target", "substitution_definition")
            # skip
        else
            @assert false
            push!(ans, "<Could not parse $t>")
        end
    end
end

function generate_model_types()
    spec = load_spec("model_types")::JSON3.Array

    # generate blank types
    mspecs = Dict{String,JSON3.Object}()
    for mspec in spec
        @assert !haskey(mspecs, mspec.name)
        mspecs[mspec.name] = mspec
    end

    # check bases
    missing_bases = Set(bname for mspec in spec for bname in mspec.bases if !haskey(mspecs, bname))
    @assert isempty(missing_bases)

    # put the models in dependency order
    order = flatten_dag(Dict(k=>collect(v.bases) for (k,v) in mspecs))
    @assert order[1] == "Model"
    @assert length(order) == length(mspecs)

    # generate types without properties
    mtypes = Dict{String,ModelType}()
    for mname in order
        # check the name
        mspec = mspecs[mname]
        @assert mspec.name == mname
        @assert !haskey(mtypes, mname)
        # make the type
        mt = ModelType(
            name = mname,
            view_type = get(mspec, :view_type, mname),
            view_subtype = get(mspec, :view_subtype, nothing),
            doc = Markdown.MD(parse_doc(mspec.desc, mspec.richdesc)),
            bases = ModelType[mtypes[bname] for bname in mspec.bases],
        )
        mtypes[mname] = mt
        # the type is in its own MRO so needs to be created after
        mt.mro = ModelType[mtypes[tname] for tname in mspec.mro]
        # export it
        if '.' ∉ mname
            xname = Symbol(mname)
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
            :ranges => GetSetT(m->PropVector([m.x_range::ModelInstance, m.y_range::ModelInstance])),
            :scales => GetSetT(m->PropVector([m.x_scale::ModelInstance, m.y_scale::ModelInstance])),
        ],
    )

    # add properties
    for mname in order
        mspec = mspecs[mname]
        mtype = mtypes[mname]
        @assert mname == mtype.name
        extras = get(Vector, extra_props, Symbol(mtype.name))
        skippable = Set(k for (k,v) in extras if v isa PropType || v isa PropDesc)
        dskippable = Set(k for (k,v) in extras if v isa DefaultT)
        props = []
        # get props from spec
        for pspec in mspec.props
            pname = Symbol(pspec.name::String)
            pname in skippable && continue
            pexpr = Meta.parse(replace(pspec.type::String, '''=>'"'))
            ptype = parse_prop_type_expr(pexpr, mtypes)
            if pname ∉ dskippable
                pdflt = parse_prop_default(pspec.default, ptype, mtypes)
                if pdflt === missing
                    @debug "$(mtype.name): $pname: can't parse default=$(pspec.default), assuming Undefined()"
                    pdflt = Undefined()
                end
                ptype = DefaultT(ptype, pdflt)
            end
            doc = Markdown.MD(parse_doc(pspec.desc::String, pspec.richdesc))
            push!(props, pname => PropDesc(ptype; doc))
        end
        append!(props, extras)
        init_props!(mtype, props)
        # add properties to the docs (by which type they are inherited from) and bind the docstring
        push!(mtype.doc.content, Markdown.Header("Properties", 2))
        pnames = []
        for t in reverse(mtype.mro)
            push!(pnames, t.name => Symbol[k for k in keys(t.propdescs) if !any(k in ks for (_, ks) in pnames)])
        end
        items = []
        for (n, ks) in reverse(pnames)
            isempty(ks) && continue
            para = []
            push!(para, Markdown.Code(n), ": ")
            for k in sort(ks)
                push!(para, Markdown.Code(string(k)), ", ")
            end
            para[end] = "."
            push!(items, Any[Markdown.Paragraph(para)])
        end
        push!(mtype.doc.content, Markdown.List(items, -1, true))
        if '.' ∉ mname
            xname = Symbol(mname)
            @eval @doc $(mtype.doc) $xname
        end
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

function interpolate_palette(xs, n)
    xs = parse.(Colors.Colorant, xs)
    m = length(xs)
    ys = eltype(xs)[]
    for i in 1:(m-1)
        append!(ys, range(xs[i], xs[i+1], length=n))
        if i < m-1
            pop!(ys)
        end
    end
    @assert length(ys) == (n - 1) * (m - 1) + 1
    zs = ys[1:(m-1):end]
    @assert length(zs) == n
    @assert zs[1] == xs[1]
    @assert zs[end] == xs[end]
    return ["#" * lowercase(Colors.hex(c)) for c in zs]
end

const PALETTE_GROUP_TAGS = Dict(
    "Accent" => ["categorical"],
    "Blues" => ["continuous", "linear"],
    "Bokeh" => ["categorical"],
    "BrBG" => ["continuous", "diverging"],
    "BuGn" => ["continuous", "linear"],
    "BuPu" => ["continuous", "linear"],
    "Category10" => ["categorical"],
    "Category20" => ["categorical"],
    "Category20b" => ["categorical"],
    "Category20c" => ["categorical"],
    "Cividis" => ["continuous", "linear"],
    "Colorblind" => ["categorical"],
    "Dark2" => ["categorical"],
    "GnBu" => ["continuous", "linear"],
    "Greens" => ["continuous", "linear"],
    "Greys" => ["continuous", "linear"],
    "Inferno" => ["continuous", "linear"],
    "Julia" => ["categorical"],
    "Magma" => ["continuous", "linear"],
    "OrRd" => ["continuous", "linear"],
    "Oranges" => ["continuous", "linear"],
    "PRGn" => ["continuous", "diverging"],
    "Paired" => ["categorical"],
    "Pastel1" => ["categorical"],
    "Pastel2" => ["categorical"],
    "PiYG" => ["continuous", "diverging"],
    "Plasma" => ["continuous", "linear"],
    "PuBu" => ["continuous", "linear"],
    "PuBuGn" => ["continuous", "linear"],
    "PuOr" => ["continuous", "diverging"],
    "PuRd" => ["continuous", "linear"],
    "Purples" => ["continuous", "linear"],
    "RdBu" => ["continuous", "diverging"],
    "RdGy" => ["continuous", "diverging"],
    "RdPu" => ["continuous", "linear"],
    "RdYlBu" => ["continuous", "diverging"],
    "RdYlGn" => ["continuous", "diverging"],
    "Reds" => ["continuous", "linear"],
    "Set1" => ["categorical"],
    "Set2" => ["categorical"],
    "Set3" => ["categorical"],
    "Spectral" => ["continuous", "diverging"],
    "Turbo" => ["continuous", "diverging"],
    "Viridis" => ["continuous", "linear"],
    "YlGn" => ["continuous", "linear"],
    "YlGnBu" => ["continuous", "linear"],
    "YlOrBr" => ["continuous", "linear"],
    "YlOrRd" => ["continuous", "linear"],
)

# check the tags are consistent
for (g, tags) in PALETTE_GROUP_TAGS
    if "categorical" in tags
        # good
    elseif "continuous" in tags
        if "linear" in tags
            # good
        elseif "diverging" in tags
            # good
        else
            error("continuous palette group $g is not tagged linear or diverging")
        end
    else
        error("palette group $g is not tagged categorical or continuous")
    end
end

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
    # ensure the tags have full coverage
    @assert keys(palette_groups) == keys(PALETTE_GROUP_TAGS)
    # interpolate 256-color versions of continuous palettes
    for (pg, tags) in PALETTE_GROUP_TAGS
        "continuous" in tags || continue
        n0 = maximum(keys(palette_groups[pg]))
        p0 = "$(pg)$(n0)"
        old_palette = palettes[p0]
        for n1 in [3:11; 256]
            haskey(palette_groups[pg], n1) && continue
            p1 = "$(pg)$(n1)"
            new_palette = interpolate_palette(old_palette, n1)
            push!(palette_enum, p1)
            palettes[p1] = new_palette
            palette_groups[pg][n1] = new_palette
        end
    end
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
