mathplot = mathplot or {}

local S = mathplot.get_translator

minetest.register_privilege("mathplot", {
        description = S("Can use MathPlot functionality"),
        give_to_singleplayer = true
    })


local function do_mathplot_menu(playername, param)
    local context = {}
    mathplot.gui.invoke_screen("originlist", playername, context)
    return true, nil
end


local function do_mathplot_clearlist(playername, param)
    if not mathplot.util.has_server_priv(playername) then
        return false, S("The 'server' privilege is required.")
    end
    mathplot.clear_origin_locations()
    return true, S("Origin locations list cleared.")
end


local function do_mathplot_timeout(playername, param)
    param = string.trim(param)
    if #param == 0 then
        --Echo the current setting.
        if mathplot.settings.plot_timeout == 0 then
            return true, S("Plot timeout is currently disabled.")
        else
            return true, S("Plot timeout is currently set to @1 seconds.", mathplot.settings.plot_timeout / 1e6)
        end
    else
        if not mathplot.util.has_server_priv(playername) then
            return false, S("The 'server' privilege is required.")
        end

        --Change setting if valid parameter provided.
        local seconds = tonumber(param)
        if not seconds then
            return false, S("Invalid timeout specified: @1", param)
        elseif seconds < 0 then
            return false, S("Timeout must be zero or greater.")
        else
            mathplot.settings.plot_timeout = seconds * 1e6
            if mathplot.settings.plot_timeout == 0 then
                return true, S("Plot timeout disabled.")
            else
                return true, S("Plot timeout set to @1 seconds.", seconds)
            end
        end
    end
end


local function do_mathplot_max_coord(playername, param)
    param = string.trim(param)
    if #param == 0 then
        --Echo the current setting.
        return true, S("Maximum coordinate magnitude is currently set to @1.", mathplot.settings.max_coord)
    else
        if not mathplot.util.has_server_priv(playername) then
            return false, S("The 'server' privilege is required.")
        end

        --Change setting if valid parameter provided.
        local max_coord = tonumber(param)
        if not max_coord then
            return false, S("Invalid maximum coordinate magnitude specified: @1", param)
        elseif max_coord < 0 then
            return false, S("Maximum coordinate magnitude must be zero or greater.")
        else
            mathplot.settings.max_coord = max_coord
            return true, S("Maximum coordinate magnitude set to @1.", mathplot.settings.max_coord)
        end
    end
end


local function do_mathplot_respect_protected_areas(playername, param, action)
    param = string.trim(param)
    if #param == 0 then
        --Echo the current setting.
        return true, S("Respect protected areas is currently set to @1.", tostring(mathplot.settings.respect_protected_areas))
    else
        if not mathplot.util.has_server_priv(playername) then
            return false, S("The 'server' privilege is required.")
        end

        --Change setting if valid parameter provided.
        local respect = mathplot.util.toboolean(param)
        if respect == nil then
            return false, S("Invalid boolean specified: @1", param)
        else
            mathplot.settings.respect_protected_areas = respect
            return true, S("Respect protected areas set to @1.", tostring(mathplot.settings.respect_protected_areas))
        end
    end
end

local function do_mathplot_open(playername, param, action)
    param = string.trim(param)

    local l = nil
    local pos = minetest.string_to_pos(param)
    if pos ~= nil then
        l = mathplot.get_origin_location_by_pos(pos)
    else
        local locs = mathplot.get_origin_locations_by_name(param)
        if #locs > 0 then
            l = locs[1]
        end
    end

    if l ~= nil then
        if action == "open" then
            local context = { node_pos = l.pos }
            mathplot.gui.invoke_screen("originmainmenu", playername, context)
            return true, nil
        elseif action == "teleport" then
            local canTeleport = minetest.get_player_privs(playername).teleport
            if canTeleport then
                minetest.log(S("mathplot: player @1 teleporting to @2", playername, minetest.pos_to_string(l.pos)))
                local player = minetest.get_player_by_name(playername)
                if player then
                    player:set_pos(l.pos)
                end
                return true, nil
            end
            return false, S("The 'teleport' privilege is required.")
        end
    else
        return false, S("Unknown origin node '@1'.", param)
    end
end

local function do_mathplot_setorigin(playername, param)
    local player = minetest.get_player_by_name(playername)
    local pos = player:get_pos()
    local protection_bypass = mathplot.util.has_protection_bypass_priv(playername)
    --Note: ignore the minetest.respect_protected_areas setting here, as this is "equivalent"
    --to the user creating a node through the usual right-click mechanism.
    if protection_bypass or not minetest.is_protected(pos, playername) then
        minetest.set_node(pos, {name=mathplot.ORIGIN_NODE_NAME})
    else
        return false, S("Cannot set origin: area is protected.")
    end
end


local subcommand_map = {
    menu = do_mathplot_menu,
    clearlist = do_mathplot_clearlist,
    timeout = do_mathplot_timeout,
    max_coord = do_mathplot_max_coord,
    respect_protected_areas = do_mathplot_respect_protected_areas,
    open = function(playername, param)
        return do_mathplot_open(playername, param, "open")
    end,
    teleport = function(playername, param)
        return do_mathplot_open(playername, param, "teleport")
    end,
    setorigin = do_mathplot_setorigin
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
        return false, S("Invalid mathplot subcommand: @1", subcommand)
    end
end


minetest.register_chatcommand("mathplot", {
        privs = { mathplot = true },
        func = do_mathplot,
        description = S("Perform MathPlot functions")
    })
