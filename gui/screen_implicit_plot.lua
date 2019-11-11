mathplot.gui.screens = mathplot.gui.screens or {}

local function parse_and_validate(playername, identifier, fields, context)
    local e = {}  --list of error messages
    local p = table.copy(fields)

    if minetest.string_to_pos(p.e1) == nil then
        e[#e+1] = "Invalid +X Direction"
    end
    if minetest.string_to_pos(p.e2) == nil then
        e[#e+1] = "Invalid +Y Direction"
    end
    if minetest.string_to_pos(p.e3) == nil then
        e[#e+1] = "Invalid +Z Direction"
    end

    p.xmin = tonumber(p.xmin)
    p.xmax = tonumber(p.xmax)
    p.xstep = tonumber(p.xstep)
    if p.xmin == nil then
        e[#e+1] = "X Min must be a number."
    end
    if p.xmax == nil then
        e[#e+1] = "X Max must be a number."
    end
    if p.xmin ~= nil and p.xmax ~= nil and p.xmin > p.xmax then
        e[#e+1] = "X Min must be <= X Max."
    end
    if p.xstep == nil then
        e[#e+1] = "X Step must be a number."
    end
    if p.xstep ~= nil and p.xstep <= 0 then
        e[#e+1] = "X Step must be positive."
    end

    p.ymin = tonumber(p.ymin)
    p.ymax = tonumber(p.ymax)
    p.ystep = tonumber(p.ystep)
    if p.ymin == nil then
        e[#e+1] = "Y Min must be a number."
    end
    if p.ymax == nil then
        e[#e+1] = "Y Max must be a number."
    end
    if p.ymin ~= nil and p.ymax ~= nil and p.ymin > p.ymax then
        e[#e+1] = "Y Min must be <= Y Max."
    end
    if p.ystep == nil then
        e[#e+1] = "Y Step must be a number."
    end
    if p.ystep ~= nil and p.ystep <= 0 then
        e[#e+1] = "Y Step must be positive."
    end

    p.zmin = tonumber(p.zmin)
    p.zmax = tonumber(p.zmax)
    p.zstep = tonumber(p.zstep)
    if p.zmin == nil then
        e[#e+1] = "Z Min must be a number."
    end
    if p.zmax == nil then
        e[#e+1] = "Z Max must be a number."
    end
    if p.zmin ~= nil and p.zmax ~= nil and p.zmin > p.zmax then
        e[#e+1] = "Z Min must be <= Z Max."
    end
    if p.zstep == nil then
        e[#e+1] = "Z Step must be a number."
    end
    if p.zstep ~= nil and p.zstep <= 0 then
        e[#e+1] = "Z Step must be positive."
    end

    --Load ftn code string to check for syntax error
    local syntaxerror = mathplot.check_function_syntax(p.ftn, p.varnames, {0, 0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = "Syntax error in condition: " .. syntaxerror
    end

    if not mathplot.is_drawable_node(fields.nodename) then
        e[#e+1] = string.format("'%s' is not a drawable node.", fields.nodename or "")
    end

    if #e == 0 then
        return p, e
    end
    --If errors, return original values
    return fields, e
end


local function load_saved_params(context)
    local meta = minetest.get_meta(context.node_pos)
    local s = meta:get_string("implicit_plot_params")
    return mathplot.util.merge_tables(
        mathplot.plotdefaults.plot_implicit_params(),
        minetest.deserialize(s) or {}
    )
end
local function have_saved_params(context, identifier)
    local meta = minetest.get_meta(context.node_pos)
    local s = meta:get_string("implicit_plot_params")
    return s ~= nil and string.trim(s) ~= ""
end

mathplot.gui.screens["implicit_plot"] = {
    initialize = function(playername, identifier, context)
        --If context.screen_params is already in context, then show those values.
        --(Likely coming back from a validation error.)
        if not context.screen_params then
            context.screen_params = load_saved_params(context)
        end
        return context
    end,
    get_formspec = function(playername, identifier, context)
        local p = context.screen_params
        local nodepos = context.node_pos

        mathplot.gui.set_brushes(playername, {brush = p.nodename})

        local allowErase = have_saved_params(context, identifier)

        local formspec = "size[12,10.5]"
        .. "label[0,0;Implicit Plot]"
        .. "container[0,1]"
        .. string.format("label[0,0;+X Direction:]field[2,0;2,1;e1;;%s]", p.e1)
        .. string.format("label[4,0;+Y Direction:]field[6,0;2,1;e2;;%s]", p.e2)
        .. string.format("label[8,0;+Z Direction:]field[10,0;2,1;e3;;%s]", p.e3)
        .. string.format("label[0,1;X Min:]field[2,1;2,1;xmin;;%s]", p.xmin)
        .. string.format("label[4,1;X Max:]field[6,1;2,1;xmax;;%s]", p.xmax)
        .. string.format("label[8,1;X Step:]field[10,1;2,1;xstep;;%s]", p.xstep)
        .. string.format("label[0,2;Y Min:]field[2,2;2,1;ymin;;%s]", p.ymin)
        .. string.format("label[4,2;Y Max:]field[6,2;2,1;ymax;;%s]", p.ymax)
        .. string.format("label[8,2;Y Step:]field[10,2;2,1;ystep;;%s]", p.ystep)
        .. string.format("label[0,3;Z Min:]field[2,3;2,1;zmin;;%s]", p.zmin)
        .. string.format("label[4,3;Z Max:]field[6,3;2,1--1;zmax;;%s]", p.zmax)
        .. string.format("label[8,3;Z Step:]field[10,3;2,1;zstep;;%s]", p.zstep)
        .. string.format("label[0,4;Condition:]field[2,4;10,1;ftn;;%s]", p.ftn)
        .. "container_end[]"
        .. "container[0,6]"
        .. "list[current_player;main;0,0;8,4;]"
        .. "label[8.25,0.25;Plot node:]"
        .. "list[detached:mathplot:inv_brush_" .. playername .. ";brush;9.75,0;1,1;]"
        .. "image[10.81,0.1;0.8,0.8;creative_trash_icon.png]"
        .. "list[detached:mathplot:inv_trash;main;10.75,0;1,1;]"
        .. "container_end[]"
        .. "button_exit[0,10;2,1;btn_plot;Plot]"
        .. "button_exit[2,10;2,1;btn_cancel;Cancel]"
        .. (allowErase and "button_exit[9,10;3,1;btn_erase;Erase Previous]" or "")
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        if fields.btn_plot or fields.key_enter or fields.btn_erase then
            local nodename = ""
            local newfields = nil
            if fields.btn_erase then
                newfields = load_saved_params(context)
                newfields.nodename = "air"
                context.is_erase = true
            else
                nodename = mathplot.gui.get_brushes(playername, { "brush" })["brush"]
                newfields = mathplot.util.merge_tables(
                    mathplot.plotdefaults.plot_implicit_params(),
                    fields,
                    { origin_pos = context.node_pos, nodename = nodename }
                )
            end

            mathplot.gui.validate_screen_form(playername, identifier, newfields, context,
                {
                    validator_function = parse_and_validate,
                    success_callback = function(playername, identifier, validated_params, context)
                        if not context.is_erase then
                            local nodemeta = minetest.get_meta(validated_params.origin_pos)
                            nodemeta:set_string("implicit_plot_params", minetest.serialize(validated_params))
                        end

                        return mathplot.plot_implicit(validated_params)
                    end,
                    -- failure_callback = function(errormsgs, playername, identifier, fields, context)
                    --     return true, errormsgs
                    -- end
                })
        end
    end
}
