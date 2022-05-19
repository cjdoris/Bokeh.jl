function _hex_axial_to_cartesian(q, r; size=1, orientation="pointytop", aspect_scale=1)
    if orientation == "pointytop"
        x = size * sqrt(3) * (q + r / 2) / aspect_scale
        y = -size * 3/2  * r
    elseif orientation == "flattop"
        x = size * 3/2 * q
        y = -size * sqrt(3) * (r + q/2) * aspect_scale
    else
        error("invalid orientation: $(repr(orientation))")
    end
    return (x, y)
end

function _hex_cartesian_to_axial(x, y; size=1, orientation="pointytop", aspect_scale=1)
    if orientation == "pointytop"
        coords = (2/3, 0.0, -1/3, sqrt(3)/3)
        xscale = aspect_scale
        yscale = one(aspect_scale)
    elseif orientation == "flattop"
        coords = (sqrt(3)/3, -1/3, 0.0, 2/3)
        xscale = one(aspect_scale)
        yscale = aspect_scale
    else
        error("invalid orientation: $(repr(orientation))")
    end

    x = x / size * xscale
    y = -y / size / yscale

    q = coords[1] * x + coords[2] * y
    r = coords[3] * x + coords[4] * y

    return _hex_round(q, r)
end

function _hex_round(q, r) where {T}
    x = q
    z = r
    y = -(x+z)

    rx = round(Int, x)
    ry = round(Int, y)
    rz = round(Int, z)

    dx = abs(rx - x)
    dy = abs(ry - y)
    dz = abs(rz - z)

    rq::Int = rx
    rr::Int = rz
    if (dx > dy) && (dx > dz)
        rq = -(ry + rz)
        if !(dy > dz)
            rr = -(rx + ry)
        end
    end

    return (rq, rr)
end

function hexbin(x, y; size=1, orientation="pointytop", aspect_scale=1)
    counts = Dict{Tuple{Int,Int},Int}()
    for (x, y) in zip(x, y)
        qr = _hex_cartesian_to_axial(x, y; size, orientation, aspect_scale)
        counts[qr] = get(counts, qr, 0) + 1
    end
    q = [q for ((q,_),_) in counts]
    r = [r for ((_,r),_) in counts]
    count = [n for (_,n) in counts]
    return (; q, r, count)
end
