mathplot.gui.screens = mathplot.gui.screens or {}

local S = mathplot.get_translator

local contributors = {
    { name = "Powi", email = "powi@powi.fr", contributions = { S("Implemented internationalization support and provided French translation") } },
}

local aboutStr = [[
%s
https://github.com/kyleclaassen/minetest_mathplot/

%s Kyle Claassen <kyle.m.claassen@gmail.com>

%s

%s
]]

local versionStr = S("MathPlot version @1", mathplot.VERSION)
local contributorsStr = ""
for _, contributor in ipairs(contributors) do
    local allContributions = ""
    for _, contribution in ipairs(contributor.contributions) do
        allContributions = allContributions .. string.format("   - %s\n", contribution)
    end
    contributorsStr = contributorsStr .. string.format("%s <%s>\n%s\n", contributor.name, contributor.email, allContributions)
end

aboutStr = string.format(aboutStr,
    versionStr,
    S("Author:"),
    S("Contributors:"),
    contributorsStr)

mathplot.gui.screens["about"] = {
    initialize = function(playername, identifier, context)
    end,
    get_formspec = function(playername, identifier, context)
        local formspec = "size[12.25,7]"
        .. string.format("textarea[0.25,0;12,7.5;;%s;]", minetest.formspec_escape(aboutStr))
        .. string.format("button_exit[0,6.5;2,1;btn_OK;%s]", S("OK"))
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
    end
}
