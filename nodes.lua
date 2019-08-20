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


--mimic the wool colors.
--Not too bright: want to see a little bit of shadow at night
local colors = {
    black = { val = "000000", light = 7 },
    blue = { val = "0000ff", light = 7 },
    brown = { val = "492300", light = 7 },
    cyan = { val = "00ffff", light = 7 },
    dark_green = { val = "2a7a00", light = 7 },
    dark_grey = { val = "323232", light = 7 },
    green = { val = "00ff00", light = 7 },
    grey = { val = "8b8b8b", light = 7 },
    magenta = { val = "e0048b", light = 7 },
    orange = { val = "ff6600", light = 7 },
    pink = { val = "ff6d6d", light = 7 },
    red = { val = "ff0000", light = 7 },
    violet = { val = "8a00ff", light = 7 },
    white = { val = "ffffff", light = 7 },
    yellow = { val = "ffff00", light = 7 }
}
local alpha = "8f"

for colorName, c in pairs(colors) do
    --Translucent nodes
    minetest.register_node("mathplot:translucent_" .. colorName, {
            description = "mathplot " .. colorName .. " translucent glow block",
            groups = {cracky = 1},
            paramtype = "light",
            light_source = 11,
            use_texture_alpha = true,
            tiles = { "mathplot_translucent_grid_16x16.png^[colorize:#" .. c.val .. alpha }
        })

    --Make "glow wool" by tweaking standard wool nodes
    local woolNode = table.copy(minetest.registered_nodes["wool:" .. colorName])
    woolNode.paramtype = "light"
    woolNode.light_source = c.light
    woolNode.description = "mathplot Glowing " .. woolNode.description
    minetest.register_node("mathplot:glow_wool_" .. colorName, woolNode)

    --Make "glow glass" by tweaking the standard glass node
    local glassNode = table.copy(minetest.registered_nodes["default:glass"])
    glassNode.description = "mathplot Glowing " .. colorName .. " Glass"
    glassNode.paramtype = "light"
    glassNode.light_source = c.light
    for i = 1, #glassNode.tiles do
        glassNode.tiles[i] = glassNode.tiles[i] .. "^[colorize:#" .. c.val
    end
    minetest.register_node("mathplot:glow_glass_" .. colorName, glassNode)
end
