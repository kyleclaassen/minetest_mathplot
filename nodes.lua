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
            else
                minetest.chat_send_player(digger:get_player_name(), "Use the \"mathplot:destroyer\" tool to dig this node.")
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


--#############################################
--############## Colorful Nodes ###############
--#############################################


local alpha = "8F"

--mimic the wool colors.
local colors = {
    black = "000000",
    blue = "0000ff",
    brown = "492300",
    cyan = "00FFFF",
    dark_green = "2a7a00",
    dark_grey = "323232",
    green = "00FF00",
    grey = "8b8b8b",
    magenta = "e0048b",
    orange = "ff6600",
    pink = "ff6d6d",
    red = "ff0000",
    violet = "8a00ff",
    white = "ffffff",
    yellow = "ffff00"
}

for colorName, colorVal in pairs(colors) do
    minetest.register_node("mathplot:translucent_" .. colorName, {
            description = "mathplot " .. colorName .. " translucent glow block",
            groups = {cracky = 1},
            paramtype = "light",
            light_source = 11,
            use_texture_alpha = true,
            tiles = { "mathplot_translucent_mesh.png^[colorize:#" .. colorVal .. alpha }
        })

    --Make "glow wool" by tweaking standard wool nodes
    local woolNode = table.copy(minetest.registered_nodes["wool:" .. colorName])
    woolNode.paramtype = "light"
    woolNode.light_source = 11
    minetest.register_node("mathplot:glow_wool_" .. colorName, woolNode)
end
