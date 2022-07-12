function Theme(attrs)
    ans = Theme()
    for (k, v) in attrs
        ans.attrs[Symbol(k)] = Dict{Symbol,Any}(Symbol(k) => v for (k,v) in v)
    end
    return ans
end
