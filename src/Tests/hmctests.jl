
function infinitesimal_transformation(lftws::AbstractLFT, hmcws::AbstractHMC) 
    @error "No function infinitesimal_transformation for $(typeof(lftws))"
end

function analytic_force(lftws::AbstractLFT, hmcws::AbstractHMC) 
    @error "No function analytic_force for $(typeof(lftws))"
end

function get_field(lftws::AbstractLFT) 
    @error "No function get_field for $(typeof(lftws))"
end

function flip_momenta_sign!(hmcws::AbstractHMC) 
    @error "No function flip_momenta_sign! for $(typeof(hmcws))"
end

function reversibility!(lftws::AbstractLFT, hmcws::AbstractHMC)
    molecular_dynamics!(lftws, hmcws)
    flip_momenta_sign!(hmcws)
    molecular_dynamics!(lftws, hmcws)
    return nothing
end


"""
    function force_test(lftws::AbstractLFT, hmcws::AbstractHMC, epsilon)

Computes the average numerical force of a configuration and compares it with the
analytical one. To use this function one needs to define the functions
- analytic_force
- get_field
- flip_momenta_sign!
"""
function force_test(lftws::AbstractLFT, hmcws::AbstractHMC, epsilon)
    lftws2 = deepcopy(lftws)

    Si = action(lftws, hmcws)

    F_ana = analytic_force(lftws, hmcws)

    fld = get_field(lftws2)

    F_diff = 0.0

    for i in 1:length(fld)
        fld[i] = infinitesimal_transformation(fld[i], epsilon, lftws2)

        # Final action
        Sf = action(lftws2, hmcws)

        # Numerical force at point i
        F_num = (Sf - Si)/epsilon

        # Difference
        F_diff += abs(F_ana[i] + F_num)

        fld[i] = infinitesimal_transformation(fld[i], -epsilon, lftws2)
    end

    return F_diff / length(fld)
end
