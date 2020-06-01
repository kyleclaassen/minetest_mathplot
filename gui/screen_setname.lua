mathplot.gui.screens = mathplot.gui.screens or {}

local S = mathplot.get_translator

mathplot.gui.screens["set_name"] = {
    initialize = function(playername, identifier, context)
    end,
    get_formspec = function(playername, identifier, context)
        local loc = mathplot.get_origin_location_by_pos(context.node_pos)
        local nickname = loc ~= nil and loc.name or ""
        local formspec = "size[4,2.5]"
        .. string.format("label[0,0;%s]", S("Set Name"))
        .. string.format("field[0.25,1;4,1;txt_name;;%s]", minetest.formspec_escape(nickname))
        formspec = formspec
        .. string.format("button_exit[0,2;2,1;btn_OK;%s]", S("OK"))
        .. string.format("button_exit[2,2;2,1;btn_cancel;%s]", S("Cancel"))
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        if fields.btn_OK or fields.key_enter then
            local newName = string.trim(fields.txt_name)
            mathplot.store_origin_location(newName, context.node_pos)
        end
    end
}
