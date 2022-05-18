using Documenter, Bokeh

using DemoCards

gallery, gallery_cb, gallery_assets = makedemos("gallery")

# hack presumably because I didn't generate markdown properly from the spec
# TODO: fix it
Base.convert(::Type{Vector{T}}, x::T) where {T<:Documenter.Utilities.Markdown2.MarkdownNode} = T[x]

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

format = Documenter.HTML(
    edit_link = "master",
    prettyurls = get(ENV, "CI", nothing) == "true",
    assets = Any[gallery_assets],
)
makedocs(
    sitename = "Bokeh",
    modules = [Bokeh],
    format = format,
    pages = [
        "Home" => "index.md",
        "guide.md",
        "Reference" => [
            "plotting.md",
            "misc.md",
            "data.md",
            "models.md",
        ],
        gallery
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
