mathplot.gui.screens = mathplot.gui.screens or {}

local relevant_meta_keys = {
    "axis_params",
    "implicit_plot_params",
    "parametric_curve_params",
    "parametric_solid_params",
    "parametric_surface_params",
    "parametric_solid_params"
}

local function serialize_origin_node(pos)
    local meta = minetest.get_meta(pos)
    local meta_table = meta:to_table()
    local d = {}
    for _, key in ipairs(relevant_meta_keys) do
        local t = minetest.deserialize(meta_table.fields[key])
        if t then
            --unset some fields that are unsuitable to be copied to another node.
            t.connect = nil
            t.origin_pos = nil
            t.varnames = nil
            d[key] = t
        end
    end
    return minetest.write_json(d)
end

local function deserialize_origin_node(pos, json)
    local node = minetest.get_node(pos)
    if node and node.name == mathplot.ORIGIN_NODE_NAME then
        local meta = minetest.get_meta(pos)
        local meta_table = meta:to_table()
        local d = minetest.parse_json(json)
        if d then
            for _, key in ipairs(relevant_meta_keys) do
                meta_table.fields[key] = minetest.serialize(d[key])
            end
            meta:from_table(meta_table)
            return true, nil
        else
            return false, "Invalid JSON."
        end
    else
        return false, string.format("Non-mathplot origin node at position %s", minetest.pos_to_string(pos))
    end
end

mathplot.gui.screens["serialize"] = {
    initialize = function(playername, identifier, context)
    end,
    get_formspec = function(playername, identifier, context)
        local json = serialize_origin_node(context.node_pos)
        local escaped_json = minetest.formspec_escape(json)
        if escaped_json == "null" then
            escaped_json = ""
        end
        local formspec = "size[10.25,4.5]"
        .. "label[0,0;Serialized Node:]"
        .. string.format("field[0.25,1;10,1;txt_to_json;;%s]", escaped_json)
        .. "label[0,2;Deserialize from JSON:]"
        .. "field[0.25,3;10,1;txt_from_json;;]"
        .. "button_exit[0,4;2,1;btn_load;Load]"
        .. "button_exit[2,4;2,1;btn_cancel;Cancel]"
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        if fields.btn_load or fields.key_enter then
            if fields.txt_from_json and string.len(string.trim(fields.txt_from_json)) > 0 then
                local ok, msg = deserialize_origin_node(context.node_pos, fields.txt_from_json)
                if ok then
                    minetest.log("mathplot: successfully deserialized json to node.")
                elseif msg then
                    minetest.log("mathplot: failed to deserialize json to node: " .. msg)
                end
            end
        end
    end
}
