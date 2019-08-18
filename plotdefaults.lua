mathplot = mathplot or {}
mathplot.plotdefaults = {}

local _axis_params = {
    schema_version = 1,
    xmin = 0,
    xmax = 1,
    ymin = 0,
    ymax = 1,
    zmin = 0,
    zmax = 1,
    e1 = "(1,0,0)",
    e2 = "(0,0,1)",
    e3 = "(0,1,0)",
    xaxisbrush = "wool:red",
    yaxisbrush = "wool:green",
    zaxisbrush = "wool:blue"
}
mathplot.plotdefaults.axis_params = function()
    return table.copy(_axis_params)
end

local _plot_implicit_params = {
    schema_version = 1,
    varnames = { "x", "y", "z" },
    origin_pos = "",
    ftn = "",
    xmin = 0,
    xmax = 10,
    xstep = 1,
    ymin = 0,
    ymax = 10,
    ystep = 1,
    zmin = 0,
    zmax = 10,
    zstep = 1,
    nodename = "default:meselamp",
    e1 = "(1,0,0)",
    e2 = "(0,0,1)",
    e3 = "(0,1,0)"
}
mathplot.plotdefaults.plot_implicit_params = function()
    return table.copy(_plot_implicit_params)
end


local _plot_parametric_curve_params = {
    schema_version = 1,
    connect = true,  --connect the dots with line segments
    varnames = { "u", "_____v", "_____w" },  --u and w are "unused"
    origin_pos = "",
    ftn_x = "",
    ftn_y = "",
    ftn_z = "",
    umin = 0,
    umax = 10,
    ustep = 0.1,
    vmin = 0,
    vmax = 0,
    vstep = 1,
    wmin = 0,
    wmax = 0,
    wstep = 1,
    nodename = "default:meselamp",
    e1 = "(1,0,0)",
    e2 = "(0,0,1)",
    e3 = "(0,1,0)"
}
mathplot.plotdefaults.plot_parametric_curve_params = function()
    return table.copy(_plot_parametric_curve_params)
end


local _plot_parametric_surface_params = {
    schema_version = 1,
    connect = false,
    varnames = { "u", "v", "_____w" },  --w is "unused"
    origin_pos = "",
    ftn_x = "",
    ftn_y = "",
    ftn_z = "",
    umin = 0,
    umax = 10,
    ustep = 0.1,
    vmin = 0,
    vmax = 10,
    vstep = 0.1,
    wmin = 0,
    wmax = 0,
    wstep = 1,
    nodename = "default:meselamp",
    e1 = "(1,0,0)",
    e2 = "(0,0,1)",
    e3 = "(0,1,0)"
}
mathplot.plotdefaults.plot_parametric_surface_params = function()
    return table.copy(_plot_parametric_surface_params)
end


local _plot_parametric_solid_params = {
    schema_version = 1,
    connect = false,
    varnames = { "u", "v", "w" },
    origin_pos = "",
    ftn_x = "",
    ftn_y = "",
    ftn_z = "",
    umin = 0,
    umax = 10,
    ustep = 0.1,
    vmin = 0,
    vmax = 10,
    vstep = 0.1,
    wmin = 0,
    wmax = 10,
    wstep = 0.1,
    nodename = "default:meselamp",
    e1 = "(1,0,0)",
    e2 = "(0,0,1)",
    e3 = "(0,1,0)"
}
mathplot.plotdefaults.plot_parametric_solid_params = function()
    return table.copy(_plot_parametric_solid_params)
end
