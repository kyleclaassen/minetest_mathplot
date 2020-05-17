mathplot.gui.screens = mathplot.gui.screens or {}

local S = mathplot.get_translator

local function open_originmenu(name_idx, playername)
    local _, positions = mathplot.get_origin_location_lists()
    if name_idx ~= nil then
        local pos = positions[name_idx]
        if pos ~= nil then
            local newContext = {
                node_pos = pos
            }
            mathplot.gui.invoke_screen("originmainmenu", playername, newContext)
        end
    end
end

local function teleport(name_idx, playername)
    local privs = minetest.get_player_privs(playername)
    if privs and privs.teleport then
        local _, positions = mathplot.get_origin_location_lists()
        if name_idx ~= nil then
            local pos = positions[name_idx]
            minetest.log(S("mathplot: player @1 teleporting to @2", playername, minetest.pos_to_string(pos)))
            local player = minetest.get_player_by_name(playername)
            if player then
                player:set_pos(pos)
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
        local names, positions = mathplot.get_origin_location_lists()
        for i = 1, #names do
            names[i] = S("@1 at @2", names[i], minetest.pos_to_string(positions[i]))
        end
        local namesStr = mathplot.util.escape_textlist(names)
        local formspec = "size[6,6.5]"
        .. string.format("label[0,0;%s]", S("Available mathplot origin nodes:"))
        .. string.format("textlist[0,0.5;5.75,5.5;originname_idx;%s;;]", namesStr)
        .. string.format("button_exit[0,6;2,1;btn_open;%s]", S("Open"))
        .. string.format("button_exit[4,6;2,1;btn_cancel;%s]", S("Cancel"))
        if canTeleport then
            formspec = formspec
            .. string.format("button_exit[2,6;2,1;btn_teleport;%s]", S("Teleport"))
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
