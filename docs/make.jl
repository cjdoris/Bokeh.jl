using Documenter, Bokeh

makedocs(
    sitename = "Bokeh",
    modules = [Bokeh],
    pages = [
        "Home" => "index.md",
        "Gallery" => [
            "gallery/penguins.md",
            "gallery/vbar.md",
            "gallery/lorenz.md",
            "gallery/image.md",
            "gallery/image_rgba.md",
            "gallery/latex.md",
            "gallery/les_mis.md",
        ],
    ]
)

deploydocs(
    repo = "github.com/cjdoris/Bokeh.jl.git",
)
