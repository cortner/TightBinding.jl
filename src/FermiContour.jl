module FermiContour

module Transforms

include("JacobiFunc.jl")

import Base.(|>)

struct Sn{M}
    m::M
end
@inline function |>(p, s::Sn)
    w,z = p
    sn,cn,dn = JacobiFunc.jacobi(z, s.m)
    return w*cn*dn, sn
end

struct Möbius{A,B,C,D}
    a::A; b::B; c::C; d::D
end
@inline function |>(p, m::Möbius)
    w,z = p
    return w*(m.a*(m.c*z+m.d ) - m.c*(m.a*z+m.b))/(m.c*z+m.d)^2,
          (m.a*z+m.b)/(m.c*z+m.d)
end

struct Affine{A,B}
    a::A; b::B
end
@inline function |>(p, a::Affine)
    w,z = p
    return w*a.a, a.a*z+a.b
end

struct Sqrt end
@inline function |>(p, s::Sqrt)
    w,z = p
    return w/(2*sqrt(z)), sqrt(z)
end

end # module Transforms


include("JacobiFunc.jl")

export fermicontour
"""
    fermicontour(E1,E2,β,n) -> w,z

Compute a quadrature rule for evaluating the Fermi-Dirac function through contour integration.

For any `x ∈ [-E2,-E1] ∪ [E1,E2]` and any `β ∈ [0,∞]` it holds
```julia
fermidirac(x,β) ≈ sum(
    real(w*fermidirac(z,β)/(z-x))
    for (w,z) in zip(fermicontour(E1,E2,β,n)...)
)
```
and the error converges exponentially for `n → ∞`. Note that both `E1 = 0` (single interval)
and `β = Inf` (zero temperature) are valid inputs.

Reference: Lin Lin et al., Pole-Based Approximation of the Fermi-Dirac Function, Chinese Annals of Mathematics, Series B
"""
function fermicontour(E1,E2,β,n)
    m = E1^2 + π^2/β^2
    M = E2^2 + π^2/β^2

    k = (sqrt(M/m)-1)/(sqrt(M/m)+1)
    K = JacobiFunc.K(k^2)
    iK = im*JacobiFunc.iK(k^2)

    t = (-K + iK/2) .+ 4*K*(0.5:1:2*n-0.5)/(2*n)
    w = Vector{Complex{typeof(k)}}(undef, length(t))
    z = Vector{Complex{typeof(k)}}(undef, length(t))
    for i = 1:length(t)
        # Quadrature points and weights
        w[i],z[i] = (-1/(2π*im) * 4*K/n, t[i]) |>
            Transforms.Sn(k^2) |>
            Transforms.Möbius(1,1/k, -1,1/k) |>
            Transforms.Affine(-sqrt(m*M), π^2/β^2) |>
            Transforms.Sqrt() |>
            Transforms.Affine(im,0)
    end
    return w,z
end

export fermidirac
"""
    fermidirac(z,β)

Compute `1/(1+exp(β*z))` in a numerically stable way.
"""
function fermidirac(z,β)
    return abs(β*z) < log(floatmax(real(typeof(z)))) ?
            1/(1 + exp(β*z)) :
            0.5*(1-sign(real(z)))
end

end # module
