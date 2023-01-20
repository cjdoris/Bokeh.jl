using Downloads: download

old_version = "2.4.2"
version = "2.4.3"
base_url = "https://cdn.bokeh.org/bokeh/release"
components = ["bokeh", "bokeh-gl", "bokeh-widgets", "bokeh-tables", "bokeh-mathjax"]

for component in components
    if old_version !== nothing
        rm("$(component)-$(old_version).min.js")
    end
    file = "$(component)-$(version).min.js"
    url = "$(base_url)/$(file)"
    @info "downloading $url"
    download(url, file)
end

url = "https://raw.githubusercontent.com/bokeh/bokeh/$(version)/LICENSE.txt"
@info "downloading $url"
open("../BOKEH_LICENSE.txt", "w") do io
    println(io, """
    A significant portion of the code in this project is copied, derived or modified
    from the original Bokeh repository at https://github.com/bokeh/bokeh. Below is
    the license pertaining to this portion.

    ---------------------------------------------------------------------------------
    """)
    download(url, io)
end
