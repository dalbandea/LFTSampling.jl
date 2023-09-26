abstract type AbstractMetropolis <: AbstractSampler end
abstract type MetropolisParams <: SamplerParameters end

Base.@kwdef mutable struct Metropolis <: MetropolisParams
    weight::Float64 = 0.1
    naccepted::Int64 = 0
    nsampled::Int64 = 0
end

struct FallbackMetropolis{P <: MetropolisParams} <: AbstractMetropolis
    params::P
end
