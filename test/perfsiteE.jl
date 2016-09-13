using JuLIP
using TightBinding
# using ProfileView

# test parameters
beta = 20.0        # temperature / smearing paramter
                  # 10 to 50 for room temperature
n0 = 1            # site index where we compute the site energy
NQUAD = 8         # number of contour points
DIM = (3,3,3)


TB=TightBinding

# define the model
tbm = TB.NRLTB.NRLTBModel(elem = TB.NRLTB.Si_sp, nkpoints = (0,0,0))
calc = TB.Contour.ContourCalculator(tbm, NQUAD)
# now the real system to test on
at = DIM * Atoms("Si", pbc=(false,false,false), cubic=true)
JuLIP.rattle!(at, 0.02)
TB.Contour.calibrate2!(calc, at, beta, nkpoints=(6,6,6))
@show length(at)

# @time Es, dEs = TB.Contour.site_energy(calc, at, n0, true)
# @time Es, dEs = TB.Contour.site_energy(calc, at, n0, true)
# @time Es, dEs = TB.Contour.site_energy(calc, at, n0, true);

# @code_warntype TB.Contour.site_energy(calc, at, n0, true);


Es, dEs = TB.Contour.site_energy(calc, at, n0, true)
;






# cross-over between full and sparse seems to be
# around (1,10,10) in 2D and  smaller in 3D

#
# for n in (2,4,8,16,24)
#    @show n
#
# # now go to the real system
# at = (1,n,n) * Atoms("Si", pbc=(true,true,true), cubic=false)
# JuLIP.rattle!(at, 0.02)
#
# H, M = TB.hamiltonian(tbm, at)
# Hf = full(H); Mf = full(M)
#
# rhs = rand(size(H,1))
#
# println("sparse")
# @time LU=lufact(H - 0.1im * M)
# @time LU=lufact(H - 0.1im * M)
# @time LU \ rhs
# @time LU \ rhs
# println("full")
# @time LU=lufact(Hf - 0.1im * Mf)
# @time LU=lufact(Hf - 0.1im * Mf)
# @time LU \ rhs
# @time LU \ rhs
#
# end
#




# # timing test
# println("timing with nquad = ", calc.nquad, "  (ca. 6 digits)")
# @time TB.Contour.site_energy(calc, at, n0)
# @time TB.Contour.site_energy(calc, at, n0)
# @show length(at) * tbm.norbitals