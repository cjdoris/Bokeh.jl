module Bokeh

# Base.Experimental.@compiler_options optimize=0 compile=min

import Base: IdSet
import Base64
import Colors
import Dates
import DefaultApplication
import JSON3
import Markdown
import Tables
import UUIDs

const BOKEH_VERSION = v"2.4.2"
const SRC_DIR = @__DIR__

export Field, Value, Document, Theme
export figure, plot!
export transform, dodge, factor_mark, factor_cmap, factor_hatch, jitter, linear_cmap, log_cmap
export row, column, widgetbox, gridplot
export js_on_change, js_link, js_on_event, js_on_click

include("data.jl")
include("typedefs.jl")
include("settings.jl")
include("spec.jl")
include("core.jl")
include("serialize.jl")
include("types.jl")
include("descs.jl")
include("models.jl")
include("plotting.jl")
include("templates.jl")
include("resources.jl")
include("theme.jl")
include("document.jl")
include("display.jl")
include("init.jl")
include("hex.jl")

precompile(figure, ())
precompile(Figure, ())
precompile(plot!, (ModelInstance, ModelType))
precompile(plot!, (ModelInstance, ModelInstance))
precompile(display, (BokehDisplay, ModelInstance))
precompile(display, (BokehDisplay, Document))

end
