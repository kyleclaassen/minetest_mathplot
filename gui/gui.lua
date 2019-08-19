mathplot = mathplot or {}
mathplot.gui = {}

local _formcontext = {}

-- Create the trash field
local trashinv = minetest.create_detached_inventory(
    "mathplot:inv_trash", {
        allow_put = function(inv, listname, index, stack, player)
            return stack:get_count()
        end,
        on_put = function(inv, listname)
            inv:set_list(listname, {})
        end
    })
trashinv:set_size("main", 1)


local make_brush_inv = function(playername)
    local brushinv = minetest.create_detached_inventory(
        "mathplot:inv_brush_" .. playername, {
            allow_put = function(inv, listname, index, stack, player)
                local newStack = ItemStack({name=stack:get_name(), count=1, wear=0, metadata=""})
                inv:set_stack(listname, index, newStack)
                return 0 --don't actually take from the player inventory
            end
        })
    brushinv:set_size("brush", 1)
    brushinv:set_size("xaxisbrush", 1)
    brushinv:set_size("yaxisbrush", 1)
    brushinv:set_size("zaxisbrush", 1)
end

minetest.register_on_joinplayer(
    function(player)
        make_brush_inv(player:get_player_name())
    end)
minetest.register_on_leaveplayer(
    function(player)
        minetest.remove_detached_inventory("mathplot:inv_brush_" .. player:get_player_name())
    end)


mathplot.gui.set_brushes = function(playername, params)
    -- params is table of "listname" = "nodename",
    -- e.g. { xaxisbrush = "wool:red", yaxisbrush = wool:green" }
    local brushinv = minetest.get_inventory({type="detached", name="mathplot:inv_brush_" .. playername})
    for listname, nodename in pairs(params) do
        brushinv:set_stack(listname, 1, nodename)
    end
end

mathplot.gui.get_brushes = function(playername, listnames)
    local brushinv = minetest.get_inventory({type="detached", name="mathplot:inv_brush_" .. playername})
    local nodenames = {}
    for _, listname in ipairs(listnames) do
        local stack = brushinv:get_stack(listname, 1)
        local nodename = stack:get_name() ~= "" and stack:get_name() or "air"
        nodenames[listname] = nodename
    end
    return nodenames
end


local function show_form(playername, formname, formspec, context)
    _formcontext[playername] = context
    --Using minetest.after() here seems to reduce the issue with the new
    --form not appearing after a button press.
    minetest.after(0.05, minetest.show_formspec, playername, formname, formspec)
    --THIS DOESN'T WORK SOMETIMES: minetest.show_formspec(playername, formname, formspec)
end

mathplot.gui.invoke_screen = function(identifier, playername, context)
    local screen = mathplot.gui.screens[identifier]
    if screen then
        local updatedContext = screen.initialize(playername, identifier, context)
        if updatedContext == nil then
            updatedContext = context
        end
        local formspec = screen.get_formspec(playername, identifier, updatedContext)
        local formname = "mathplot:form_" .. identifier
        show_form(playername, formname, formspec, updatedContext)
    end
end

mathplot.gui.validate_screen_form = function(playername, identifier, fields, context, functions)
    local fields, errormsgs = functions.validator_function(playername, identifier, fields, context)
    --Set screen params to current (potentially erroneous) values so they'll
    --show up again after an error screen.
    context.screen_params = fields

    if #errormsgs == 0 then
        local ok = true
        local msg = "Done."
        if functions.success_callback then
            ok, msg = functions.success_callback(playername, identifier, fields, context)
        end

        if ok then
            if msg then
                minetest.chat_send_player(playername, msg)
            end
        else
            local validationContext = {
                errormsgs = { msg },
                action_callback = function()
                    mathplot.gui.invoke_screen(identifier, playername, context)
                end
            }
            mathplot.gui.invoke_screen("validation_errors", playername, validationContext)
        end
    else
        if functions.failure_callback then
            errormsgs = functions.failure_callback(errormsgs, playername, identifier, fields, context)
        end
        if errormsgs ~= nil and #errormsgs > 0 then
            local validationContext = {
                errormsgs = errormsgs,
                action_callback = function()
                    mathplot.gui.invoke_screen(identifier, playername, context)
                end
            }
            mathplot.gui.invoke_screen("validation_errors", playername, validationContext)
        end
    end
end


minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        --minetest.log(formname .. " --> " .. dump(fields))

        local context = _formcontext[player:get_player_name()]
        if not context then
            return
        end

        local identifier = string.gsub(formname, "^mathplot:form_", "")
        local screen = mathplot.gui.screens[identifier]
        if screen then
            local playername = player:get_player_name()
            local done = screen.on_receive_fields(playername, identifier, fields, context)
            if done == nil or done == true then
                if context.action_callback then
                    context.action_callback()
                end
            elseif done == false then
                --not done... reopen the form!
                mathplot.gui.invoke_screen(identifier, playername, context)
            end
        end
    end)
