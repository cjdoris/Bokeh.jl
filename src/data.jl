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

for (name, doc) in [
    ("anscombe", "The four data series that comprise 'Anscombe's Quartet'."),
    ("antibiotics", "A table of Will Burtin's historical data regarding antibiotic efficacies."),
    ("autompg", "A version of the Auto MPG data set."),
    ("autompg_clean", "A version of the Auto MPG data set. Cleans the `mfr` and `origin` fields."),
    ("autompg2", "A version of the Auto MPG data set."),
    ("browsers_nov_2013", "Browser market share by version from November 2013."),
    ("commits", "Time series of commits for a GitHub user between 2012 and 2016."),
    ("daylight_warsaw_2013", "2013 Warsaw daylight hours."),
    ("degrees", "A table of data regarding bachelor's degrees earned by women."),
    ("iris", "Fisher's Iris dataset."),
    ("obiszow_mtb_xcm", "Route data (including altitude) for a bike race in Eastern Europe."),
    ("numberly", ""),
    ("probly", ""),
    ("elements", "A periodic table dataset."),
    ("sea_surface_temperature", "Time series of historical average sea surface temperatures."),
    ("sprint", "Historical results for Olympic sprints by year."),
    ("unemployment1948", "US Unemployment rate data by month and year, from 1948 to 2013."),
    ("us_marriages_divorces", "U.S. marriage and divorce statistics between 1867 and 2014."),
    ("penguins", "The Palmer Archipelago (Antarctica) penguin dataset."),
    ("les_mis_nodes", "Co-occurrence of characters in Les Miserables."),
    ("les_mis_links", "Co-occurrence of characters in Les Miserables."),
    ("olympics2014", "Medal counts by country for the 2014 Olympics."),
    ("us_holidays", "Calendar file of US Holidays from Mozilla provided by `icalendar`."),
    ("us_states", "Geometry data for US States."),
]
    fname = Symbol(name)
    doc = """
        $(fname)([materializer])

    $(isempty(doc) ? "The $fname dataset." : doc)
    """
    @eval $(fname)(m=identity) = m(_load_table($name))
    @eval @doc $doc $fname
end

"""
    les_mis([materializer])

Co-occurrence of characters in Les Miserables.

Returns a named tuple `(nodes=..., links=...)` of nodes (characters) and links
(co-occurrences) between them.
"""
les_mis(m=identity) = (nodes=m(les_mis_nodes()), links=m(les_mis_links()))

end
