reset_sampler!(samplerws::AbstractMetropolisHastings, accepted) = reset_sampler!(samplerws.params.dist, accepted)

reset_sampler!(samplerws::AbstractDistribution, accepted::Bool) = nothing

function mhastings!(lftws::AbstractLFT, samplerws::AbstractSampler)
    # Backup configuration
    lftws_cp = deepcopy(lftws)

    # Initial action
    logp_i = -action(lftws)
    logq_i = log_prob(lftws, samplerws)
    
    # Generate new configuration
    update!(lftws, samplerws)

    # Final action
    logp_f = -action(lftws)
    logq_f = log_prob(lftws, samplerws)
    
    # Accept-reject step
    dS = -(logp_f - logp_i + logq_i - logq_f)
    accepted = metropolis_accept_reject!(lftws, lftws_cp, dS)

    samplerws.params.nsampled += 1
    if accepted == true
        samplerws.params.naccepted += 1
    end

    reset_sampler!(samplerws, accepted)
end
