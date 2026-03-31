# These functions need to be defined for every model using SMD
## Mandatory
# Partial momentum refresh: p <- c1*p + sqrt(1-c1^2)*eta, where eta is Gaussian noise.
# c1 = exp(-gamma*epsilon): c1=0 is a full refresh (as in HMC), c1=1 keeps momenta unchanged.
function refresh_momenta!(lftws::AbstractLFT, smdws::AbstractSMD, c1::Float64)
    error("No function refresh_momenta! for $(typeof(lftws))")
    return nothing
end

molecular_dynamics!(lftws::AbstractLFT, smdws::AbstractSMD) =
    molecular_dynamics!(lftws, smdws, smdws.params.integrator)
molecular_dynamics!(lftws::AbstractLFT, smdws::AbstractSMD, integr::Leapfrog) =
    leapfrog!(lftws, smdws, integr.epsilon, integr.nsteps)
molecular_dynamics!(lftws::AbstractLFT, smdws::AbstractSMD, integr::OMF4) =
    OMF4!(lftws, smdws, integr.epsilon, integr.nsteps)

function smd!(lftws::AbstractLFT, smdws::AbstractSMD)
    c1 = exp(-smdws.params.gamma * smdws.params.integrator.epsilon)

    # Partial momentum refresh
    refresh_momenta!(lftws, smdws, c1)

    # MD trajectory without accept/reject step
    molecular_dynamics!(lftws, smdws)

    return nothing
end
