mathplot = mathplot or {}

local mod_storage = minetest.get_mod_storage()

mathplot.clear_origin_locations = function()
    mod_storage:set_string("origin_locations", nil)
end

mathplot.store_origin_location = function(name, pos)
    local locations = minetest.deserialize(mod_storage:get_string("origin_locations")) or {}
    locations[name] = {
        name = name,
        pos = pos
    }
    mod_storage:set_string("origin_locations", minetest.serialize(locations))
end

mathplot.remove_origin_location = function(pos)
    local locations = minetest.deserialize(mod_storage:get_string("origin_locations")) or {}
    for name, loc in pairs(locations) do
        if vector.equals(loc.pos, pos) then
            locations[name] = nil
        end
    end
    mod_storage:set_string("origin_locations", minetest.serialize(locations))
end

mathplot.get_origin_locations = function()
    local s = mod_storage:get_string("origin_locations")
    local locations = minetest.deserialize(s) or {}

    local names = {}
    for name, _ in pairs(locations) do
        names[#names+1] = name
    end
    table.sort(names)
    return names, locations
end


mathplot.get_origin_location_by_name = function(name)
    local _, locationsByName = mathplot.get_origin_locations()
    for locName, locData in pairs(locationsByName) do
        if locName == name then
            return locData
        end
    end
    return nil
end

mathplot.get_origin_location_by_pos = function(pos)
    local _, locationsByName = mathplot.get_origin_locations()
    for locName, locData in pairs(locationsByName) do
        if vector.equals(locData.pos, pos) then
            return locData
        end
    end
    return nil
end

mathplot.remove_stale_locations = function()
    local _, locations = mathplot.get_origin_locations()
    for _, locationData in pairs(locations) do
        local node = mathplot.util.get_far_node(locationData.pos)
        if node and node.name ~= "mathplot:origin" then
            minetest.log("mathplot: removing stale origin node at " .. minetest.pos_to_string(locationData.pos))
            mathplot.remove_origin_location(locationData.pos)
        end
    end
end