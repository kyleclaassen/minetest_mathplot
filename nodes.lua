mathplot = mathplot or {}

minetest.register_node("mathplot:origin", {
        description = "MathPlot Origin Node",
        groups = {cracky = 1},
        paramtype = "light",
        light_source = 7,
        --tiles = {"^[colorize:#00FF00"},
        tiles = { "mathplot_origin_node_128x128.png" },
        inventory_image = "mathplot_origin_node_128x128.png",
        on_construct = function(pos)
            --add to mod storage
            local name = "Untitled Node"
            mathplot.store_origin_location(name, pos)
        end,
        is_ground_content = false,
        on_blast = function(pos, intensity) end, --prevent explosions from destroying it
        on_dig = function(pos, node, digger)
            local wieldedItemName = digger:get_wielded_item():get_name()
            if wieldedItemName == "mathplot:destroyer" then
                minetest.node_dig(pos, node, digger)
            end
        end,
        on_punch = function(pos, node, puncher, pointed_thing)
            local wieldedItemName = puncher:get_wielded_item():get_name()
            if wieldedItemName == "mathplot:destroyer" then
                --Default "on_punch" behavior
                minetest.node_punch(pos, node, puncher, pointed_thing)
            else
                --Show menu
                local context = {
                    node_pos = pos
                }
                mathplot.gui.invoke_screen("originmainmenu", puncher:get_player_name(), context)
            end
        end,
        after_destruct = function(pos, oldnode)
            --remove from mod storage
            mathplot.remove_origin_location(pos)
        end
    })

minetest.register_tool("mathplot:destroyer", {
        description = "MathPlot Origin Node Destroyer",
        groups = {},
        inventory_image = "mathplot_tool_destroyer_128x128.png"
    })
