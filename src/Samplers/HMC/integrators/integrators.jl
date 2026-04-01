abstract type AbstractIntegrator end

Base.@kwdef struct Leapfrog <: AbstractIntegrator 
    epsilon::Float64 = 0.1 
    nsteps::Int64 = 10
    function Leapfrog(tau::Float64, nsteps::Int64)
        epsilon = tau / nsteps
        return new(epsilon, nsteps)
    end
end

"""
    OMF4(tau::Float64, nsteps::Int64)

4th-order Omelyan-Mryglod-Folk (OMF4) symplectic integrator for molecular dynamics.

Each trajectory of length `tau` is divided into `nsteps` steps of size
`epsilon = tau / nsteps`. One step consists of six force/field update pairs with
coefficients:

    r1 =  0.08398315262876693
    r2 =  0.2539785108410595
    r3 =  0.6822365335719091
    r4 = -0.03230286765269967
    r5 =  0.5 - r1 - r3
    r6 =  1.0 - 2*(r2 + r4)

resulting in integration error O(ε⁴) per step (O(ε⁴) global error for fixed `tau`),
compared to O(ε²) for leapfrog.

# Fields
- `epsilon::Float64`: step size (= `tau / nsteps`)
- `nsteps::Int64`: number of steps per trajectory

# Example
```julia
integrator = OMF4(1.0, 10)   # tau=1.0, 10 steps of size 0.1
hmcp = HMC(integrator = integrator)
```

See also [`Leapfrog`](@ref).
"""
struct OMF4 <: AbstractIntegrator
    epsilon::Float64
    nsteps::Int64
    function OMF4(tau::Float64, nsteps::Int64)
        epsilon = tau / nsteps
        return new(epsilon, nsteps)
    end
end



