mathplot = mathplot or {}

minetest.register_node("mathplot:origin", {
        description = "MathPlot Origin Node",
        groups = {cracky = 1},
        paramtype = "light",
        light_source = 6,
        tiles = {"^[colorize:#00FF00"},
        on_construct = function(pos)
            --add to mod storage
            local name = "Untitled Node"  --TODO: need some kind of uniqueness here... or change nodes to be stored by location instead of by name (probably better)
            mathplot.store_origin_location(name, pos)
        end,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            local context = {
                node_pos = pos
            }
            mathplot.gui.invoke_screen("originmainmenu", player:get_player_name(), context)
        end,
        after_destruct = function(pos, oldnode)
            --remove from mod storage
            mathplot.remove_origin_location(pos)
        end
    })

