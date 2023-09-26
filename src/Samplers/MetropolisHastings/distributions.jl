abstract type AbstractDistribution end

struct QuantumRotorOBCDistribution <: AbstractDistribution
    I::Float64
end

function sample(dist::AbstractDistribution, n::Int64)
    samples = [sample(dist) for i in 1:n]
end

function log_prob(dist::AbstractDistribution, x) end

