mathplot.gui.screens = mathplot.gui.screens or {}

local aboutStr = [[
Mathplot version {{version}}

https://github.com/kyleclaassen/minetest_mathplot/
]]
aboutStr = string.gsub(aboutStr, "{{version}}", mathplot.VERSION)

mathplot.gui.screens["about"] = {
    initialize = function(playername, identifier, context)
    end,
    get_formspec = function(playername, identifier, context)
        local formspec = "size[8.25,2.5]"
        .. string.format("textarea[0.25,0;8,2;;%s;;]", minetest.formspec_escape(aboutStr))
        .. "button_exit[0,2;2,1;btn_OK;OK]"
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
    end
}
