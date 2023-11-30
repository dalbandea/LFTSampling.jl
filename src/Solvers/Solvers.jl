abstract type AbstractSolver end

struct CG{A <: AbstractArray} <: AbstractSolver
    maxiter::Int64
    tol::Float64
    r::A
    p::A
    Ap::A
    tmp::A
    function CG(maxiter, tol, X)
        r = similar(X)
        p = similar(X)
        Ap = similar(X)
        tmp = similar(X)
        return new{typeof(X)}(maxiter, tol, r, p, Ap, tmp)
    end
end

struct BiCGSTAB{A <: AbstractArray} <: AbstractSolver
    maxiter::Int64
    tol::Float64
    r::A
    r_hat::A
    p::A
    v::A
    s::A
    t::A
    tmp::A
    function BiCGSTAB(maxiter, tol, X)
        r = similar(X)
        r_hat = similar(X)
        p = similar(X)
        v = similar(X)
        s = similar(X)
        t = similar(X)
        tmp = similar(X)
        return new{typeof(X)}(maxiter, tol, r, r_hat, p, v, s, t, tmp)
    end
end


invert!(so, A::Function, si, solver::CG, lftws::AbstractLFT) = cg!(so, A, si, solver, lftws)
invert!(so, A::Function, si, solver::BiCGSTAB, lftws::AbstractLFT) = bicgstab!(so, A, si, solver, lftws)


function cg!(so, A::Function, si, solver::CG, lftws::AbstractLFT)

    r  = solver.r
    p  = solver.p
    Ap = solver.Ap
    tmp = solver.tmp
    
    so .= zero(eltype(so))
    r  .= si
    p  .= si
    norm = mapreduce(x -> abs2(x), +, si)
    err = zero(lftws.PRC)
    
	    # println( tol)
	    iterations = 0
    for i in 1:solver.maxiter
        A(Ap, tmp, p, lftws)
        prod  = LinearAlgebra.dot(p, Ap)
        alpha = norm/prod

        so .= so .+ alpha .*  p
        r  .= r  .- alpha .* Ap

        err = mapreduce(x -> abs2(x), +, r)
        
        if err < solver.tol
		iterations=i
            break
        end

        beta = err/norm
        p .= r .+ beta .* p
        
        norm = err;
    end

    if err > solver.tol
	    println(err)
        error("CG not converged after $(solver.maxiter) iterationss")
    end
    
    return iterations
end


function bicgstab!(so, A::Function, si, solver::BiCGSTAB, lftws::AbstractLFT)
    r  = solver.r
    r_hat = solver.r_hat
    p  = solver.p
    v = solver.v
    s = solver.s
    t = solver.t
    tmp = solver.tmp

    so .= zero(eltype(so))
    r .= si
    r_hat .= si  # Choose r_hat such that (r_hat, r) is nonzero. Here, just set r_hat = r
    p .= zero(eltype(p))
    v .= zero(eltype(v))

    rho_old = alpha = omega = 1.0
    err = mapreduce(x -> abs2(x), +, r)

    iterations = 0
    for i in 1:solver.maxiter
        rho_new = LinearAlgebra.dot(r_hat, r)
        beta = (rho_new / rho_old) * (alpha / omega)
        p .= r .+ beta .* (p - omega .* v)
        A(v, tmp, p, lftws)
        alpha = rho_new / LinearAlgebra.dot(r_hat, v)
        s .= r .- alpha .* v
        A(t, tmp, s, lftws)
        omega = LinearAlgebra.dot(t, s) / LinearAlgebra.dot(t, t)
        so .= so .+ alpha .* p .+ omega .* s
        r .= s .- omega .* t

        err = mapreduce(x -> abs2(x), +, r)
        if err < solver.tol
            iterations=i
            break
        end

        rho_old = rho_new
    end

    if err > solver.tol
        error("BiCGSTAB not converged after $(solver.maxiter) iterations")
    end

    return iterations
end
