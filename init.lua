mathplot = {}
mathplot.MODPATH = minetest.get_modpath("mathplot")

mathplot.VERSION = "0.5"

--Read settings from settingtypes.txt
mathplot.settings = {}
--Plot timeout (in microseconds). Stored as seconds in minetest settings.
mathplot.settings.plot_timeout = tonumber(minetest.settings:get("mathplot.plot_timeout")) or 60
mathplot.settings.plot_timeout = mathplot.settings.plot_timeout * 1e6  --convert to microseconds

--Maximum coordinate (relative to origin) to protect against "runaway growth"
mathplot.settings.max_coord = tonumber(minetest.settings:get("mathplot.max_coord")) or 600

----------------------------------------------

dofile(mathplot.MODPATH .. "/util.lua")
dofile(mathplot.MODPATH .. "/nodes.lua")
dofile(mathplot.MODPATH .. "/storage.lua")
dofile(mathplot.MODPATH .. "/functions.lua")
dofile(mathplot.MODPATH .. "/plotdefaults.lua")

dofile(mathplot.MODPATH .. "/gui/gui.lua")
dofile(mathplot.MODPATH .. "/gui/screen_validation_errors.lua")
dofile(mathplot.MODPATH .. "/gui/screen_mainmenu.lua")
dofile(mathplot.MODPATH .. "/gui/screen_originmainmenu.lua")
dofile(mathplot.MODPATH .. "/gui/screen_draw_axes.lua")
dofile(mathplot.MODPATH .. "/gui/screen_implicit_plot.lua")
dofile(mathplot.MODPATH .. "/gui/screen_parametric.lua")
dofile(mathplot.MODPATH .. "/gui/screen_about.lua")
dofile(mathplot.MODPATH .. "/gui/screen_setname.lua")
dofile(mathplot.MODPATH .. "/gui/screen_serialize.lua")

dofile(mathplot.MODPATH .. "/commands.lua")
