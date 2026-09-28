# These functions need to be defined for every model using SMD
## Mandatory
# Partial momentum refresh: p <- c1*p + sqrt(1-c1^2)*eta, where eta is Gaussian noise.
# c1 = exp(-gamma*epsilon): c1=0 is a full refresh (as in HMC), c1=1 keeps momenta unchanged.
function refresh_momenta!(lftws::AbstractLFT, smdws::AbstractSMD, c1::Float64)
    error("No function refresh_momenta! for $(typeof(lftws))")
    return nothing
end
# Kinetic energy of the momenta; only needed with compute_dH = true
function kinetic_energy(lftws::AbstractLFT, smdws::AbstractSMD)
    error("No function kinetic_energy for $(typeof(lftws))")
    return nothing
end

molecular_dynamics!(lftws::AbstractLFT, smdws::AbstractSMD) =
    molecular_dynamics!(lftws, smdws, smdws.params.integrator)
molecular_dynamics!(lftws::AbstractLFT, smdws::AbstractSMD, integr::Leapfrog) =
    leapfrog!(lftws, smdws, integr.epsilon, 1)
molecular_dynamics!(lftws::AbstractLFT, smdws::AbstractSMD, integr::OMF4) =
    OMF4!(lftws, smdws, integr.epsilon, 1)

function smd!(lftws::AbstractLFT, smdws::AbstractSMD)
    c1 = exp(-smdws.params.gamma * smdws.params.integrator.epsilon)
    # generate_momenta!(lftws, smdws)

    # MD trajectory without accept/reject step
    if !smdws.params.compute_dH
        for i in 1:smdws.params.integrator.nsteps
            refresh_momenta!(lftws, smdws, c1)
            molecular_dynamics!(lftws, smdws)
        end
        return nothing
    end

    # Same, returning dH = sum over the steps of H(after MD) - H(before MD). The
    # momentum rotations change H too, but they are not integration errors and are
    # left out. They do not change the field, so the action at the end of a step is
    # the one at the start of the next.
    S  = action(lftws)
    dH = zero(S)
    for i in 1:smdws.params.integrator.nsteps
        refresh_momenta!(lftws, smdws, c1)
        K = kinetic_energy(lftws, smdws)
        molecular_dynamics!(lftws, smdws)
        Snew = action(lftws)
        dH  += (kinetic_energy(lftws, smdws) - K) + (Snew - S)
        S    = Snew
    end

    return dH
end
