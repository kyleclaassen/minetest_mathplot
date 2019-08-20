mathplot = mathplot or {}
mathplot.examples = {}

mathplot.examples.hemisphere = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_implicit_params()
    p.origin_pos = node_pos
    p.ftn = "x^2 + y^2 + (z-10)^2 - 20^2"
    p.xmin = -20
    p.xmax = 20
    p.ymin = -20
    p.ymax = 20
    p.zmin = 10
    p.zmax = 30
    p.nodename = "mathplot:glow_wool_magenta"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("implicit_plot", playername, context)
end

mathplot.examples.solid_hemisphere = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_implicit_params()
    p.origin_pos = node_pos
    p.ftn = "x^2 + y^2 + (z-10)^2 <= 20^2"
    p.xmin = -20
    p.xmax = 20
    p.ymin = -20
    p.ymax = 20
    p.zmin = 10
    p.zmax = 30
    p.nodename = "mathplot:glow_wool_blue"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("implicit_plot", playername, context)
end

mathplot.examples.cylinder_with_tunnel = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_implicit_params()
    p.origin_pos = node_pos
    p.ftn = "x^2 + y^2 <= 20^2 and x^2 + z^2 >= 10^2"
    p.xmin = -20
    p.xmax = 20
    p.ymin = -120
    p.ymax = 20
    p.zmin = 0
    p.zmax = 20
    p.nodename = "default:stonebrick"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("implicit_plot", playername, context)
end

mathplot.examples.implicit_cone = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_implicit_params()
    p.origin_pos = node_pos
    p.ftn = "x^2 + y^2 - (z-20)^2"
    p.xmin = -15
    p.xmax = 15
    p.ymin = -15
    p.ymax = 15
    p.zmin = 5
    p.zmax = 35
    p.nodename = "mathplot:glow_wool_green"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("implicit_plot", playername, context)
end

mathplot.examples.onevar_ftn_graph = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_parametric_curve_params()
    p.origin_pos = node_pos
    p.ftn_x = "u"
    p.ftn_y = "0"
    p.ftn_z = "10 + 5*sin(2*pi*u/15)"
    p.umin = -15
    p.umax = 15
    p.ustep = 0.1
    p.nodename = "mathplot:glow_wool_yellow"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("parametric_curve", playername, context)
end

mathplot.examples.helix = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_parametric_curve_params()
    p.origin_pos = node_pos
    p.ftn_x = "8*cos(2*pi*u*4)"
    p.ftn_y = "8*sin(2*pi*u*4)"
    p.ftn_z = "50*u"
    p.umin = "0"
    p.umax = "1"
    p.ustep = "1/100"
    p.nodename = "mathplot:glow_wool_red"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("parametric_curve", playername, context)
end

mathplot.examples.circular_wave = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_parametric_curve_params()
    p.origin_pos = node_pos
    p.ftn_x = "25*cos(u)"
    p.ftn_y = "25*sin(u)"
    p.ftn_z = "10 + 5*sin(4*u)"
    p.umin = "0"
    p.umax = "2*pi"
    p.ustep = "0.01"
    p.nodename = "mathplot:glow_wool_violet"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("parametric_curve", playername, context)
end

mathplot.examples.trefoil_knot = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_parametric_curve_params()
    p.origin_pos = node_pos
    p.ftn_x = "15*(sin(u) + 2*sin(2*u))"
    p.ftn_y = "15*(cos(u) - 2*cos(2*u))"
    p.ftn_z = "20 - 15*sin(3*u)"
    p.umin = "0"
    p.umax = "2*pi"
    p.ustep = "0.01"
    p.nodename = "mathplot:glow_wool_orange"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("parametric_curve", playername, context)
end

mathplot.examples.twovar_ftn_graph = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_parametric_surface_params()
    p.origin_pos = node_pos
    p.ftn_x = "u"
    p.ftn_y = "v"
    p.ftn_z = "15 + 5*(cos(u/4)  + cos(v/4))"
    p.umin = "-2*pi*4"
    p.umax = "2*pi*4"
    p.ustep = "0.25"
    p.vmin = "-2*pi*4"
    p.vmax = "2*pi*4"
    p.vstep = "0.25"
    p.nodename = "mathplot:glow_wool_pink"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("parametric_surface", playername, context)
end

mathplot.examples.parametric_torus = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_parametric_surface_params()
    p.origin_pos = node_pos
    p.ftn_x = "(20 + 7*cos(u))*cos(v)"
    p.ftn_y = "(20 + 7*cos(u))*sin(v)"
    p.ftn_z = "15 + 7*sin(u)"
    p.umin = "0"
    p.umax = "2*pi"
    p.ustep = "0.025"
    p.vmin = "0"
    p.vmax = "2*pi"
    p.vstep = "0.025"
    p.nodename = "mathplot:glow_glass_white"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("parametric_surface", playername, context)
end

mathplot.examples.surface_of_revolution  = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_parametric_surface_params()
    p.origin_pos = node_pos
    p.ftn_x = "u"
    p.ftn_y = "(10 + 5*u/6 - u^3/200)*cos(v)"
    p.ftn_z = "20 + (10 + 5*u/6 - u^3/200)*sin(v)"
    p.umin = "-12"
    p.umax = "14"
    p.ustep = "0.5"
    p.vmin = "0"
    p.vmax = "2*pi"
    p.vstep = "0.01"
    p.nodename = "default:goldblock"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("parametric_surface", playername, context)
end

mathplot.examples.klein_bottle = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_parametric_surface_params()
    p.origin_pos = node_pos
    p.ftn_x = "30*(-2/15*cos(u)*(3*cos(v) - 30*sin(u) + 90*cos(u)^4*sin(u) - 60*cos(u)^6*sin(u) + 5*cos(u)*cos(v)*sin(u)))"
    p.ftn_y = "30*((2/5 + 2/3*cos(u)*sin(u))*sin(v))"
    p.ftn_z = "30*(-1/15*sin(u)*(3*cos(v) - 3*cos(u)^2*cos(v) - 48*cos(u)^4*cos(v) + 48*cos(u)^6*cos(v) - 60*sin(u) + 5*cos(u)*cos(v)*sin(u) - 5*cos(u)^3*cos(v)*sin(u) - 80*cos(u)^5*cos(v)*sin(u) + 80*cos(u)^7*cos(v)*sin(u)))"
    p.umin = "0"
    p.umax = "pi"
    p.ustep = "0.005"
    p.vmin = "0"
    p.vmax = "2*pi"
    p.vstep = "0.025"
    p.nodename = "mathplot:translucent_violet"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("parametric_surface", playername, context)
end

mathplot.examples.solid_of_revolution = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_parametric_solid_params()
    p.origin_pos = node_pos
    p.ftn_x = "w*cos(v)"
    p.ftn_y = "w*sin(v)"
    p.ftn_z = "5 + u"
    p.umin = "0"
    p.umax = "50"
    p.ustep = "0.5"
    p.vmin = "0"
    p.vmax = "2*pi"
    p.vstep = "0.025"
    p.wmin = "3*u/10"
    p.wmax = "5 + (u/10)^2"
    p.wstep = "0.5"
    p.nodename = "mathplot:glow_wool_orange"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("parametric_solid", playername, context)
end

mathplot.examples.thick_twovar_ftn_graph = function(playername, node_pos)
    local p = mathplot.plotdefaults.plot_parametric_solid_params()
    p.origin_pos = node_pos
    p.ftn_x = "u"
    p.ftn_y = "v"
    p.ftn_z = "15 + 5*(cos(u/4)  + cos(v/4)) + w"
    p.umin = "-2*pi*4"
    p.umax = "2*pi*4"
    p.ustep = "0.25"
    p.vmin = "-2*pi*4"
    p.vmax = "2*pi*4"
    p.vstep = "0.25"
    p.wmin = "0"
    p.wmax = "15"
    p.wstep = "1"
    p.nodename = "mathplot:glow_wool_cyan"
    local context = {
        node_pos = node_pos,
        screen_params = p
    }
    mathplot.gui.invoke_screen("parametric_solid", playername, context)
end
