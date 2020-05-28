mathplot.gui.screens = mathplot.gui.screens or {}

local S = mathplot.get_translator

local function parse_and_validate(playername, identifier, fields, context)
    local e = {}  --list of error messages
    local p = table.copy(fields)

    if not mathplot.util.has_mathplot_priv(playername) then
        e[#e+1] = S("Must have the 'mathplot' privilege in order to use this node.")
    end

    if minetest.string_to_pos(p.e1) == nil then
        e[#e+1] = S("Invalid +x Direction.")
    end
    if minetest.string_to_pos(p.e2) == nil then
        e[#e+1] = S("Invalid +y Direction.")
    end
    if minetest.string_to_pos(p.e3) == nil then
        e[#e+1] = S("Invalid +z Direction.")
    end

    p.xmin = tonumber(p.xmin)
    p.xmax = tonumber(p.xmax)
    if p.xmin == nil then
        e[#e+1] = S("x Min must be a number.")
    end
    if p.xmax == nil then
        e[#e+1] = S("x Max must be a number.")
    end
    if p.xmin ~= nil and p.xmax ~= nil and p.xmin > p.xmax then
        e[#e+1] = S("x Min must be <= x Max.")
    end

    p.ymin = tonumber(p.ymin)
    p.ymax = tonumber(p.ymax)
    if p.ymin == nil then
        e[#e+1] = S("y Min must be a number.")
    end
    if p.ymax == nil then
        e[#e+1] = S("y Max must be a number.")
    end
    if p.ymin ~= nil and p.ymax ~= nil and p.ymin > p.ymax then
        e[#e+1] = S("y Min must be <= y Max.")
    end

    p.zmin = tonumber(p.zmin)
    p.zmax = tonumber(p.zmax)
    if p.zmin == nil then
        e[#e+1] = S("z Min must be a number.")
    end
    if p.zmax == nil then
        e[#e+1] = S("z Max must be a number.")
    end
    if p.zmin ~= nil and p.zmax ~= nil and p.zmin > p.zmax then
        e[#e+1] = S("z Min must be <= z Max.")
    end

    if not mathplot.util.is_drawable_node(p.xaxisbrush) then
        e[#e+1] = S("x-axis brush '@1' is not a drawable node.", p.xaxisbrush or "")
    end
    if not mathplot.util.is_drawable_node(p.yaxisbrush) then
        e[#e+1] = S("y-axis brush '@1' is not a drawable node.", p.yaxisbrush or "")
    end
    if not mathplot.util.is_drawable_node(p.zaxisbrush) then
        e[#e+1] = S("z-axis brush '@1' is not a drawable node.", p.zaxisbrush or "")
    end

    if #e == 0 then
        return p, e
    end
    --If errors, return original values
    return fields, e
end


local function draw_axes_initialize(playername, identifier, context)
    if not context.screen_params then
        local meta = minetest.get_meta(context.node_pos)
        local s = meta:get_string("axis_params")
        context.screen_params = mathplot.util.merge_tables(
            mathplot.plotdefaults.axis_params(),
            minetest.deserialize(s) or {}
        )
    end
    return context
end

local function draw_axes_get_formspec(playername, identifier, context)
    local p = context.screen_params
    local nodepos = context.node_pos

    mathplot.gui.set_brushes(
        playername,
        { xaxisbrush = p.xaxisbrush, yaxisbrush = p.yaxisbrush, zaxisbrush = p.zaxisbrush })

    local formspec = "size[9,8.5;]"
    .. string.format("label[0,0;%s]", S("Draw Axes"))
    --Axis window ranges and direction vectors
    .. "container[0,1]"
    .. string.format("label[0,0;%s] field[1.4,0;1.25,1;xmin;;%s]", S("x Min:"), p.xmin)
    .. string.format("label[2.4,0;%s] field[3.8,0;1.25,1;xmax;;%s]", S("x Max:"), p.xmax)
    .. string.format("label[4.9,0;%s] field[6.9,0;1.35,1;e1;;%s]", S("+x Direction:"), p.e1)
    .. "list[detached:mathplot:inv_brush_" .. playername .. ";xaxisbrush;8,-0.35;1,1;]"
    .. string.format("label[0,1;%s] field[1.4,1;1.25,1;ymin;;%s]", S("y Min:"), p.ymin)
    .. string.format("label[2.4,1;%s] field[3.8,1;1.25,1;ymax;;%s]", S("y Max:"), p.ymax)
    .. string.format("label[4.9,1;%s] field[6.9,1;1.35,1;e2;;%s]", S("+y Direction:"), p.e2)
    .. "list[detached:mathplot:inv_brush_" .. playername .. ";yaxisbrush;8,0.65;1,1;]"
    .. string.format("label[0,2;%s] field[1.4,2;1.25,1;zmin;;%s]", S("z Min:"), p.zmin)
    .. string.format("label[2.4,2;%s] field[3.8,2;1.25,1;zmax;;%s]", S("z Max:"), p.zmax)
    .. string.format("label[4.9,2;%s] field[6.9,2;1.35,1;e3;;%s]", S("+z Direction:"), p.e3)
    .. "list[detached:mathplot:inv_brush_" .. playername .. ";zaxisbrush;8,1.65;1,1;]"
    .. "container_end[]"
    --Player inventory and trash
    .. "container[0,4]"
    .. "list[current_player;main;0,0;8,4;]"
    .. "image[8.06,0.1;0.8,0.8;creative_trash_icon.png]"
    .. "list[detached:mathplot:inv_trash;main;8,0;1,1;]"
    .. "container_end[]"
    .. string.format("button_exit[0,8;2,1;btn_draw;%s]", S("Plot"))
    .. string.format("button_exit[2,8;2,1;btn_cancel;%s]", S("Cancel"))
    return formspec
end


local function draw_axes_on_receive_fields(playername, identifier, fields, context)
    if fields.btn_draw or fields.key_enter then
        local brushNodenames = mathplot.gui.get_brushes(
            playername,
            { "xaxisbrush", "yaxisbrush", "zaxisbrush" })

        local newfields = mathplot.util.merge_tables(
            mathplot.plotdefaults.axis_params(),
            fields,
            brushNodenames
        )

        mathplot.gui.validate_screen_form(
            playername, identifier, newfields, context, {
                validator_function = parse_and_validate,
                success_callback = function(playername, identifier, validated_params, context)
                    local nodemeta = minetest.get_meta(context.node_pos)
                    nodemeta:set_string("axis_params", minetest.serialize(validated_params))

                    local errorMsg = ""

                    local plotParams = mathplot.plotdefaults.plot_parametric_curve_params()
                    plotParams.origin_pos = context.node_pos
                    plotParams.ustep = 1
                    plotParams.e1 = validated_params.e1
                    plotParams.e2 = validated_params.e2
                    plotParams.e3 = validated_params.e3

                    --x-axis
                    plotParams.ftn_x = "u"; plotParams.ftn_y = "0"; plotParams.ftn_z = "0"
                    plotParams.umin = validated_params.xmin
                    plotParams.umax = validated_params.xmax
                    plotParams.nodename = validated_params.xaxisbrush
                    local ok, err = mathplot.plot_parametric(plotParams, playername)
                    if not ok then
                        errorMsg = err
                    end

                    --y-axis
                    plotParams.ftn_x = "0"; plotParams.ftn_y = "u"; plotParams.ftn_z = "0"
                    plotParams.umin = validated_params.ymin
                    plotParams.umax = validated_params.ymax
                    plotParams.nodename = validated_params.yaxisbrush
                    mathplot.plot_parametric(plotParams, playername)
                    local ok, err = mathplot.plot_parametric(plotParams, playername)
                    if not ok then
                        errorMsg = err
                    end

                    --z-axis
                    plotParams.ftn_x = "0"; plotParams.ftn_y = "0"; plotParams.ftn_z = "u"
                    plotParams.umin = validated_params.zmin
                    plotParams.umax = validated_params.zmax
                    plotParams.nodename = validated_params.zaxisbrush
                    mathplot.plot_parametric(plotParams, playername)
                    local ok, err = mathplot.plot_parametric(plotParams, playername)
                    if not ok then
                        errorMsg = err
                    end

                    if #errorMsg > 0 then
                        return false, errorMsg
                    end
                    return true, S("Axes drawn.")
                end
            })
    end
end

mathplot.gui.screens["draw_axes"] = {
    initialize = draw_axes_initialize,
    get_formspec = draw_axes_get_formspec,
    on_receive_fields = draw_axes_on_receive_fields
}
