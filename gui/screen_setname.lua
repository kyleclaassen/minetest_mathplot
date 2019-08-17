mathplot.gui.screens = mathplot.gui.screens or {}

mathplot.gui.screens["set_nickname"] = {
    initialize = function(playername, identifier, context)
    end,
    get_formspec = function(playername, identifier, context)
        local loc = mathplot.get_origin_location_by_pos(context.node_pos)
        local nickname = loc ~= nil and loc.name or ""
        local formspec = "size[5.25,2.5]"
        .. "label[0,0;Set Node Nickname]"
        .. string.format("field[0.25,1;4,1;txt_nickname;;%s]", minetest.formspec_escape(nickname))
        if context.nickname_already_used then
            formspec = formspec
            .. "label[0,1.5;" .. minetest.colorize("#FF0000", string.format("Name '%s' already used", context.nickname_already_used)) .. "]"
        end
        formspec = formspec
        .. "button_exit[0,2;2,1;btn_OK;OK]"
        .. "button_exit[2,2;2,1;btn_cancel;Cancel]"
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        if fields.txt_nickname then
            local newName = string.trim(fields.txt_nickname)
            local loc = mathplot.get_origin_location_by_name(newName)
            if loc ~= nil then
                if not vector.equals(loc.pos, context.node_pos) then
                    --already have that name recorded on a different node. pick a different name.
                    context.nickname_already_used = newName
                    mathplot.gui.invoke_screen(identifier, playername, context)
                end
            else
                --Fresh name for this node. Remove existing entry and create new one.
                mathplot.remove_origin_location(context.node_pos)
                mathplot.store_origin_location(newName, context.node_pos)
            end
        end
    end
}
