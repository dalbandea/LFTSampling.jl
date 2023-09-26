include("samplertypes.jl")

function copy!(lftws_dest::L, lftws_src::L) where L <: AbstractLFT
    error("No function copy! for $(typeof(lftws_dest))")
    return nothing
end

function sampler(lftws::AbstractLFT, samplerparms::SamplerParameters) end
function sample!(lftws::AbstractLFT, samplerws::AbstractSampler) end 
function sample!(lftws::AbstractLFT, samplerparms::SamplerParameters)
    samplerws = sampler(lftws, samplerparms)
    return sample!(lftws, samplerws)
end
export sample!



function metropolis_accept_reject!(lftws::L, lftcp::L, dS::Float64) where {L <: AbstractLFT}
    pacc = exp(-dS)
    if (pacc < 1.0)
        r = rand()
        if (r > pacc) 
            copy!(lftws, lftcp)
            @info("    REJECT: Energy [difference: $(dS)]")
            return 0.0
        else
            @info("    ACCEPT:  Energy [difference: $(dS)]")
            return 1.0
        end
    else
        @info("    ACCEPT:  Energy [difference: $(dS)]")
        return 1.0
    end
    return nothing
end

function accept_reject!(dS::Float64)
    pacc = exp(-dS)
    if (pacc < 1.0)
        r = rand()
        if (r > pacc) 
            # @info("    REJECT: Energy [difference: $(dS)]")
            return 0.0
        else
            # @info("    ACCEPT:  Energy [difference: $(dS)]")
            return 1.0
        end
    else
        # @info("    ACCEPT:  Energy [difference: $(dS)]")
        return 1.0
    end
end


#########
#  HMC  #
#########

include("HMC/hmctypes.jl")
export AbstractHMC, HMCParams, HMC, RHMC

include("HMC/hmc.jl")
export hmc!

sampler(lftws::AbstractLFT, hmcp::HMCParams) = FallbackHMC(hmcp)
sample!(lftws::AbstractLFT, samplerws::AbstractHMC) = hmc!(lftws, samplerws)



##############
# Metropolis #
##############

include("Metropolis/metropolistypes.jl")
export Metropolis

include("Metropolis/metropolis.jl")
export sweep!


function sampler(lftws::AbstractLFT, mp::MetropolisParams) 
    samplerws = FallbackMetropolis(mp)
    samplerws.params.naccepted = 0.0
    samplerws.params.nsampled = 0.0
    return samplerws
end
sample!(lftws::AbstractLFT, samplerws::AbstractMetropolis) = sweep!(lftws, samplerws)

acceptance(samplerws::AbstractMetropolis) = samplerws.params.naccepted / samplerws.params.nsampled



#######################
# Metropolis-Hastings #
#######################

include("MetropolisHastings/metropolishastingstypes.jl")
export MetropolisHastings

include("MetropolisHastings/metropolishastings.jl")
export mhastings!

function sampler(lftws::AbstractLFT, mp::MetropolisHastingsParams) 
    samplerws = FallbackMetropolisHastings(mp)
    samplerws.params.naccepted = 0.0
    samplerws.params.nsampled = 0.0
    return samplerws
end
sample!(lftws::AbstractLFT, samplerws::AbstractMetropolisHastings) = mhastings!(lftws, samplerws)
acceptance(samplerws::AbstractMetropolisHastings) = samplerws.params.naccepted / samplerws.params.nsampled


update!(lftws::AbstractLFT, samplerws::AbstractMetropolisHastings) =
        sample!(lftws, samplerws.params.dist)

log_prob(lftws::AbstractLFT, samplerws::AbstractMetropolisHastings) =
        log_prob(lftws, samplerws.params.dist)

