* Author: Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2018.07.20
* Goal: compile information at the HH level (pseudo-panel)


if "`c(username)'"=="paul.rodriguez" {
	glo mainF="D:\Paul.Rodriguez\Dropbox\tabaco\tabacoDrive\superBaseECVSusanaOtalvaro\" //Paul
}
else {
	glo mainF="C:\Users\\`c(username)'\Dropbox\tabacoDrive\Tobacco-health-inequalities\data" // Susana
}

if "`c(username)'"=="susana.otalvaro" {
	glo maps = "C:\Users\\`c(username)'\Google Drive\Tesis_Susana\Mapas"
}
else {
	glo maps = "D:\Paul.Rodriguez\Dropbox\tabaco\tabacoDrive\tesisSusana\Mapas"
}

///////////////////////////////////////////////////////////////////////////////
********************************************************************************
use  "$mainF\ECVB2007\derived\ECVB2007_tabaco1.dta", clear 
keep 	tabacoExpenses totalExpenses alimExpenses alimExpenses1 T1_expen_m1 ///
		T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 ///
		T2_expen_m7 T2_expen_m8 T2_expen_m9 hheq edad educ_uptoSec educ_tert female ///
		fex_calib educ_uptoPrim id_hogar persgast numnin numadu alcoholExpenses ///
		id_loc id_depto id_ag incomeHH incomeHH1 incomeHH2 incomeHH3 incomeHH4 ///
		incomeHH5 time_job persingr ocupacion strata edad_mean ///
		hm_age hm_female hm_educ_uptoPrim hm_educ_uptoSec hm_educ_tert
		
gen year=2007
rename id_depto depto
rename id_ag AG
replace tabacoExpenses=0 if tabacoExpenses==.
replace alcoholExpenses=0 if alcoholExpenses==.

merge n:1 AG using "$maps\bases\ECVB07_centroids_FINAL_2.dta" , nogen

xtile quintile=persgast, n(5)
xtile decile=persgast, n(10)
xtile quint_income=persingr, n(5)



tempfile emb2007
save `emb2007'

///////////////////////////////////////////////////////////////////////////////
********************************************************************************
use  "$mainF\EMB2011\derived\EMB2011_tabaco1.dta", clear 
keep 	totalExpenses alimExpenses T1_expen_m1 T2_expen_m1 T2_expen_m2 ///
		T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 ///
		T2_expen_m8 T2_expen_m9 hheq edad educ_uptoSec educ_tert female ///
		fex_c educ_uptoPrim id_hogar incomeHH incomeHH1 incomeHH2 incomeHH3 incomeHH4 ///
		persgast numnin numadu  e9_depto localidad sector1 seccion1 manzana1 ///
		x_centroids y_centroids OBJECTID SETR_CLSE_ SECR_SETR_ ///
		CPOB_SECR_ SETU_CPOB_ SECU_SETU_ SECU_SETU1 SECU_SET_1 ///
		SECU_SECU_ MANZ_CCDGO MANZ_CAG MANZ_NAREA MANZ_CSMBL ///
		MANZ_NANO MANZ_CCNCT MANZ_CESTR SHAPE_Leng SHAPE_Area time_job ///
		prevalence_30 prevalence_dia intensity persingr f44 ocupacion strata edad_mean ///
		hm_age hm_female hm_educ_uptoPrim hm_educ_uptoSec hm_educ_tert

gen  year=2011
rename fex_c fex_calib 
rename e9_depto depto 
rename MANZ_CAG AG
rename localidad id_loc

replace T2_expen_m1=0 if T2_expen_m1==.
gen 	tabacoExpenses = .
replace tabacoExpenses = T2_expen_m1*(0.56) if T2_expen_m1!=. 

gen 	alcoholExpenses = . 
replace alcoholExpenses = T2_expen_m1*(0.44) if T2_expen_m1!=. 

xtile quintile=persgast, n(5)
xtile decile=persgast, n(10)
xtile quint_income=persingr, n(5)
 
append using `emb2007'

order 	year id_hogar id_loc AG x_centroids y_centroids SHAPE_Leng SHAPE_Area ///
		sector1 seccion1 manzana1 OBJECTID SETR_CLSE_ SECR_SETR_ ///
		CPOB_SECR_ SETU_CPOB_ SECU_SETU_ SECU_SETU1 SECU_SET_1 ///
		SECU_SECU_ MANZ_CCDGO MANZ_NAREA MANZ_CSMBL MANZ_NANO MANZ_CCNCT  

sort AG year		


save "$mainF\EMB2011\derived\Bogota_completo.dta", replace
save "$maps\InputData\Finales\Bogota_completo.dta", replace

preserve
keep AG year totalExpenses alimExpenses alimExpenses1 T1_expen_m1 T2_expen_m1 T2_expen_m2 ///
		T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 ///
		T2_expen_m8 T2_expen_m9  id_hogar tabacoExpenses alcoholExpenses ocupacion strata edad_mean ///
		hm_age hm_female hm_educ_uptoPrim hm_educ_uptoSec hm_educ_tert

rename AG MANZ_CAG 

save "$maps\InputData\Finales\Hogares\Correg_Expenditure.dta", replace
restore

preserve 
keep id_hogar year quint_income prevalence_dia prevalence_30 persingr persgast intensity incomeHH5 incomeHH4 incomeHH3 incomeHH2 incomeHH1 incomeHH time_job
save "$mainF\EMB2011\derived\income.dta", replace 
restore

/*
preserve
rename AG MANZ_CAG
gen id_unit = _n
keep if year==2011
export delimited 	MANZ_CAG MANZ_CCDGO MANZ_NAREA MANZ_CSMBL MANZ_NANO ///
					MANZ_CCNCT MANZ_CESTR SHAPE_Leng SHAPE_Area ///
					x_* y_* using "$maps\InputData\Finales\BaseEMB2011.csv", nolabel replace
restore

preserve
rename AG MANZ_CAG
gen id_unit = _n
keep if year==2007
export delimited 	MANZ_CAG MANZ_CCDGO MANZ_NAREA MANZ_CSMBL MANZ_NANO ///
					MANZ_CCNCT MANZ_CESTR SHAPE_Leng SHAPE_Area ///
					x_* y_* using "$maps\InputData\Finales\BaseEMB2007.csv", nolabel replace
restore
*/


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

use "$maps\InputData\Finales\Bogota_centroids_FINALabc.dta", clear
drop  T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m6 T2_expen_m7 T2_expen_m9 T2_expen_m5 T2_expen_m8 tabacoExpenses alcoholExpenses
cap drop NEAR_DI*
merge n:1 year using "$mainF\IPC\ipc nacional1.dta", nogen keep(master match)

replace informal=0 if informal==.
replace formal=0 if formal==.

cap drop inf_density1 for_density1 sitios
gen inf_density1=(informal/sitios) if informal!=.
gen for_density1=(formal/sitios) if formal!=.

replace inf_density1=0 if inf_density1==. 
replace for_density1=0 if for_density1==. 
*destring SECU_SETU SECU_SECU_ , replace
*rename AG MANZ_CAG

merge n:1 year MANZ_CAG id_hogar using "$maps\InputData\Finales\Hogares\Correg_Expenditure.dta"
drop if _merge==2  // 1.8%
drop _merge 

drop SETR_CLSE_ SECR_SETR_  SECU_SETU_ SECU_SECU_
merge n:1 year MANZ_CAG using "$maps\InputData\Finales\Hogares\Dist_completa.dta", nogen

replace NEAR_DIST = NEAR_DIST+0.0000001 if NEAR_DIST==0

replace NEAR_DENS = NEAR_DENS+0.0000001 if NEAR_DENS==0



////////////////////////////////////////////////////////////////////////////////
// Constant prices cigarettes
////////////////////////////////////////////////////////////////////////////////
foreach varDep in persgast totalExpenses T2_expen_m4 {
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

foreach varDep in alimExpenses {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_alimentos/100
}

foreach varDep in alcoholExpenses {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_bebal/100
}
*
gen  cigprice=121*ipc_tabacoAd/95.78 

rename MANZ_CAG AG

tab id_loc, gen(loc_)
sort AG year
drop depto

save "$mainF\EMB2011\derived\EMB2011_1.dta", replace

