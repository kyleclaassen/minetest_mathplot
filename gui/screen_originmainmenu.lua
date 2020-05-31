mathplot.gui.screens = mathplot.gui.screens or {}

local S = mathplot.get_translator

mathplot.gui.screens["originmainmenu"] = {
    initialize = function(playername, identifier, context)
    end,
    get_formspec = function(playername, identifier, context)
        local loc = mathplot.get_origin_location_by_pos(context.node_pos)
        local nodeName = nil
        if loc and #loc.name > 0 then
            nodeName = loc.name
        end
        local title = S("Mathematical Object Plotter at @1", minetest.pos_to_string(context.node_pos))
        local nodeNameText = ""
        if nodeName then
            nodeNameText = minetest.formspec_escape(S("Node Name: \"@1\"", nodeName))
        end
        local formspec = "size[9,4.75]"
        .. string.format("label[0,0;%s]", title)
        .. string.format("label[0,0.5;%s]", nodeNameText)
        .. string.format("button_exit[0,1.25;3,1;btn_set_name;%s]", S("Set Name"))
        .. string.format("button_exit[3,1.25;3,1;btn_draw_axes;%s]", S("Draw Axes"))
        .. string.format("button_exit[6,1.25;3,1;btn_implicit_plot;%s]", S("Implicit Plot"))
        .. string.format("button_exit[0,2.25;3,1;btn_parametric_curve;%s]", S("Parametric Curve"))
        .. string.format("button_exit[3,2.25;3,1;btn_parametric_surface;%s]", S("Parametric Surface"))
        .. string.format("button_exit[6,2.25;3,1;btn_parametric_solid;%s]", S("Parametric Solid"))
        .. string.format("button_exit[0,3.25;3,1;btn_originlist;%s]", S("Other Nodes"))
        .. string.format("button_exit[3,3.25;3,1;btn_serialize;%s]", S("Serialize/Deserialize"))
        .. string.format("button_exit[6,3.25;3,1;btn_examples;%s]", S("Examples"))
        .. string.format("button_exit[0,4.25;3,1;btn_about;%s]", S("About"))
        .. string.format("button_exit[6,4.25;3,1;btn_exit;%s]", S("Exit"))
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        --Invoke the appropriate screen based on which button was clicked.
        --E.g. if "btn_draw_axes" was clicked, then "btn_" is stripped from
        --the button name, and the remaining "draw_axes" is used as
        --the screen name.
        for name, _ in pairs(fields) do
            if string.match(name, "^btn_") then
                local screenName = string.gsub(name, "^btn_", "")
                local screenExists = mathplot.gui.screens[screenName] ~= nil
                if screenExists then
                    mathplot.gui.invoke_screen(screenName, playername, context)
                    break
                end
            end
        end
    end
}
