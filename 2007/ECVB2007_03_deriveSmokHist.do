* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.05
* Goal: produce a dataset for ENCV2008 that has total expenditures, tabaco expenditures, income/wealth, age, education level, gender

if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Dropbox\tabaco\tabacoDrive\" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}

glo project="$dropbox\superBaseECVSusanaOtalvaro" // Susana folder
********************************************************************************
* Define individual level info
********************************************************************************
use "$project\ECVB2007\derived\ECVB2007_incomeHH.dta" , clear 
rename identificador_viv id_vivienda
rename nro_hogar id_hogar

tempfile Ingreso2007
save `Ingreso2007'

use "$project\ECVB2007\original\Persona.dta", clear
rename identificador_viv id_vivienda
rename nro_hogar id_hogar

merge n:1 id_vivienda id_hogar using  "$project\ECVB2007\derived\Vivienda_Hogar.dta" , nogen keepusing(fex_calib id_loc id_region id_clase id_segmto id_ag id_edif id_viv)
merge n:1 id_vivienda id_hogar using  `Ingreso2007' , nogen 

tostring id_vivienda, replace format(%7.0f)
tostring id_hogar , replace format(%02.0f)

egen id_hogar1=concat(id_vivienda id_hogar)
destring id_vivienda id_hogar id_hogar1, replace

gen female = e03_sexo==2 if e03_sexo!=.
gen age=e02_edad

gen student=i02_act_estudia==1 if i02_act_estudia!=9
replace i0701_niv_educ_cursa=. if i0701_niv_educ_cursa==9
replace i0702_grado_cursa=. if i0702_grado_cursa==99

gen     educ_uptoPrim = i0701_niv_educ_cursa==1 | i0701_niv_educ_cursa==2 | (i0701_niv_educ_cursa==3 & i0702_grado_cursa<12 )   if student==1 & i0701_niv_educ_cursa!=. // At most, still in grade 11
replace educ_uptoPrim = i0401_niv_educ_aprob==1 | i0401_niv_educ_aprob==2 | i0401_niv_educ_aprob==3 | (i0401_niv_educ_aprob==4 & i0402<11) if student==0 & i0401_niv_educ_aprob!=. // Did not obtained Bachillerato degree

gen     educ_uptoSec = (i0701_niv_educ_cursa==3 & i0702_grado_cursa>=12 )  if student==1 & i0701_niv_educ_cursa!=. // If still is Media, it should be above grade 11
replace educ_uptoSec = (i0401_niv_educ_aprob==4 & i0402_ult_grado_aprob>=11)  if student==0 & i0401_niv_educ_aprob!=. // obtained Bachillerato degree

gen     educ_tert = inrange(i0701_niv_educ_cursa,4,7) if student==1 & i0701_niv_educ_cursa!=.
replace educ_tert = inrange(i0401_niv_educ_aprob,5,10) if student==0 & i0401_niv_educ_aprob!=.

recode j11_cargo (1=1 "Obrero particular")(2=2 "Obrero gobierno")(3=3 "Empleado doméstico")(4=4 "Trabajador CP")(5=5 "Patron")(6/7=6 "Sin remuneracion")(8=7 "Jornalero"), g(ocupacion)
replace ocupacion =. if ocupacion==0 | ocupacion==9

gen edad=age
egen numnin = sum(edad < 18), by(id_hogar1)
egen numadu = sum(edad > 17), by(id_hogar1)
egen edad_mean = mean(edad), by(id_hogar1)
gen hheq = 1 + (0.5*(numadu-1)) + (0.3*numnin)
replace hheq = 1 if hheq<1

gen time_job=j29_tiempo_transp if j29_tiempo_transp!=. & j29_tiempo_transp!=999

* >>>>> Mathieu, decide here what is better: take HH head only, or the average for adults... !!!!!!!!!!!!!!!!!!!!!!!!!!!! >>>>>>>>>
keep if age>15
drop id_hogar
rename id_hogar1 id_hogar
format id_hogar id_vivienda %20.0f

* Make it HH level dataset .....................................................
preserve
collapse (mean) age female educ_uptoPrim educ_uptoSec educ_tert , by(id_vivienda id_hogar)
rename * hm_*
rename hm_id_vivienda id_vivienda
rename hm_id_hogar id_hogar

tempfile filo
save `filo'
restore

keep if e01_nro_orden==1 // Jefe de hogar
merge 1:1 id_vivienda id_hogar using `filo', nogen keep(master match)


********************************************************************************
* Compile household level data
********************************************************************************
merge 1:1 id_hogar using "$project\ECVB2007\derived/ECVB2007_expenditures1.dta" , nogen

gen persgast = totalExpenses/hheq
gen persgastc= GastoCte/hheq
gen persingr = incomeHH/hheq

* These are the relevant variables!
sum tabacoExpenses totalExpenses age female educ_uptoPrim educ_uptoSec educ_tert 

saveold "$project\ECVB2007\\derived\ECVB2007_tabaco1.dta", replace
