
# test parameters
beta = 20.0        # temperature / smearing paramter
                     # 10 to 50 for room temperature
n0 = 1            # site index where we compute the site energy
NQUAD = (4, 6, 8, 10)     # number of contour points
DIM = (1,2,3)

TB=TightBinding

# define the model
tbm = TB.NRLTB.NRLTBModel(elem = TB.NRLTB.Si_sp, nkpoints = (0,0,0))
calc = TB.Contour.ContourCalculator(tbm, 0)

# use a mini-system to pre-compute the Fermi-level and energy bounds
print("calibrating . . . ")
at = Atoms("Si", pbc=(true,true,true))
TB.Contour.calibrate!(calc, at, beta, nkpoints=(6,6,6))
println("done.")

# now the real system to test on
at = DIM * Atoms("Si", pbc=(false,false,false), cubic=true)
JuLIP.rattle!(at, 0.02)
# TB.Contour.calibrate2!(calc, at, beta, nkpoints=(6,6,6))
@show length(at)


# compute the site energy the old way
Eold = TB.site_energy(tbm, at, n0)
println("Old Site Energy (via spectral decomposition)")
println(Eold)

println("Testing that the old site energies sum to total energy")
Etot = TB.energy(tbm, at)
Es = [TB.site_energy(tbm, at, n) for n = 1:length(at)]
@show Etot - sum(Es)
@assert abs(Etot - sum(Es)) < 1e-10

# now try the new one
println("Convergence of Contour integral implementation")
for nquad in NQUAD
   calc.nquad = nquad
   Enew, _ = TB.Contour.site_energy(calc, at, n0)
   println("nquad = ", nquad, "; error = ", abs(Enew - Eold))
end


println("Test consistency of site forces")

calc.nquad = 10
X = copy( positions(at) |> mat )
Es, dEs = TB.Contour.site_energy(calc, at, n0, true)
dEs = dEs |> mat
dEsh = []

println(" p  |  error ")
for p = 2:9
   h = 0.1^p
   dEsh = zeros(dEs)
   for n = 1:length(X)
      X[n] += h
      set_positions!(at, X)
      Esh, _ = TB.Contour.site_energy(calc,at,n0)
      dEsh[n] = (Esh - Es) / h
      X[n] -= h
   end
   println( " ", p, " | ", vecnorm(dEs-dEsh, Inf) )
end