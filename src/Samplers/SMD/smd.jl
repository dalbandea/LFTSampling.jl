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
    leapfrog!(lftws, smdws, integr.epsilon, 1)
molecular_dynamics!(lftws::AbstractLFT, smdws::AbstractSMD, integr::OMF4) =
    OMF4!(lftws, smdws, integr.epsilon, 1)

function smd!(lftws::AbstractLFT, smdws::AbstractSMD)
    c1 = exp(-smdws.params.gamma * smdws.params.integrator.epsilon)

    # MD trajectory without accept/reject step
    for i in 1:smdws.params.integrator.nsteps
        refresh_momenta!(lftws, smdws, c1)
        molecular_dynamics!(lftws, smdws)
    end

    return nothing
end
