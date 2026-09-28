abstract type AbstractSMD <: AbstractSampler end
abstract type SMDParams <: SamplerParameters end

Base.@kwdef mutable struct SMD <: SMDParams
    integrator::AbstractIntegrator = OMF4(0.1, 1)
    gamma::Float64 = 1.0
    width::Float64 = 1.0
    compute_dH::Bool = false    # smd! accumulates and returns the energy violation
end

struct FallbackSMD <: AbstractSMD
    params::SMDParams
end
