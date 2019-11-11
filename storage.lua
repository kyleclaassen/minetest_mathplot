mathplot = mathplot or {}

local mod_storage = minetest.get_mod_storage()

mathplot.clear_origin_locations = function()
    mod_storage:set_string("origin_locations", nil)
end

mathplot.store_origin_location = function(name, pos)
    local locations = minetest.deserialize(mod_storage:get_string("origin_locations")) or {}
    local posStr = minetest.pos_to_string(pos)
    locations[posStr] = {
        name = name,
        pos = pos
    }
    mod_storage:set_string("origin_locations", minetest.serialize(locations))
end

mathplot.remove_origin_location = function(pos)
    local locations = minetest.deserialize(mod_storage:get_string("origin_locations")) or {}
    for posStr, locData in pairs(locations) do
        if vector.equals(locData.pos, pos) then
            locations[posStr] = nil
        end
    end
    mod_storage:set_string("origin_locations", minetest.serialize(locations))
end

mathplot.get_origin_locations = function()
    local s = mod_storage:get_string("origin_locations")
    local locations = minetest.deserialize(s) or {}
    return locations
end

mathplot.get_origin_location_lists = function()
    local locations = mathplot.get_origin_locations()

    local names = {}
    for _, locData in pairs(locations) do
        names[#names+1] = locData.name
    end
    --Case-insensitive sort
    table.sort(names, function(a,b) return string.lower(a) < string.lower(b) end)

    local posList = {}
    for _, n in ipairs(names) do
        for posStr, locData in pairs(locations) do
            if locData.name == n then
                posList[#posList+1] = locData.pos
            end
        end
    end

    return names, posList
end


mathplot.get_origin_locations_by_name = function(name)
    local locationsByPos = mathplot.get_origin_locations()
    local l = {}
    for _, locData in pairs(locationsByPos) do
        if locData.name == name then
            l[#l+1] = locData
        end
    end
    return l
end

mathplot.get_origin_location_by_pos = function(pos)
    local locationsByPos = mathplot.get_origin_locations()
    return locationsByPos[minetest.pos_to_string(pos)]
end

mathplot.remove_stale_locations = function()
    local locations = mathplot.get_origin_locations()
    for _, locData in pairs(locations) do
        local node = mathplot.util.get_far_node(locData.pos)
        if node and node.name ~= mathplot.ORIGIN_NODE_NAME then
            minetest.log("mathplot: removing stale origin node at " .. minetest.pos_to_string(locData.pos))
            mathplot.remove_origin_location(locData.pos)
        end
    end
end
