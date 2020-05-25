mathplot.gui.screens = mathplot.gui.screens or {}

local S = mathplot.get_translator

local function parse_and_validate(playername, identifier, fields, context)
    local e = {}  --list of error messages
    local p = table.copy(fields)

    if not mathplot.util.has_mathplot_priv(playername) then
        e[#e+1] = S("Must have the 'mathplot' privilege in order to use this node.")
    end

    if minetest.string_to_pos(p.e1) == nil then
        e[#e+1] = S("Invalid +@1 Direction.", "X")
    end
    if minetest.string_to_pos(p.e2) == nil then
        e[#e+1] = S("Invalid +@1 Direction.", "Y")
    end
    if minetest.string_to_pos(p.e3) == nil then
        e[#e+1] = S("Invalid +@1 Direction.", "Z")
    end

    p.xmin = tonumber(p.xmin)
    p.xmax = tonumber(p.xmax)
    p.xstep = tonumber(p.xstep)
    if p.xmin == nil then
        e[#e+1] = S("@1 must be a number.", S("X Min"))
    end
    if p.xmax == nil then
        e[#e+1] = S("@1 must be a number.", S("X Max"))
    end
    if p.xmin ~= nil and p.xmax ~= nil and p.xmin > p.xmax then
        e[#e+1] = S("@1 Min must be <= @2 Max.", "X", "X")
    end
    if p.xstep == nil then
        e[#e+1] = S("@1 Step must be a number.", "X")
    end
    if p.xstep ~= nil and p.xstep <= 0 then
        e[#e+1] = S("@1 Step must be positive.", "X")
    end

    p.ymin = tonumber(p.ymin)
    p.ymax = tonumber(p.ymax)
    p.ystep = tonumber(p.ystep)
    if p.ymin == nil then
        e[#e+1] = S("@1 must be a number.", S("Y Min"))
    end
    if p.ymax == nil then
        e[#e+1] = S("@1 must be a number.", S("Y Max"))
    end
    if p.ymin ~= nil and p.ymax ~= nil and p.ymin > p.ymax then
        e[#e+1] = S("@1 Min must be <= @2 Max.", "Y", "Y")
    end
    if p.ystep == nil then
        e[#e+1] = S("@1 Step must be a number.", "Y")
    end
    if p.ystep ~= nil and p.ystep <= 0 then
        e[#e+1] = S("@1 Step must be positive.", "Y")
    end

    p.zmin = tonumber(p.zmin)
    p.zmax = tonumber(p.zmax)
    p.zstep = tonumber(p.zstep)
    if p.zmin == nil then
        e[#e+1] = S("@1 must be a number.", S("Z Min"))
    end
    if p.zmax == nil then
        e[#e+1] = S("@1 must be a number.", S("Z Max"))
    end
    if p.zmin ~= nil and p.zmax ~= nil and p.zmin > p.zmax then
        e[#e+1] = S("@1 Min must be <= @2 Max.", "Z", "Z")
    end
    if p.zstep == nil then
        e[#e+1] = S("@1 Step must be a number.", "Z")
    end
    if p.zstep ~= nil and p.zstep <= 0 then
        e[#e+1] = S("@1 Step must be positive.", "Z")
    end

    --Load ftn code string to check for syntax error
    local syntaxerror = mathplot.check_function_syntax(p.ftn, p.varnames, {0, 0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in condition: @1", syntaxerror)
    end

    if not mathplot.util.is_drawable_node(fields.nodename) then
        e[#e+1] = S("'@1' is not a drawable node.", fields.nodename or "")
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

        local relationTooltipText = S("A function f(x,y,z), e.g. 'x^2 + y^2 + z^2 - 100'. A node will be set at (x,y,z) if f(x,y,z)=0. Can also use inequalities, e.g. 'x^2 + y^2 <= 100'.")

        local formspec = "size[12,10.5]"
        .. string.format("label[0,0;%s]", S("Implicit Plot"))
        .. "container[0,1]"
        .. string.format("label[0,0;%s]field[2,0;2,1;e1;;%s]", S("@1 Direction:", S("+X")), p.e1)
        .. string.format("label[4,0;%s]field[6,0;2,1;e2;;%s]", S("@1 Direction:", S("+Y")), p.e2)
        .. string.format("label[8,0;%s]field[10,0;2,1;e3;;%s]", S("@1 Direction:", S("+Z")), p.e3)
        .. string.format("label[0,1;%s]field[2,1;2,1;xmin;;%s]", S("@1:", S("X Min")), p.xmin)
        .. string.format("label[4,1;%s]field[6,1;2,1;xmax;;%s]", S("@1:", S("X Max")), p.xmax)
        .. string.format("label[8,1;%s]field[10,1;2,1;xstep;;%s]", S("@1:", S("X Step")), p.xstep)
        .. string.format("label[0,2;%s]field[2,2;2,1;ymin;;%s]",  S("@1:", S("Y Min")), p.ymin)
        .. string.format("label[4,2;%s]field[6,2;2,1;ymax;;%s]", S("@1:", S("Y Max")), p.ymax)
        .. string.format("label[8,2;%s]field[10,2;2,1;ystep;;%s]", S("@1:", S("Y Step")), p.ystep)
        .. string.format("label[0,3;%s]field[2,3;2,1;zmin;;%s]", S("@1:", S("Z Min")), p.zmin)
        .. string.format("label[4,3;%s]field[6,3;2,1--1;zmax;;%s]", S("@1:",S("Z Max")), p.zmax)
        .. string.format("label[8,3;%s]field[10,3;2,1;zstep;;%s]", S("@1:",S("Z Step")), p.zstep)
        .. string.format("label[0,4;%s]field[2,4;10,1;ftn;;%s]", S("@1",S("Relation")), p.ftn)
        .. string.format("tooltip[ftn;%s]", minetest.formspec_escape(relationTooltipText))
        .. "container_end[]"
        .. "container[0,6]"
        .. "list[current_player;main;0,0;8,4;]"
        .. string.format("label[8.25,0.25;%s]", S("@1:", S("Plot node")))
        .. "list[detached:mathplot:inv_brush_" .. playername .. ";brush;9.75,0;1,1;]"
        .. "image[10.81,0.1;0.8,0.8;creative_trash_icon.png]"
        .. "list[detached:mathplot:inv_trash;main;10.75,0;1,1;]"
        .. "container_end[]"
        .. string.format("button_exit[0,10;2,1;btn_plot;%s]", S("Plot"))
        .. string.format("button_exit[2,10;2,1;btn_cancel;%s]", S("Cancel"))
        .. (allowErase and string.format("button_exit[9,10;3,1;btn_erase;%s]", S("Erase Previous")) or "")
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

                        return mathplot.plot_implicit(validated_params, playername)
                    end,
                    -- failure_callback = function(errormsgs, playername, identifier, fields, context)
                    --     return true, errormsgs
                    -- end
                })
        end
    end
}
