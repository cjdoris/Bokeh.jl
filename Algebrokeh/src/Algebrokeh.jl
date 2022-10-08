module Algebrokeh

using Base: @kwdef
using Bokeh: Bokeh
using DataFrames: DataFrame, groupby, combine, nrow
using Tables: Tables
using DataAPI: DataAPI

export plot, linesby

include("typedefs.jl")
include("layers.jl")
include("mappings.jl")
include("theme.jl")
include("draw.jl")
include("extras.jl")
include("init.jl")

end # module
