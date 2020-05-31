mathplot = mathplot or {}

local S = mathplot.get_translator

local function create_sandbox(code)
    if code:byte(1) == 27 then
        return nil, S("Binary code prohibited.")
    end

    local ftn, errormsg = loadstring(code)
    if ftn == nil then
        return nil, errormsg
    end

    local env = {
        tonumber = tonumber,

        --Lua 5.1 math library (https://www.lua.org/manual/5.1/manual.html#5.6)
        abs = math.abs,
        acos = math.acos,
        asin = math.asin,
        atan = math.atan,
        atan2 = math.atan2,
        ceil = math.ceil,
        cos = math.cos,
        cosh = math.cosh,
        deg = math.deg,
        exp = math.exp,
        floor = math.floor,
        fmod = math.fmod,
        --frexp = math.frexp,  --Probably not useful
        huge = math.huge,
        --ldexp = math.ldexp,  --Probably not useful
        log = math.log,
        log10 = math.log10,
        max = math.max,
        min = math.min,
        --modf = math.modf,  --Returns two values
        pi = math.pi,
        pow = math.pow,
        rad = math.rad,
        random = math.random,
        --randomseed = math.randomseed,  --Not sure how to use a seed... global property on node?
        sin = math.sin,
        sinh = math.sinh,
        sqrt = math.sqrt,
        tan = math.tan,
        tanh = math.tanh,

        --additions by KMC
        Pi = math.pi,  --for Maple copy/paste to work
        PI = math.pi,
        ln = math.log,  --alias for convenience and for Maple copy/paste to work
        arccos = math.acos, --for Maple copy/paste to work
        arcsin = math.asin, --for Maple copy/paste to work
        arctan = math.atan, --for Maple copy/paste to work
        Heaviside = function(x) return x >= 0 and 1 or 0 end, --for Maple copy/paste to work
        e = 2.7182818284590452354,
        E = 2.7182818284590452354,
        iif = function(condition, trueval, falseval)
            if condition then return trueval else return falseval end
        end,
        round = function(x) return math.floor(x+0.5) end
    }
    setfenv(ftn, env)
    return ftn, nil
end


local function clean_syntax_errormsg(errormsg)
    --Strip unhelpful "(load):1:" from start of error message from loadstring()
    return string.trim(string.match(errormsg, "%(load%):%d+:(.*)") or errormsg or "")
end

local function make_safe_function(expressionstr, varnames)
    local argstr = ""
    if varnames ~= nil then
        argstr = table.concat(varnames, ",")
    end
    local sandboxstr = string.format("return function(%s) return %s end", argstr, expressionstr)
    local ftnwrapper, errormsg = create_sandbox(sandboxstr)
    if errormsg == nil then
        local ftn = ftnwrapper()
        local pcallftn = function(...)
            return pcall(ftn, ...)
        end
        return pcallftn, nil
    else
        errormsg = clean_syntax_errormsg(errormsg)
        return nil, errormsg
    end
end


mathplot.check_function_syntax = function(expression, varnames, testinputs)
    expression = tostring(expression)

    expression = string.trim(tostring(expression))
    if #expression == 0 then
        return S("expression cannot be blank.")
    end

    local f, loaderror = make_safe_function(expression, varnames)
    if loaderror ~= nil then
        return loaderror
    end
    if testinputs then
        local ok, err = f(unpack(testinputs))
        if not ok then
            err = clean_syntax_errormsg(err)
            return err
        end
    end
    return nil
end

mathplot.line_3d = function(p1, p2)
    --This DDA algorithm is so simple and easy to understand conceptually.
    --Tested against Bresenham, and it appears to give the same results. Or at least close enough.
    --See https://www.crisluengo.net/archives/400

    --NOTE: returned list does NOT include p1.

    local d = vector.subtract(p2, p1)
    local N = math.max(math.abs(d.x), math.abs(d.y), math.abs(d.z))
    if N == 0 then
        --p1 and p2 are the same point. We're done here.
        return false, {}
    end
    local s = vector.divide(d, N)
    local i_stop = N
    local clip = false
    local max_coord = mathplot.settings.max_coord
    if max_coord then
        local M1 = mathplot.util.max_abs_coord(p1)
        if M1 > max_coord then
            --If the point starts outside the max coordinate range, just don't even try.
            return false, {}
        end
        local M2 = mathplot.util.max_abs_coord(p2)
        if M2 > max_coord then
            --Find the iteration at which we should stop. N goes too far.
            for _, c in ipairs({"x", "y", "z"}) do
                if s[c] ~= 0 then
                    local t = (-max_coord - p1[c]) / s[c]
                    if t > 0 then i_stop = math.min(i_stop, t) end
                    t = (max_coord - p1[c]) / s[c]
                    if t > 0 then i_stop = math.min(i_stop, t) end
                end
            end
        end
    end

    local pts = {}
    local p = p1
    for i = 1, i_stop do
        p = vector.add(p, s)
        pts[#pts+1] = p
    end

    return clip, pts
end


mathplot.parametric_argstr_display = function(varnames)
    local varnamesStr = ""
    for _, varname in pairs(varnames) do
        if varname:sub(1, 1) ~= "_" then
            if varnamesStr ~= "" then
                varnamesStr = varnamesStr .. ","
            end
            varnamesStr = varnamesStr .. varname
        end
    end
    return varnamesStr
end


local function to_vector(v)
    if type(v) == "string" then
        return minetest.string_to_pos(v)
    end
    return {x=v.x, y=v.y, z=v.z}
end

local function to_world_coords(x, y, z, e1, e2, e3)
    local p = vector.add(
        vector.multiply(e1, x),
        vector.add(
            vector.multiply(e2, y),
            vector.multiply(e3, z)
        ))
    return p
end

local function set_node(p, origin_pos, node, playername, protection_bypass)
    p = mathplot.util.round_vector(p)
    if (p.x ~= 0 or p.y ~= 0 or p.z ~= 0)
    and mathplot.util.max_abs_coord(p) <= mathplot.settings.max_coord
    and (protection_bypass or not mathplot.settings.respect_protected_areas or not minetest.is_protected(p, playername))
    then
        local q = vector.add(origin_pos, p)
        minetest.set_node(q, node)
    end
end

local function evaluate_parametric(e1, e2, e3, ftn_X, ftn_Y, ftn_Z, ...)
    --The "..." paramaters should be ordered parameters to functions ftn_X, ftn_Y, ftn_Z
    --Note: X, Y, Z are wrapped in pcall() under the hood, so safe here.
    local okx, x = ftn_X(...)
    local oky, y = ftn_Y(...)
    local okz, z = ftn_Z(...)

    local ok = true
    local err = ""
    if not okx then
        ok = false
        err = err .. " (x) " .. x
    end
    if not oky then
        ok = false
        err = err .. " (y) " .. y
    end
    if not okz then
        ok = false
        err = err .. " (z) " .. z
    end

    if not ok then
        local coordsStr = table.concat({...}, ",")
        return nil, S("Error evaluating parametric equations at (@1): @2", coordsStr, err)
    end

    --Note: also protecting against x,y,z being strings. tonumber("foo") returns nil, for example.
    if tonumber(x) ~= nil and tonumber(y) ~= nil and tonumber(z) ~= nil
    and x == x and y == y and z == z  --all not NaN
    and math.abs(x) < math.huge and math.abs(y) < math.huge and math.abs(z) < math.huge  --all finite
    then
        local p = to_world_coords(x, y, z, e1, e2, e3)
        return true, p
    else
        err = S("At least one coordinate does not evaluate to a number.")
        local coordsStr = table.concat({...}, ",")
        return false, S("Error evaluating parametric equations at (@1): @2", coordsStr, err)
    end
end


mathplot.plot_parametric = function(params, playername)
    --params: origin_pos, ftn_x, ftn_y, ftn_z, umin, umax, ustep, vmin, vmax, vstep, nodename, e1, e2, e3, connect, varnames
    --Note: e1, e2, e3 can be vectors in string form, e.g. "(1,2,3)"

    if not mathplot.util.has_mathplot_priv(playername) then
        return false, S("The 'mathplot' privilege is required.")
    end

    if not mathplot.util.is_drawable_node(params.nodename) then
        return false, S("'@1' is not a drawable node.", params.nodename or "")
    end

    local protection_bypass = mathplot.util.has_protection_bypass_priv(playername)

    local varnamesStr = mathplot.parametric_argstr_display(params.varnames)
    local X, loaderror = make_safe_function(params.ftn_x, params.varnames)
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1(@2): @3", "x", varnamesStr, loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    local Y, loaderror  = make_safe_function(params.ftn_y, params.varnames)
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1(@2): @3", "y", varnamesStr, loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    local Z, loaderror = make_safe_function(params.ftn_z, params.varnames)
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1(@2): @3", "z", varnamesStr, loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end

    --Tolerate vectors as strings
    local e1 = to_vector(params.e1)
    local e2 = to_vector(params.e2)
    local e3 = to_vector(params.e3)

    local node = {name=params.nodename}

    local useTimeout = mathplot.settings.plot_timeout > 0
    local timedOut = false
    local startTime = minetest.get_us_time()
    local p1 = nil

    --##################
    local UMIN, loaderror = make_safe_function(params.umin, {})
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1: @2", S("u Min"), loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    local UMAX, loaderror = make_safe_function(params.umax, {})
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1: @2", S("u Max"), loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    local USTEP, loaderror = make_safe_function(params.ustep, {})
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1: @2", S("u Step"), loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    local VMIN, loaderror = make_safe_function(params.vmin, {params.varnames[1]})  --depends on u
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1: @2", S("v Min"), loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    local VMAX, loaderror = make_safe_function(params.vmax, {params.varnames[1]})  --depends on u
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1: @2", S("v Max"), loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    local VSTEP, loaderror = make_safe_function(params.vstep, {params.varnames[1]})  --depends on u
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1: @2", S("v Step"), loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    local WMIN, loaderror = make_safe_function(params.wmin, {params.varnames[1], params.varnames[2]})  --depends on u,v
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1: @2", S("w Min"), loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    local WMAX, loaderror = make_safe_function(params.wmax, {params.varnames[1], params.varnames[2]})  --depends on u,v
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1: @2", S("w Max"), loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    local WSTEP, loaderror = make_safe_function(params.wstep, {params.varnames[1], params.varnames[2]})  --depends on u,v
    if loaderror ~= nil then
        local errormsg = S("Syntax error in @1: @2", S("w Step"), loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end
    --##################

    local ok, umin = UMIN()
    if not ok or tonumber(umin) == nil then
        return false, S("Unable to determine @1: @2", S("u Min"), umin)
    end
    local ok, umax = UMAX()
    if not ok or tonumber(umax) == nil then
        return false, S("Unable to determine @1: @2", S("u Max"), umax)
    end
    local ok, ustep = USTEP()
    if not ok or tonumber(ustep) == nil then
        return false, S("Unable to determine @1: @2", S("u Step"), ustep)
    end
    for u = umin, umax, ustep do
        local ok, vmin = VMIN(u)
        if not ok or tonumber(vmin) == nil then
            return false, S("Unable to determine @1: @2", S("v Min"), vmin)
        end
        local ok, vmax = VMAX(u)
        if not ok or tonumber(vmax) == nil then
            return false, S("Unable to determine @1: @2", S("v Max"), vmax)
        end
        local ok, vstep = VSTEP(u)
        if not ok or tonumber(vstep) == nil then
            return false, S("Unable to determine @1: @2", S("v Step"), vstep)
        end
        for v = vmin, vmax, vstep do
            local ok, wmin = WMIN(u, v)
            if not ok or tonumber(wmin) == nil then
                return false, S("Unable to determine @1: @2", S("w Min"), wmin)
            end
            local ok, wmax = WMAX(u, v)
            if not ok or tonumber(wmax) == nil then
                return false, S("Unable to determine @1: @2", S("w Max"), wmax)
            end
            local ok, wstep = WSTEP(u, v)
            if not ok or tonumber(wstep) == nil then
                return false, S("Unable to determine @1: @2", S("w Step"), wstep)
            end
            for w = wmin, wmax, wstep do
                local ok, p2 = evaluate_parametric(e1, e2, e3, X, Y, Z, u, v, w)
                if ok == nil then
                    --Error evaluating. Punt!
                    return false, p2  --p2 is error message
                end

                if ok then
                    if params.connect and p1 ~= nil then
                        set_node(p1, params.origin_pos, node, playername, protection_bypass)
                        --connect the nodes with a line
                        local clip, linepoints = mathplot.line_3d(p1, p2)
                        for _, p in ipairs(linepoints) do
                            set_node(p, params.origin_pos, node, playername, protection_bypass)
                        end
                        if clip then
                            p2 = nil
                        end
                    else
                        --set node, but don't draw line since there's
                        --no previous node to draw line to.
                        set_node(p2, params.origin_pos, node, playername, protection_bypass)
                    end
                    p1 = p2
                else
                    --Perhaps evaluated to NaN or inf. Just do nothing.
                    --Right now p1 is an error string. Set to nil instead.
                    p1 = nil
                end

                if useTimeout then
                    timedOut = minetest.get_us_time() - startTime > mathplot.settings.plot_timeout
                    if timedOut then
                        local errormsg = S("Timeout exceeded.")
                        minetest.log(errormsg)
                        return false, errormsg
                    end
                end
            end
        end
    end

    local msg = S("Total elapsed time: @1 seconds", (minetest.get_us_time()-startTime) / 1e6)
    minetest.log(msg)
    return true, msg
end



--###############################################################


local function satisfies_implicit_relation(F, x, y, z, xstep, ystep, zstep)
    local evaluate = function(x, y, z)
        local ok, f = F(x, y, z)
        local errormsg = nil
        if not ok then
            errormsg = S("Error evaluating implicit relation: @1", f)
        end
        return ok, f, errormsg
    end

    local d = { 0, 0.49, -0.49 }
    local sgn = nil
    for i = 1, 3 do
        for j = 1, 3 do
            for k = 1, 3 do
                local ok, f, errormsg = evaluate(x+d[i]*xstep, y+d[j]*ystep, z+d[k]*zstep)
                if not ok then
                    return false, errormsg
                end

                if type(f) == "number" then
                    local sgn2 = mathplot.util.sgn(f)
                    if sgn2 == 0 then
                        --Jackpot!
                        return true, nil
                    elseif sgn ~= nil and sgn2 ~= sgn then
                        --Sign change! By IVT, a zero exists in the voxel.
                        --(Assuming condition is a continuous function)
                        return true, nil
                    end
                    sgn = sgn2
                elseif type(f) == "boolean" then
                    if f == true then
                        return true, nil
                    end
                end
            end
        end
    end

    return false, nil
end

mathplot.plot_implicit = function(params, playername)
    --params: origin_pos, ftn, xmin, xmax, xstep, ymin, ymax, ystep, zmin, zmax, zstep, nodename, e1, e2, e3

    if not mathplot.util.has_mathplot_priv(playername) then
        return false, S("The 'mathplot' privilege is required.")
    end

    if not mathplot.util.is_drawable_node(params.nodename) then
        return false, S("'@1' is not a drawable node.", params.nodename or "")
    end

    local protection_bypass = mathplot.util.has_protection_bypass_priv(playername)

    local F, loaderror = make_safe_function(params.ftn, params.varnames)
    if loaderror ~= nil then
        local errormsg = S("Syntax error in relation: @1", loaderror)
        minetest.log(errormsg)
        return false, errormsg
    end

    local node = {name=params.nodename}

    --Tolerate vectors as strings
    local e1 = to_vector(params.e1)
    local e2 = to_vector(params.e2)
    local e3 = to_vector(params.e3)

    local useTimeout = mathplot.settings.plot_timeout > 0
    local timedOut = false
    local startTime = minetest.get_us_time()
    for x = params.xmin, params.xmax, params.xstep do
        for y = params.ymin, params.ymax, params.ystep do
            for z = params.zmin, params.zmax, params.zstep do
                local yes, errormsg = satisfies_implicit_relation(F, x, y, z, params.xstep, params.ystep, params.zstep)
                if yes then
                    local p = to_world_coords(x, y, z, e1, e2, e3)
                    set_node(p, params.origin_pos, node, playername, protection_bypass)
                elseif errormsg ~= nil then
                    minetest.log(errormsg)
                    return false, errormsg
                end
            end

            if useTimeout then
                timedOut = minetest.get_us_time() - startTime > mathplot.settings.plot_timeout
                if timedOut then
                    local errormsg = S("Timeout exceeded.")
                    minetest.log(errormsg)
                    return false, errormsg
                end
            end
        end
    end

    local msg = S("Total elapsed time: @1 seconds", (minetest.get_us_time()-startTime) / 1e6)
    minetest.log(msg)
    return true, msg
end
