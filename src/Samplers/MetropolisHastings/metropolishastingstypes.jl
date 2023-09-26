abstract type AbstractMetropolisHastings <: AbstractSampler end
abstract type MetropolisHastingsParams <: SamplerParameters end

include("distributions.jl")
export QuantumRotorOBCDistribution, sample, log_prob


Base.@kwdef mutable struct MetropolisHastings{D <: AbstractDistribution} <: MetropolisHastingsParams
    dist::D
    naccepted::Int64 = 0
    nsampled::Int64 = 0
end

struct FallbackMetropolisHastings{P <: MetropolisHastingsParams} <: AbstractMetropolisHastings
    params::P
end

