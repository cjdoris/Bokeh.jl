# to build locally:
# > julia --project=docs/ -e 'using Pkg; Pkg.develop([PackageSpec(path="."), PackageSpec(path="./BokehBlink")]); Pkg.instantiate()'
# > julia --project=docs/ docs/make.jl
using Documenter, Bokeh, BokehBlink, DemoCards, Pkg

gallery, gallery_cb, gallery_assets = makedemos("gallery", edit_branch="main")

# hack presumably because I didn't generate markdown properly from the spec
# TODO: fix it
Base.convert(::Type{Vector{T}}, x::T) where {T<:Documenter.Utilities.Markdown2.MarkdownNode} = T[x]

function ranges(xs)
    rs = UnitRange{eltype(xs)}[]
    x0 = x1 = first(xs)
    for x in xs
        if x in (x1, x1+1)
            x1 = x
        else
            push!(rs, x0:x1)
            x0 = x1 = x
        end
    end
    push!(rs, x0:x1)
    return rs
end

function ranges_str(xs)
    return join([r.start == r.stop ? "$(r.start)" : "$(r.start)–$(r.stop)" for r in ranges(xs)], ", ")
end

open("docs/src/palettes.md", "w") do io
    names = Dict(v=>k for (k,v) in Bokeh.PALETTES)
    println(io, """
    # Palettes
    Only the largest palette in each group is shown.

    To get the full name of a palette, append the size to the group name, such as `Accent6`.
    If the group name ends contains a number, put an underscore between, such as `Category10_8`.
    """)
    for (tag, hdr) in [("categorical", "Categorical"), ("linear", "Linear"), ("diverging", "Diverging")]
        println(io, "## $hdr")
        for group in sort!(collect(keys(Bokeh.PALETTE_GROUPS)))
            tag in Bokeh.PALETTE_GROUP_TAGS[group] || continue
            println(io, "### $group")
            lens = sort(collect(keys(Bokeh.PALETTE_GROUPS[group])))
            name = names[Bokeh.PALETTE_GROUPS[group][lens[end]]]
            println(io, """
            Sizes: $(ranges_str(lens)).
            ```@example
            using Bokeh, Colors # hide
            parse.(Colorant, Bokeh.PALETTES["$name"]) # hide
            ```
            """)
        end
    end
end

open("docs/src/colors.md", "w") do io
    println(io, "# Named Colors")
    for name in sort!(collect(keys(Bokeh.NAMED_COLORS)))
        value = Bokeh.NAMED_COLORS[name]
        println(io, """
        #### $name (`$value`)
        ```@example
        using Bokeh, Colors # hide
        parse(Colorant, Bokeh.NAMED_COLORS["$name"]) # hide
        ```
        """)
    end
end

open("docs/src/models.md", "w") do io
    props = sort([k for k in propertynames(Bokeh) if getproperty(Bokeh, k) isa Bokeh.ModelType])
    println(io, "# Models")
    for (title, type) in [
        ("Glyphs", Glyph),
        ("Data Sources", DataSource),
        ("Axes", Axis),
        ("Ranges", Range),
        ("Annotations", Annotation),
        ("Other Renderers", Renderer),
        ("Tools", Tool),
        ("Transforms", Transform),
        ("Filters", Filter),
        ("Widgets", Widget),
        ("Layouts", LayoutDOM),
        ("Tickers", Ticker),
        ("Tick Formatters", TickFormatter),
        ("Labeling Policies", LabelingPolicy),
        ("Math Text", MathText),
        ("Expressions", Expression),
        ("Other", Model),
    ]
        oldprops = copy(props)
        empty!(props)
        curprops = String[]
        for k in oldprops
            if Bokeh.issubmodeltype(getproperty(Bokeh, k), type)
                push!(curprops, "Bokeh.$k")
            else
                push!(props, k)
            end
        end
        println(io, """

        ## $title

        ```@docs
        $(join(curprops, "\n"))
        ```
        """)
    end
end

open("docs/src/themes.md", "w") do io
    println(io, """
    # [Themes](@id themes)

    See [the theming section](@ref theming) to find out how to apply these themes.
    """)
    for name in sort(collect(keys(Bokeh.THEMES)))
        println(io, """

        ## $name

        ```@example
        using Bokeh
        p = figure(title="$name", width=300, height=300)
        plot!(p, Line; x=[1, 2, 3, 4, 5], y=[6, 7, 6, 4, 5])
        Document(p, theme="$name")
        ```
        """)
    end
end

format = Documenter.HTML(
    edit_link = "main",
    prettyurls = get(ENV, "CI", nothing) == "true",
    assets = Any[gallery_assets, "assets/customstyle.css"],
)
makedocs(
    sitename = "Bokeh",
    modules = [Bokeh, BokehBlink],
    format = format,
    pages = [
        "Home" => "index.md",
        gallery,
        "guide.md",
        "Reference" => [
            "plotting.md",
            "misc.md",
            "data.md",
            "models.md",
            "colors.md",
            "palettes.md",
            "themes.md",
        ],
    ],
    strict = [
        :autodocs_block,
        # :cross_references,
        :docs_block,
        :doctest,
        :eval_block,
        :example_block,
        :footnote,
        :linkcheck,
        :meta_block,
        # :missing_docs,
        :parse_error,
        :setup_block,
    ]
)

gallery_cb() # redirect URL and clean up tmp files

deploydocs(
    repo = "github.com/cjdoris/Bokeh.jl.git",
)
