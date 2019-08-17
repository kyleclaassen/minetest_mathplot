mathplot.gui.screens = mathplot.gui.screens or {}

local function validate_parametric(playername, identifier, fields, context)
    local e = {}  --list of error messages
    local p = table.copy(fields)

    minetest.log("In validate_parametric()... fields=" .. dump(p))

    if minetest.string_to_pos(p.e1) == nil then
        e[#e+1] = "Invalid +X Direction"
    end
    if minetest.string_to_pos(p.e2) == nil then
        e[#e+1] = "Invalid +Y Direction"
    end
    if minetest.string_to_pos(p.e3) == nil then
        e[#e+1] = "Invalid +Z Direction"
    end

    local varname1 = p.varnames[1]
    local varname2 = p.varnames[2]
    local varname3 = p.varnames[3]
    local varnamesStr = mathplot.parametric_argstr_display(p.varnames)

    --Load ftn code string to check for syntax error
    local syntaxerror = mathplot.check_function_syntax(p.umin, {}, {})
    if syntaxerror ~= nil then
        e[#e+1] = "qqSyntax error in umin: " .. syntaxerror
    end
    syntaxerror = mathplot.check_function_syntax(p.umax, {}, {})
    if syntaxerror ~= nil then
        e[#e+1] = "qqSyntax error in umax: " .. syntaxerror
    end
    syntaxerror = mathplot.check_function_syntax(p.ustep, {}, {})
    if syntaxerror ~= nil then
        e[#e+1] = "qqSyntax error in ustep: " .. syntaxerror
    end
    
    syntaxerror = mathplot.check_function_syntax(p.vmin, {p.varnames[1]}, {0})
    if syntaxerror ~= nil then
        e[#e+1] = "qqSyntax error in vmin: " .. syntaxerror
    end
    syntaxerror = mathplot.check_function_syntax(p.vmax, {p.varnames[1]}, {0})
    if syntaxerror ~= nil then
        e[#e+1] = "qqSyntax error in vmax: " .. syntaxerror
    end
    syntaxerror = mathplot.check_function_syntax(p.vstep, {p.varnames[1]}, {0})
    if syntaxerror ~= nil then
        e[#e+1] = "qqSyntax error in vstep: " .. syntaxerror
    end

    syntaxerror = mathplot.check_function_syntax(p.wmin, {p.varnames[1], p.varnames[2]}, {0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = "qqSyntax error in wmin: " .. syntaxerror
    end
    syntaxerror = mathplot.check_function_syntax(p.wmax, {p.varnames[1], p.varnames[2]}, {0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = "qqSyntax error in wmax: " .. syntaxerror
    end
    syntaxerror = mathplot.check_function_syntax(p.wstep, {p.varnames[1], p.varnames[2]}, {0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = "qqSyntax error in wstep: " .. syntaxerror
    end

    syntaxerror = mathplot.check_function_syntax(p.ftn_x, p.varnames, {0, 0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = "Syntax error in X(" .. varnamesStr .. "): " .. syntaxerror
    end
    syntaxerror = mathplot.check_function_syntax(p.ftn_y, p.varnames, {0, 0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = "Syntax error in Y(" .. varnamesStr .. "): " .. syntaxerror
    end
    syntaxerror = mathplot.check_function_syntax(p.ftn_z, p.varnames, {0, 0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = "Syntax error in Z(" .. varnamesStr .. "): " .. syntaxerror
    end

    if #e == 0 then
        return p, e
    end
    --If errors, return original values
    return fields, e
end

local function title_container(title)
    return {
        height = 1,
        formspec = string.format("label[0,0;%s]", title)
    }
end
local function direction_container(e1, e2, e3)
    return {
        height = 1,
        formspec = string.format("label[0,0;+X Direction:]field[2,0;2,1;e1;;%s]", e1)
        .. string.format("label[4,0;+Y Direction:]field[6,0;2,1;e2;;%s]", e2)
        .. string.format("label[8,0;+Z Direction:]field[10,0;2,1;e3;;%s]", e3)
    }
end
local function min_max_step_container(varname, umin, umax, ustep)
    return {
        height = 1,
        formspec = string.format("label[0,0;%s Min:]field[2,0;2,1;%smin;;%s]", varname, varname, umin)
        .. string.format("label[4,0;%s Max:]field[6,0;2,1;%smax;;%s]", varname, varname, umax)
        .. string.format("label[8,0;%s Step:]field[10,0;2,1;%sstep;;%s]", varname, varname, ustep)
    }
end
local function ftn_container(varnames, ftn_x, ftn_y, ftn_z)
    local varstr = table.concat(varnames, ",")
    return {
        height = 3,
        formspec = string.format("label[0,0;X(%s) = ]field[2,0;10,1;ftn_x;;%s]", varstr, ftn_x)
        .. string.format("label[0,1;Y(%s) = ]field[2,1;10,1;ftn_y;;%s]", varstr, ftn_y)
        .. string.format("label[0,2;Z(%s) = ]field[2,2;10,1;ftn_z;;%s]", varstr, ftn_z)
    }
end
local function inventory_container(playername, identifier)
    local btn_to_name1 = nil
    local btn_to_label1 = nil
    local btn_to_name2 = nil
    local btn_to_label2 = nil
    if identifier == "parametric_curve" then
        btn_to_name1, btn_to_label1 = "btn_to_surface", "To Surface"
        btn_to_name2, btn_to_label2 = "btn_to_solid", "To Solid"
    elseif identifier == "parametric_surface" then
        btn_to_name1, btn_to_label1 = "btn_to_curve", "To Curve"
        btn_to_name2, btn_to_label2 = "btn_to_solid", "To Solid"
    elseif identifier == "parametric_solid" then
        btn_to_name1, btn_to_label1 = "btn_to_curve", "To Curve"
        btn_to_name2, btn_to_label2 = "btn_to_surface", "To Surface" 
    end
    return {
        height = 4,
        formspec = "list[current_player;main;0,0;8,4;]"
        .. "label[8.25,0.25;Plot node:]"
        .. "list[detached:mathplot:inv_brush_" .. playername .. ";brush;9.75,0;1,1;]"
        .. "image[10.81,0.1;0.8,0.8;creative_trash_icon.png]"
        .. "list[detached:mathplot:inv_trash;main;10.75,0;1,1;]"
        .. string.format("button_exit[8.25,3;2,1;%s;%s]", btn_to_name1, btn_to_label1)
        .. string.format("button_exit[10.1,3;2,1;%s;%s]", btn_to_name2, btn_to_label2)
    }
end
local function plot_cancel_container()
    return {
        height = 1,
        formspec = "button_exit[0,0;2,1;btn_plot;Plot]"
        .. "button_exit[2,0;2,1;btn_cancel;Cancel]"
    }
end


local function concat_containers(...)
    local y = 0
    local formspec = ""
    for _, c in ipairs({...}) do
        formspec = formspec
        .. string.format("container[0,%f]", y)
        .. c.formspec
        .. "container_end[]\n"
        y = y + c.height
    end
    return y, formspec
end


local function default_params(identifier)
    if identifier == "parametric_curve" then
        return mathplot.plotdefaults.plot_parametric_curve_params()
    elseif identifier == "parametric_surface" then
        return mathplot.plotdefaults.plot_parametric_surface_params()
    elseif identifier == "parametric_solid" then
        return mathplot.plotdefaults.plot_parametric_solid_params()
    end
    minetest.log("Error: mathplot: invalid parametric identifier")
    return nil
end


local parametric_screen = {
    initialize = function(playername, identifier, context)
        --If context.action_params is already in context, then show those values.
        --(Likely coming back from a validation error.)
        if not context.action_params then
            local defaults = default_params(identifier)
            local meta = minetest.get_meta(context.node_pos)
            local s = meta:get_string(identifier .. "_params")
            context.action_params = mathplot.util.merge_tables(
                defaults,
                minetest.deserialize(s) or {}
            )
        end
        return context
    end,
    get_formspec = function(playername, identifier, context)
        local p = context.action_params
        local nodepos = context.node_pos

        mathplot.gui.set_brushes(playername, {brush = p.nodename})

        local formspec = ""
        local totalHeight = 0
        if identifier == "parametric_curve" then
            totalHeight, formspec = concat_containers(
                title_container("Parametric Curve"),
                direction_container(p.e1, p.e2, p.e3),
                min_max_step_container("u", p.umin, p.umax, p.ustep),
                ftn_container({"u"}, p.ftn_x, p.ftn_y, p.ftn_z),
                inventory_container(playername, identifier),
                plot_cancel_container()
            )
        elseif identifier == "parametric_surface" then
            totalHeight, formspec = concat_containers(
                title_container("Parametric Surface"),
                direction_container(p.e1, p.e2, p.e3),
                min_max_step_container("u", p.umin, p.umax, p.ustep),
                min_max_step_container("v", p.vmin, p.vmax, p.vstep),
                ftn_container({"u", "v"}, p.ftn_x, p.ftn_y, p.ftn_z),
                inventory_container(playername, identifier),
                plot_cancel_container()
            )
        elseif identifier == "parametric_solid" then
            totalHeight, formspec = concat_containers(
                title_container("Parametric Solid"),
                direction_container(p.e1, p.e2, p.e3),
                min_max_step_container("u", p.umin, p.umax, p.ustep),
                min_max_step_container("v", p.vmin, p.vmax, p.vstep),
                min_max_step_container("w", p.wmin, p.wmax, p.wstep),
                ftn_container({"u", "v", "w"}, p.ftn_x, p.ftn_y, p.ftn_z),
                inventory_container(playername, identifier),
                plot_cancel_container()
            )
        end

        formspec = string.format("size[12,%f]", totalHeight-0.5) .. formspec
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        if fields.btn_plot or fields.key_enter then
            local nodename = mathplot.gui.get_brushes(playername, { "brush" })["brush"]
            local newfields = mathplot.util.merge_tables(
                default_params(identifier),
                fields,
                { origin_pos = context.node_pos, nodename = nodename }
            )

            mathplot.gui.validate_screen_form(playername, identifier, newfields, context, {
                    validator_function = validate_parametric,
                    success_callback = function(playername, identifier, validated_params, context)
                        local nodemeta = minetest.get_meta(validated_params.origin_pos)
                        nodemeta:set_string(identifier .. "_params", minetest.serialize(validated_params))
                        return mathplot.plot_parametric(validated_params)
                    end
                })
        elseif fields.btn_to_curve or fields.btn_to_surface or fields.btn_to_solid then
            local screenIdentifier = fields.btn_to_curve and "parametric_curve" or fields.btn_to_surface and "parametric_surface" or fields.btn_to_solid and "parametric_solid" or nil
            local nodename = mathplot.gui.get_brushes(playername, { "brush" })["brush"]
            local newfields = mathplot.util.merge_tables(
                default_params(screenIdentifier),
                fields,
                { origin_pos = context.node_pos, nodename = nodename }
            )
            context.action_params = newfields
            mathplot.gui.invoke_screen(screenIdentifier, playername, context)
        end
    end
}


mathplot.gui.screens["parametric_curve"] = parametric_screen;
mathplot.gui.screens["parametric_surface"] = parametric_screen;
mathplot.gui.screens["parametric_solid"] = parametric_screen;
