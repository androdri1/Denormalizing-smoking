* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co) & Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2018.07.20
* Goal: compile information at the HH level (pseudo-panel)


if "`c(username)'"=="Paul.Rodriguez" {
	glo mainF="D:\Paul.Rodriguez\Drive\tabacoDrive\Tobacco-health-inequalities\data" //Paul
}
else {
	glo mainF="C:\Users\\`c(username)'\Dropbox\tabacoDrive\Tobacco-health-inequalities\data" // Susana
}



///////////////////////////////////////////////////////////////////////////////
********************************************************************************


use  "$mainF\ECVB2007\derived\ECVB2007_tabaco1.dta", clear 
keep 	tabacoExpenses totalExpenses alimExpenses alimExpenses1 T1_expen_m1 T2_expen_m1 T2_expen_m2 ///
		T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 ///
		T2_expen_m8 T2_expen_m9 hheq edad educ_uptoSec educ_tert female ///
		fex_calib educ_uptoPrim id_hogar ///
		persgast numnin numadu GastoCte persgastc alcoholExpenses id_depto id_loc id_ag
gen year=2007
rename id_depto depto
rename id_ag AG
replace tabacoExpenses=0 if tabacoExpenses==.
replace alcoholExpenses=0 if alcoholExpenses==.

xtile quintile=persgast, n(5)
xtile decile=persgast, n(10)

xtile quintileC=GastoCte, n(5)
xtile decileC=GastoCte, n(10)


////////////////////////////////////////////////////////////////////////////////
// Collect the data
////////////////////////////////////////////////////////////////////////////////
glo maps="C:\Users\\`c(username)'\Google Drive\Tesis_Susana\Mapas"

merge n:1 AG using "$maps\bases\ECVB07_centroids_FINAL_2.dta"
keep if _merge==3
drop _merge

egen d1=rowmin(dist1_m dist2_m dist3_m dist4_m dist5_m dist6_m dist7_m dist8_m) if sitios_d>=0.11111111
egen d2=rowmin(dist2_m dist3_m dist4_m dist5_m dist6_m dist7_m dist8_m) if sitios_d>=0.11111111
egen d3=rowmin(dist3_m dist4_m dist5_m dist6_m dist7_m dist8_m)
egen d4=rowmin(dist4_m dist5_m dist6_m dist7_m dist8_m)
egen d5=rowmin(dist5_m dist6_m dist7_m dist8_m)
egen d6=rowmin(dist6_m dist7_m dist8_m)
egen d7=rowmin(dist7_m dist8_m)
egen d8=rowmin(dist8_m)




la var dist1_m "d to the nn with cd 1" 
la var dist2_m "d to the nn with cd 2" 
la var dist3_m "d to the nn with cd 3" 
la var dist4_m "d to the nn with cd 4" 
la var dist5_m "d to the nn with cd 5" 
la var dist6_m "d to the nn with cd 6" 
la var dist7_m "d to the nn with cd 7" 
la var dist8_m "d to the nn with cd 8" 

la var d1 "d to the nn with cd >= 1" 
la var d2 "d to the nn with cd >= 2" 
la var d3 "d to the nn with cd >= 3" 
la var d4 "d to the nn with cd >= 4" 
la var d5 "d to the nn with cd >= 5" 
la var d6 "d to the nn with cd >= 6" 
la var d7 "d to the nn with cd >= 7" 
la var d8 "d to the nn with cd == 8" 

la var Man_dist	"Number of blocks nearby that have cd greater than 0"
la var sitios_d "cd of the block"

merge n:1 year using "$mainF\IPC\ipc nacional1.dta", nogen keep(master match)


////////////////////////////////////////////////////////////////////////////////
// Constant prices cigarettes
////////////////////////////////////////////////////////////////////////////////
foreach varDep in persgast totalExpenses GastoCte T2_expen_m4 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_total/100
}

foreach varDep in T2_expen_m2 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_vestuario/100
}

foreach varDep in T2_expen_m3 T2_expen_m9 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_vivienda/100
}

foreach varDep in T2_expen_m5 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_salud/100
}

// No sé si usar el ipc de transporte o de comunicaciones (se unen las dos categorías del gasto)
foreach varDep in T2_expen_m6 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*(ipc_transporte+ipc_comunicaciones)/200 if ipc_comunicaciones!=.
	replace `varDep'=`varDep'*(ipc_transporte)/100 if ipc_comunicaciones==.

}

foreach varDep in T2_expen_m7 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*(ipc_diversion)/100
}

foreach varDep in T2_expen_m8 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*(ipc_educacion)/100
}

foreach varDep in tabacoExpenses {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_tabacoAd/100
}

foreach varDep in alimExpenses alimExpenses1 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_alimentos/100
}

foreach varDep in alcoholExpenses {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_bebal/100
}
*
gen  cigprice=121*ipc_tabacoAd/122.62

tab id_loc, gen(loc_)

save "$mainF\ECVB2007\derived\ECVB2007_1.dta", replace

