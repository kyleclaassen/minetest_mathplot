mathplot.util = mathplot.util or {}

mathplot.util.round = function(x)
    return math.floor(x+0.5)
end

mathplot.util.sgn = function(x)
    if math.abs(x) < 1e-8 then
        return 0
    elseif x > 0 then
        return 1
    else
        return -1
    end
end

--https://github.com/minetest/minetest/issues/6774
local my_round = function(d)
    if d >= 0 then
        return (d + 0.5) - (d + 0.5) % 1
    else
        return (d - 0.5) - (d - 0.5) % -1
    end
end
mathplot.util.round_vector = function(v)
    return vector.apply(v, my_round)
end

--Merge tables into table a
--E.g. merge_tables(a, b, c) will merge tables b and c into table a.
--A key must be present in table a, otherwise the value isn't merged in.
mathplot.util.merge_tables = function(a, ...)
    for _,t in ipairs({...}) do
        for k,v in pairs(t) do
            if a[k] ~= nil then
                a[k] = v
            end
        end
    end
    return a
end

mathplot.util.escape_textlist = function(list)
    local a = {}
    if list then
        for i, e in ipairs(list) do
            a[i] = minetest.formspec_escape(e)
        end
    end
    return table.concat(a, ",")
end


mathplot.util.get_far_node = function(pos)
    local node = minetest.get_node(pos)
    if node.name == "ignore" then
        minetest.get_voxel_manip():read_from_map(pos, pos)
        node = minetest.get_node(pos)
    end
    return node
end


mathplot.util.max_abs_coord = function(p)
    return math.max(math.abs(p.x), math.abs(p.y), math.abs(p.z))
end
