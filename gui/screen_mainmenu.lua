mathplot.gui.screens = mathplot.gui.screens or {}


local function open_originmenu(name_idx, playername)
    local names, locations = mathplot.get_origin_locations()
    if names[name_idx] ~= nil then
        local locationData = locations[names[name_idx]]
        if locationData ~= nil then
            local newContext = {
                node_pos = locationData.pos
            }
            mathplot.gui.invoke_screen("originmainmenu", playername, newContext)
        end
    end
end

local function teleport(name_idx, playername)
    local privs = minetest.get_player_privs(playername)
    if privs and privs.teleport then
        local names, locations = mathplot.get_origin_locations()
        if name_idx ~= nil then
            local name = names[name_idx]
            if name ~= nil then
                local locationData = locations[name]
                minetest.log("mathplot: player " .. playername .. " teleporting to " .. minetest.pos_to_string(locationData.pos))
                local player = minetest.get_player_by_name(playername)
                if player then
                    player:set_pos(locationData.pos)
                end
            end
        end
    end
end

mathplot.gui.screens["mainmenu"] = {
    initialize = function(playername, identifier, context)
        mathplot.remove_stale_locations()
    end,
    get_formspec = function(playername, identifier, context)
        local canTeleport = minetest.get_player_privs(playername).teleport
        local names, locations = mathplot.get_origin_locations()
        for i = 1, #names do
            names[i] = string.format("%s at %s", names[i], minetest.pos_to_string(locations[names[i]].pos))
        end
        local namesStr = mathplot.util.escape_textlist(names)
        local formspec = "size[6,6.5]"
        .. "label[0,0;Available mathplot origin nodes:]"
        .. string.format("textlist[0,0.5;5.75,5.5;originname_idx;%s;;]", namesStr)
        .. "button_exit[0,6;2,1;btn_open;Open]"
        .. "button_exit[4,6;2,1;btn_cancel;Cancel]"
        if canTeleport then
            formspec = formspec
            .. "button_exit[2,6;2,1;btn_teleport;Teleport]"
        end
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        if fields.originname_idx then
            local event = minetest.explode_textlist_event(fields.originname_idx)
            if event.type == "CHG" then
                context.selected_originname_idx = event.index
            end
        elseif fields.btn_open then
            if context.selected_originname_idx then
                open_originmenu(context.selected_originname_idx, playername)
            end
        elseif fields.btn_teleport then
            if context.selected_originname_idx then
                teleport(context.selected_originname_idx, playername)
            end
        end
    end
}
