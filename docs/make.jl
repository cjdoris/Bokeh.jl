using Documenter, Bokeh

# hack presumably because I didn't generate markdown properly from the spec
# TODO: fix it
Base.convert(::Type{Vector{T}}, x::T) where {T<:Documenter.Utilities.Markdown2.MarkdownNode} = T[x]

open("docs/src/models.md", "w") do io
    props = sort([k for k in propertynames(Bokeh) if getproperty(Bokeh, k) isa Bokeh.ModelType])
    props = ["Bokeh.$k" for k in props]
    println(io, """
    # Models

    ```@docs
    $(join(props, "\n"))
    ```
    """)
end

makedocs(
    sitename = "Bokeh",
    modules = [Bokeh],
    pages = [
        "Home" => "index.md",
        "guide.md",
        "Reference" => [
            "plotting.md",
            "misc.md",
            "data.md",
            "models.md",
        ],
        "Gallery" => [
            "gallery/mandelbrot.md",
            "gallery/penguins.md",
            "gallery/vbar.md",
            "gallery/lorenz.md",
            "gallery/image.md",
            "gallery/image_rgba.md",
            "gallery/latex.md",
            "gallery/les_mis.md",
            "gallery/mpg.md",
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

deploydocs(
    repo = "github.com/cjdoris/Bokeh.jl.git",
)
