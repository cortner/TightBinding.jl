######################### Specification for NRL-TB ############################

using DelimitedFiles: readdlm

function default_orbitals(s)
   s = string(s)
   # if s == "Al"  return "spd"
   # if s == "Si"  return "sp"
   if s == "C" || s == "Si"
      return :sp
   else
      return :spd
   end
   error("unkown species in `NRLParams`")
end


# This function reads the ASCII format data files from the NRL server.
#
# The website has been lost, but a functional version remains on the Internet Archive:
# https://web.archive.org/web/20121003160812/http://cst-www.nrl.navy.mil/bind/
#
function NRLHamiltonian(s; orbitals=default_orbitals(s), cutoff=:forceshift)
#   s = string(s)
#   orbitals = string(orbitals)
   if s == :C && orbitals == :sp
      H = C_sp
   elseif s == :Si && orbitals == :sp
      H = Si_sp
   elseif s == :Si && orbitals == :spd
      H = Si_spd
   elseif s == :Al && orbitals == :spd
      H = Al_spd
   else
        # Relatively universal!
        data_dir = joinpath(dirname(pathof(SKTB)), "..", "nrl_data")
        cd(data_dir)
        fname = NRLFILENAME[s] # Lookup species -> filename

        M = readdlm(fname,skipstart=1)
        H =  NRLHamiltonian{9, Function}(9, 10,	   # norbital, nbond
                           M[3,1], M[3,2], cutoff_NRL,			# Rc, lc
                           M[7,1],		# λ
                           [M[8,1],   M[12,1],  M[12,1],  M[12,1],
                            M[16,1],  M[16,1],  M[16,1],  M[16,1], M[16,1]],        #a
                           [M[9,1],   M[13,1],  M[13,1],  M[13,1],
                            M[17,1],  M[17,1],  M[17,1],  M[17,1], M[17,1]],       	#b
                           [M[10,1],  M[14,1],  M[14,1],  M[14,1],
                            M[18,1],  M[18,1],  M[18,1],  M[18,1], M[18,1]],  	   #c
                           [M[11,1],  M[15,1],  M[15,1],  M[15,1],
                            M[19,1],  M[19,1],  M[19,1],  M[19,1], M[19,1]],       	#d

                           [M[24,1],   M[28,1],  M[32,1],  M[36,1],  M[40,1],
                            M[44,1],   M[48,1],  M[52,1],  M[56,1],  M[60,1]],		#e
                           [M[25,1],   M[29,1],  M[33,1],  M[37,1],  M[41,1],
                            M[45,1],   M[49,1],  M[53,1],  M[57,1],  M[61,1]],      #f
                           [M[26,1],   M[30,1],  M[34,1],  M[38,1],  M[42,1],
                            M[46,1],   M[50,1],  M[54,1],  M[58,1],  M[62,1]],      #g
                           [M[27,1],   M[31,1],  M[35,1],  M[39,1],  M[43,1],
                            M[47,1],   M[51,1],  M[55,1],  M[59,1],  M[63,1]],      #h

                           [M[64,1],   M[68,1],   M[72,1],   M[76,1],   M[80,1],
                            M[84,1],   M[88,1],   M[92,1],   M[96,1],   M[100,1]],  #p
                           [M[65,1],   M[69,1],   M[73,1],   M[77,1],   M[81,1],
                            M[85,1],   M[89,1],   M[93,1],   M[97,1],   M[101,1]],  #q
                           [M[66,1],   M[70,1],   M[74,1],   M[78,1],   M[82,1],
                            M[86,1],   M[90,1],   M[94,1],   M[98,1],   M[102,1]],  #r
                           [0.0,   0.0,   0.0,   0.0,   0.0,
                            0.0,   0.0,   0.0,   0.0,   0.0],     						#s
                           [M[67,1],   M[71,1],   M[75,1],   M[79,1],   M[83,1],
                            M[87,1],   M[91,1],   M[95,1],   M[99,1],   M[103,1]],  #t
                           )
   #   error("unkown species / orbitals combination in `NRLParams`")
   end

   if cutoff == :original
      H.fcut = cutoff_NRL_original
   elseif cutoff == :energyshift
      H.fcut = cutoff_NRL_Eshift
   elseif cutoff == :forceshift
      H.fcut = cutoff_NRL_Fshift
   else
      error("unknown cut-off type")
   end
   return H
end

# Lookup table between species and NRL data filename
NRLFILENAME = Dict(
   :Ag => "ag_par",
   :Al => "al_par",
   (:Al, :spd) => "al_par",
#    : => " al_par_t2g_eq_eg",
    :Au => "au_par",
    :Ba => "ba_par",
    :Ca => "ca_par",
#    :Ca => "ca_par_315",
#    :Co => "co_ferro_par",
    :Co => "co_par",
#    : => "co_para_par",
    :C => "c_par",
#    :C => "c_par.105",
    :Cr => "cr_par",
    :Cu => "cu_par",
#    :Cu => "cu_par_99",
#    :Fe => "fe_ferro_par",
#    :Fe => "fe_par",
    :Fe => "fe_para_par",
    :Ga => "ga_par",
    (:Ge, :sp)  => "ge_par.sp.125 ",
    (:Ge, :spd) => "ge_par.spd.125 ",
    :Hf => "hf_par",
    :In => "in_par",
    :Ir => "ir_par",
    :Mg => "mg_par",
    :Mn => "mn_par",
    :Mo => "mo_par",
    :Nb => "nb_par",
    :Ni => "ni_par",
    :Os => "os_par",
    :Pb => "pb_par",
    :Pd => "pd_par",
#    :Pd => "pd_par.105",
    :Pt => "pt_par",
    :Re => "re_par",
    :Rh => "rh_par",
    :Ru => "ru_par",
    :Sc => "sc_par",
    (:Si, :sp) => "si_par",
#    :Si => " si_par.125",
    (:Si, :spd) => "si_par.spd",
    :Sn => "sn_case1_par",
#    :Sn => "sn_case2_par",
    :Sr => "sr_par",
    :Ta => "ta_par",
    :Tc => "tc_par",
#    :Ti => "ti_gga_par",
#    :Ti => "ti_par",
    :Ti => "ti_par_01",
    :V => "v_par",
    :W => "w_par",
    :Y => "y_par",
    :Zr => "zr_par"
)


# Directly entered we have parameters for Si_sp; Si_spd, C_sp and Al_spd

# SILICON
# 'Si' : silicon with s&p orbitals
# reduce Rc = 12.5 to 7.5
Si_sp  =  NRLHamiltonian{4, Function}(4, 4,			    # norbital, nbond
                    12.5, 0.5, cutoff_NRL,			# Rc, lc
                    1.10356625153,		# λ
                    [-0.053233461902,  0.357859715265,  0.357859715265,  0.357859715265],  	#a
                    [-0.907642743185,  0.303647693101,  0.303647693101,  0.303647693101],   	#b
                    [-8.83084913674,   7.09222903560,   7.09222903560,   7.09222903560],     	#c
                    [56.5661321469,    -77.4785508399,  -77.4785508399,  -77.4785508399],     	#d
                    [219.560813651,    10.127687621,    -22.959028107,   10.265449263],  		#e
                    [-16.2132459618,   -4.4036811240,   1.7207707741,   4.6718241428],   		#f
                    [-15.5048968097,   0.2266767834,   1.4191307713,   -2.2161562721],   		#g
                    [1.26439940008,   0.92267194054,   1.03136916513,   1.11134828469],  		#h
                    [1.0, 		     0.0,     		 1.0, 			 1.0],			    	#p
                    [5.157587186,     8.873646665,     11.250489009,   -692.184231145],    	#q
                    [0.660009308,     -16.240770475,  -1.1701322929,    396.153248956],    	#r
                    [-0.0815441307,   5.1822969049,   -1.0591485021,   -13.8172106270],        #s
                    [1.10814448800,   1.24065238343,   1.13762861032,   1.57248559510],  		#t
                   )


# SILICON
# 'Si' : silicon with s&p&d orbitals  :BUT: ignore d-d orbital interactions
# reduce Rc = 12.5 to 7.5
Si_spd  =  NRLHamiltonian{9, Function}(9, 10,			# norbital, nbond
                     12.5, 0.5, cutoff_NRL,			# Rc, lc
                     1.1108,		# λ
                     [-0.0555,  0.4127,   0.4127,   0.4127,
                      0.9691,   0.9691,   0.9691,   0.9691,  0.9691],         	#a
                     [-1.1131,  -0.0907,  -0.0907,  -0.0907,
                      -0.9151,  -0.9151,  -0.9151,  -0.9151, -0.9151],       	#b
                     [-7.3201,  5.3155,   5.3155,   5.3155,
                      -5.9743,  -5.9743,  -5.9743,  -5.9743, -5.9743],  	    #c
                     [74.8905,  -44.0417, -44.0417, -44.0417,
                      602.0289, 602.0289, 602.0289, 602.0289, 602.0289],       	#d

                     [234.6937,   9.5555,  -22.6782,   -1.5942,  -7571.4416,
                      -1.8087,   0.8933,  0.0,   0.0,  0.0],				    #e
                     [-18.6013,   -4.1279,   1.3611,   4.7914,   2.2354,
                      -3.4695,   0.1058,  0.0,  0.0,  0.0],                     #f
                     [-15.0266,   0.2499,    1.3879,   -1.5693,   7.0122,
                      -7.7637,   -0.0224, 0.0,  0.0,  0.0],                     #g
                     [1.2502,    0.8761,    1.01655,    1.1030,   1.6234,
                      1.6294,   0.8217,   0.0,  0.0,  0.0],                     #h

                     [1.0,   0.0,  1.0,   1.0,   0.0,
                      0.0,   0.0,  1.0,   1.0,   1.0],		                    #p
                     [2.4394,   -12.0027,  13.9608,   188.0012,   11.4724,
                      -0.6071,  -2.1340,   0.0,  0.0,  0.0],                    #q
                     [0.9091,   -14.6860,  -1.1961,  -143.3625,  -0.4454,
                      0.05789,  -0.5209,   0.0,  0.0,  0.0],                    #r
                     [-0.0749,   6.1856,   -1.2606,   33.5043,   -0.5838,
                      0.0221,   -0.0948,   0.0,  0.0,  0.0],                    #s
                     [1.0590,   1.2218,    1.1118,    1.4340,   1.0598,
                      0.8130,   1.0580,    0.0,  0.0,  0.0],                    #t
                    )




# CARBON
# 'C' : carbon with s&p orbitals
# reduce Rc = 10.5 to 6.0
C_sp  =  NRLHamiltonian{4, Function}( 4, 4,			    # norbital, nbond
                    10.5, 0.5, cutoff_NRL,			# Rc, lc
                    1.59901905594,		# λ
                    [-0.102789972814,  0.542619178314,  0.542619178314,  0.542619178314],  	#a
                    [-1.62604640052,   2.73454062799,   2.73454062799,   2.73454062799],   	#b
                    [-178.884826119,  -67.139709883,   -67.139709883,  -67.139709883],     	#c
                    [4516.11342028,    438.52883145,   438.52883145,   438.52883145],      	#d
                    [74.0837449667,   -7.9172955767,   -5.7016933899,   24.9104111573],  		#e
                    [-18.3225697598,   3.6163510241,   1.0450894823,   -5.0603652530],   		#f
                    [-12.5253007169,   1.0416715714,   1.5062731505,   -3.6844386855],   		#g
                    [1.41100521808,   1.16878908431,   1.13627440135,   1.36548919302],  		#h
                    [1.0,             0.0,             1.0,             1.0],              	#p
                    [0.18525064246,   1.85250642463,   -1.29666913067,   0.74092406925],   	#q
                    [1.56010486948,   -2.50183774417,   0.28270660019,   -0.07310263856],  	#r
                    [-0.308751658739,   0.178540723033,   -0.022234235553,   0.016694077196],  #s
                    [1.13700564649,   1.12900344616,   0.76177690688,   1.02148246334],  		#t
                   )



# ALUMINIUM
# 'Al' : Aluminum with s&p&d orbitals
# reduce Rc = 16.5 to 9.5
Al_spd  =  NRLHamiltonian{9, Function}(9, 10,			        # norbital, nbond
                     16.5, 0.5, cutoff_NRL,			# Rc, lc
                     1.108515601511,		# λ
                     [-0.0368090795665,  0.394060871550,  0.394060871550,  0.394060871550,
                      1.03732517161,  1.03732517161,  1.03732517161, 1.03732517161, 1.03732517161],         	#a
                     [1.41121601477,  0.996479629379,   0.996479629379,  0.996479629379,
                      2.25910876474,  2.25910876474,  2.25910876474,  2.25910876474,  2.25910876474],       	#b
                     [13.7933378593,   7.02388797078,    7.02388797078,   7.02388797078,
                      -34.3716752929,  -34.3716752929,  -34.3716752929,  -34.3716752929,  -34.3716752929],  	#c
                     [-150.317796096,   -77.7996182049,  -77.7996182049,  -77.7996182049,
                      293.811629762,  293.811629762,  293.811629762,  293.811629762,  293.811629762],       	#d

                     [-45.1824404773,   11.1265443008,  -27.7049616756,   7.48992761254,  -29.0814831341,
                      0.843008479887,   35.6686973234,  -8939.68482560,   -55.7867097600,  41.7418125111],      #e
                     [19.0441568385,   -4.74833564810,   1.14888504976,   3.01675751048,   12.2929753319,
                      -1.52618018997,  -8.20900836372,   730.518353338,   0.853972348751,  -12.0915149851],     #f
                     [-2.81748968422,   0.273179395549,    1.33493438322,   -1.27543114992,   -1.75865704211,
                      0.378014000015,   -0.777295830901,   282.319390496,   2.30786449075,    0.905794614748],  #g
                     [1.05012810116,    0.880778921750,    0.983097680652,    1.01546352470,    1.03433851149,
                      0.964916606335,   1.08355725127,    1.35770591641,    0.997222907112,    0.898850379448], #h

                     [-20.9441522845,   -13.0267838833,   -13.7830192613,   560.641345191,   -103.077140819,
                      20.8403415336,   23.9108771944,   -295.728688028,   -17.2027621079,   -42.9299886946],    #p
                     [17.5240112799,   7.92017585690,   5.15785376743,   -215.309856616,   33.5869977281,
                      -6.65151229760,   -5.86527866863,   80.7470264719,   -6.54916621891,   23.2260645871],    #q
                     [-1.33002925172,   -0.523366384472,   -1.08061004452,   24.2658321255,   -1.86799882707,
                      0.195368101148,   0.725698443913,   -2.93711938026,   1.11096322734,   -0.538315401068],  #r
                     [0.0,   0.0,   0.0,   0.0,   0.0,
                      0.0,   0.0,   0.0,   0.0,   0.0],     													#s
                     [1.06584516722,   0.943623371617,   0.915429215594,   1.17753799190,   0.988337965212,
                      0.873041790591,   0.999293973116,   1.02005972107,   1.01466433826,   1.14341718458],     #t
                    )
