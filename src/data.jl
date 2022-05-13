module Data

import Dates
import JSON3
import Tables

function _data_path(args...)
    return joinpath(dirname(@__DIR__), "data", args...)
end

function _load_json(name)
    return open(JSON3.read, _data_path("$name.json"))
end

function _load_table(name)
    xcols = _load_json(name)::JSON3.Array
    cols = Tables.OrderedDict{Symbol,Vector}()
    for xcol in xcols
        xcol::JSON3.Object
        name = Symbol(xcol.name::String)
        xtype = xcol.type::String
        xdata = xcol.data::JSON3.Array
        data = [x===nothing ? missing : x for x in xdata]
        if xtype == "string"
            data = [x===nothing ? missing : x::String for x in xdata]
        elseif xtype == "integer"
            data = [x===nothing ? missing : convert(Int, x)::Int for x in xdata]
        elseif xtype == "number"
            data = [x===nothing ? missing : convert(Float64, x)::Float64 for x in xdata]
        elseif xtype == "time"
            data = [x===nothing ? missing : Dates.Time(x::String) for x in xdata]
        elseif xtype == "date"
            data = [x===nothing ? missing : Dates.Date(x::String) for x in xdata]
        elseif xtype == "datetime"
            data = [x===nothing ? missing : Dates.DateTime(x::String)]
        elseif xtype == "numberlist"
            data = [xs===nothing ? missing : [x===nothing ? missing : convert(Float64, x)::Float64 for x in xs] for xs in xdata]
            if any(xs !== missing && any(x===missing for x in xs) for xs in data)
                data = [x===missing ? x : Vector{Union{Float64,Missing}}(x) for x in data]
            end
        else
            @assert false
        end
        cols[name] = data
    end
    return cols
end

for name in [
    "anscombe", "antibiotics", "autompg", "autompg_clean", "autompg2", "browsers_nov_2013",
    "commits", "daylight_warsaw_2013", "degrees", "iris", "obiszow_mtb_xcm", "numberly",
    "probly", "elements", "sea_surface_temperature", "sprint", "unemployment1948",
    "us_marriages_divorces", "penguins", "les_mis_nodes", "les_mis_links", "olympics2014",
    "us_holidays", "us_states",
]
    fname = Symbol(name)
    @eval $(fname)(m=identity) = m(_load_table($name))
end

les_mis(m=identity) = (nodes=m(les_mis_nodes()), links=m(les_mis_links()))

end
