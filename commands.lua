mathplot = mathplot or {}

minetest.register_privilege("mathplot", {
        description = "Can use mathplot functions",
        give_to_singleplayer = true
    })


local function do_mathplot_menu(playername, param)
    local context = {}
    mathplot.gui.invoke_screen("mainmenu", playername, context)
    return true, nil
end


local function do_mathplot_clearlist(playername, param)
    mathplot.clear_origin_locations()
    return true, "Origin locations list cleared."
end


local function do_mathplot_timeout(playername, param)
    param = string.trim(param)
    if #param == 0 then
        --Echo the current setting.
        if mathplot.settings.plot_timeout == 0 then
            return true, "Plot timeout is currently disabled."
        else
            return true, string.format("Plot timeout is currently set to %s seconds.", mathplot.settings.plot_timeout / 1e6)
        end
    else
        --Change setting if valid parameter provided.
        local seconds = tonumber(param)
        if not seconds then
            return false, "Invalid timeout specified: " .. param
        elseif seconds < 0 then
            return false, "Timeout must be zero or greater."
        else
            mathplot.settings.plot_timeout = seconds * 1e6
            if mathplot.settings.plot_timeout == 0 then
                return true, "Plot timeout disabled."
            else
                return true, string.format("Plot timeout set to %s seconds.", mathplot.settings.plot_timeout)
            end
        end
    end
end


local function do_mathplot_max_coord(playername, param)
    param = string.trim(param)
    if #param == 0 then
        --Echo the current setting.
        return true, string.format("Maximum coordinate magnitude is set to %s.", mathplot.settings.max_coord)
    else
        --Change setting if valid parameter provided.
        local max_coord = tonumber(param)
        if not max_coord then
            return false, "Invalid maximum coordinate magnitude specified: " .. param
        elseif max_coord < 0 then
            return false, "Maximum coordinate magnitude must be zero or greater."
        else
            mathplot.settings.max_coord = max_coord
            return true, string.format("Maximum coordinate magnitude set to %s.", mathplot.settings.max_coord)
        end
    end
end


local function do_mathplot_open(playername, param)
    param = string.trim(param)

    local l = nil
    local pos = minetest.string_to_pos(param)
    if pos ~= nil then
        l = mathplot.get_origin_location_by_pos(pos)
    else
        locs = mathplot.get_origin_locations_by_name(param)
        if #locs > 0 then
            l = locs[1]
        end
    end

    if l ~= nil then
        local context = { node_pos = l.pos }
        mathplot.gui.invoke_screen("originmainmenu", playername, context)
        return true, nil
    end
    return false, string.format("Unknown origin node '%s'.", param)
end


local subcommand_map = {
    menu = do_mathplot_menu,
    clearlist = do_mathplot_clearlist,
    timeout = do_mathplot_timeout,
    max_coord = do_mathplot_max_coord,
    open = do_mathplot_open
}

local function do_mathplot(playername, param)
    local subcommand, arg = string.match(param, "^%s*([%a%d_-]+)(.*)$")
    if subcommand == nil then
        subcommand = "menu"
    end
    if arg == nil then
        arg = ""
    end
    arg = string.trim(arg)

    local f = subcommand_map[subcommand]
    if f then
        return f(playername, arg)
    else
        return false, "Invalid mathplot subcommand: " .. subcommand
    end
end


minetest.register_chatcommand("mathplot", {
        privs = { mathplot = true },
        func = do_mathplot,
        description = "Perform mathplot functions"
    })
