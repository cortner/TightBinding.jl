
using JuLIP
using TightBinding

beta = 10.0

TB = TightBinding
at = bulk("Si", cubic = true) * 2
rattle!(at, 0.02)
tbm = TB.NRLTB.NRLTBModel(:Si, FermiDiracSmearing(beta), orbitals = :sp, cutoff=:original)

H, M = hamiltonian(tbm, at)
H = full(H)
M = full(M)

using PyCall
@pyimport quippy

function make_quip_tb(at, Nk)
    k, weight = TB.monkhorstpackgrid(cell(at), (0, 0, Nk))
    kpoint_xml =  "<KPoints N=\"$(length(weight))\">\n" *
        join(["<point weight=\"$w\">$kx $ky $kz</point>\n" for (w, (kx, ky, kz)) in zip(weight, k)]) *
        "</KPoints>"
    println(kpoint_xml)

    xml_str = "<params>" *
        readstring(open("/Users/ortner/gits/QUIP/share/Parameters/tightbind.parms.NRL_TB.Si.xml", "r")) *
        kpoint_xml * "</params>"

    pot = quippy.Potential("TB NRL-TB", param_str=xml_str)
    quip_tb = ASECalculator(pot)
    return quip_tb
end

function tb_matrices(calc, at)
   norb = 4
   H = zeros(norb * length(at), norb  * length(at))
   M = zeros(norb * length(at), norb  * length(at))
   # dH = zeros(3, length(at), norb  * length(at), norb  * length(at))
   qsi = quippy.Atoms(at.po)
   calc.po[:calc_tb_matrices](qsi, hd=H, sd=M)
   return H, M
end


quip_tb = make_quip_tb(at, 0)
Hq, Mq = tb_matrices(quip_tb, at)

M, H = real(M), real(H)
Mq, Hq = real(Mq), real(Hq)

# normalise Hq:
Hqn = Hq * H[1,1] / Hq[1,1]
Mqn = Mq * M[1,1] / Mq[1,1]


@show vecnorm(H - Hqn, Inf)
@show vecnorm(M - Mqn, Inf)

E = sort(real(eigvals(H, M)))
Eqn = sort(real(eigvals(Hq, Mq)))
@show norm(E - Eqn, Inf)
@show norm(E - Eqn * E[1]/Eqn[1], Inf)


println("JuLIP: " )
display(round(H[1:12, 1:12], 3)); println()
println("QUIP: ")
display(round(Hqn[1:12,1:12], 3)); println()




# println("scaling factor H11/Hq11 = ", H[1,1] / Hq[1,1])
#
# println("relative error: ", vecnorm(Hqn - H, Inf) / vecnorm(H, Inf))
# println(" this suggests that there is a bug in one of the two codes")
# println(" on the other hand the first few blocks look pretty good, but")
# println(" there might be a sign error: look at the first few rows:")
#
# for n = 1:5
#    println("TB.jl: H[$(n),:] = ", round(real(H[n,:]), 3) )
#    println(" QUIP: H[$(n),:] = ", round(real(Hqn[n,:]), 3) )
# end
