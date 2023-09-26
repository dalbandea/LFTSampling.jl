abstract type AbstractHMC <: AbstractSampler end
abstract type HMCParams <: SamplerParameters end

include("integrators/integrators.jl")
export Leapfrog, OMF4

Base.@kwdef mutable struct HMC <: HMCParams
    integrator::AbstractIntegrator = Leapfrog()
    width::Float64 = 1.0 # Gaussian width of momenta
end

Base.@kwdef mutable struct RHMC{I <: AbstractIntegrator} <: HMCParams
    integrator::I = Leapfrog()
	r_b::Float64
	n::Int64
	eps::Float64
	A::Float64
	rho::Vector{Float64}
	mu::Vector{Float64}
    nu::Vector{Float64}
    delta::Float64
    reweighting_N::Int64
    reweighting_Taylor::Int64
end

struct FallbackHMC <: AbstractHMC
    params::HMCParams
end


