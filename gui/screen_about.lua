mathplot.gui.screens = mathplot.gui.screens or {}

local aboutStr = [[









Mathplot v. 0.5

Author: Kyle Claassen
kyle.m.claassen@gmail.com

TODO: VCS URL
TODO: License info
]]

mathplot.gui.screens["about"] = {
    initialize = function(playername, identifier, context)
    end,
    get_formspec = function(playername, identifier, context)
        local formspec = "size[8.25,6.5]"
            .. string.format("textlist[0,0;8,6;;%s;;]", minetest.formspec_escape(aboutStr))
            .. "button_exit[0,6;2,1;btn_OK;OK]"
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
    end
}
