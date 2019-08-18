mathplot.gui.screens = mathplot.gui.screens or {}

mathplot.gui.screens["validation_errors"] = {
    initialize = function(playername, identifier, context)
    end,
    get_formspec = function(playername, identifier, context)
        local errorsStr = minetest.formspec_escape(table.concat(context.errormsgs, "\n"))
        local formspec = "size[5.5,6]"
        .. "label[0,0;Errors:]"
        .. "textarea[0.25,0.5;5.75,5.5;;;" .. errorsStr .. "]"
        .. "button_exit[0,5.5;2,1;btn_ok;OK]"
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        --Avoid events like clicking a textlist to trigger the form being done.
        local done = fields.quit == "true"
        return done
    end
}
