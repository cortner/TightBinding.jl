

# 2D geometry NRL: cross-over is at 6% sparsity!!!
# 3D, NRL: ca. 0.06 as well
for N = 2:6
   at = (N,N,N) * bulk("Si", pbc=false, cubic=true)
   tbm = SKTB.NRLTB.NRLTBModel(:Si, FermiDiracSmearing(1.0))
   H, M = hamiltonian(tbm, at)
   Hs = sparse(H)
   println("N = $N | sparsity: $(nnz(Hs)/length(Hs)) %")
   println("  full LU:")
   @time lufact(H.data)
   @time lufact(H.data)
   @time lufact(H.data)
   println("  sparse LU:")
   @time lufact(Hs)
   @time lufact(Hs)
   @time lufact(Hs)
end
