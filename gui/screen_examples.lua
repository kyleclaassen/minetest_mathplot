mathplot.gui.screens = mathplot.gui.screens or {}

mathplot.gui.screens["examples"] = {
    initialize = function(playername, identifier, context)
    end,
    get_formspec = function(playername, identifier, context)
        local formspec = "size[12.25,9.75]"
        .. "label[0,0;Examples]"
        .. "container[0,1]"
        .. "label[0,0;Implicit Plot]"
        .. "button_exit[0,0.5;3,1;btn_hemisphere;Hemisphere]"
        .. "button_exit[3,0.5;3,1;btn_solid_hemisphere;Solid Hemisphere]"
        .. "button_exit[6,0.5;3,1;btn_cylinder_with_tunnel;Cylinder w/ Tunnel]"
        .. "button_exit[9,0.5;3,1;btn_implicit_cone;Cone]"
        .. "container_end[]"
        .. "container[0,3]"
        .. "label[0,0;Parametric Curve]"
        .. "button_exit[0,0.5;3,1;btn_onevar_ftn_graph;Graph of Function]"
        .. "button_exit[3,0.5;3,1;btn_helix;Helix]"
        .. "button_exit[6,0.5;3,1;btn_circular_wave;Circular Wave]"
        .. "button_exit[9,0.5;3,1;btn_trefoil_knot;Trefoil Knot]"
        .. "container_end[]"
        .. "container[0,5]"
        .. "label[0,0;Parametric Surface]"
        .. "button_exit[0,0.5;3,1;btn_twovar_ftn_graph;Graph of Function]"
        .. "button_exit[3,0.5;3,1;btn_parametric_torus;Torus]"
        .. "button_exit[6,0.5;3,1;btn_surface_of_revolution;Surface of Revolution]"
        .. "button_exit[9,0.5;3,1;btn_klein_bottle;Klein Bottle]"
        .. "container_end[]"
--        .. "container[0,7]"
--        .. "label[0,0;Parametric Solid]"
--        .. "button_exit[0,0.5;3,1;btn_sphere;Sphere]"
--        .. "button_exit[3,0.5;3,1;btn_solid_hemisphere;Solid Hemisphere]"
--        .. "button_exit[6,0.5;3,1;btn_cylinder_tunnel;Cylinder w/ Tunnel]"
--        .. "button_exit[9,0.5;3,1;btn_cone;Cone]"
--        .. "container_end[]"
        .. "button_exit[0,9;2,1;btn_exit;Exit]"
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        for name, _ in pairs(fields) do
            if string.match(name, "^btn_") then
                local exampleName = string.gsub(name, "^btn_", "")
                local exampleExists = mathplot.examples[exampleName] ~= nil
                if exampleExists then
                    mathplot.examples[exampleName](playername, context.node_pos)
                    break
                end
            end
        end
    end
}

