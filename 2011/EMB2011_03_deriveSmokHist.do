* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.05
* Goal: produce a dataset for ENCV2008 that has total expenditures, tabaco expenditures, income/wealth, age, education level, gender

if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Dropbox\tabaco\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}

glo project="$dropbox\superBaseECVSusanaOtalvaro" // Susana folder
********************************************************************************
* Define individual level info
********************************************************************************
use "$project\EMB2011\derived/EMB2011_incomeHH.dta" , clear 

tempfile Ingreso2011
save `Ingreso2011'


use "$project\EMB2011\derived\Gasto_NoServicios.dta", clear

rename id_hogar id_hogar1

gen female = e3==2 if e3!=.
gen age=e4

gen student=H2==1 if H2!=.

gen     educ_uptoPrim = H8_NIV==1 | H8_NIV==2 | (H5==3 & H8_SEC_ANO<12 )   if student==1 & H8_SEC_ANO!=. // At most, still in grade 11
replace educ_uptoPrim = H5==1 | H5==2 | H5==3 | (H5==4 & H8_SEC_ANO<11) if student==0 & H5!=. // Did not obtained Bachillerato degree

gen     educ_uptoSec = (H8_NIV==3 & H8_TECNI_ANO>=1 )  if student==1 & H8_TECNI_ANO!=. // If still is Media, it should be above grade 11
replace educ_uptoSec = (H5==4 & H8_TECNI_ANO>=1)  if student==0 & H5!=. // obtained Bachillerato degree

gen     educ_tert = inrange(H8_NIV,4,7) if student==1 & H8_NIV!=.
replace educ_tert = inrange(H5,5,10) if student==0 & H5!=.

destring K28, replace
recode K28 (1=1 "Obrero particular")(2=2 "Obrero gobierno")(3=3 "Empleado doméstico")(4/5=4 "Trabajador CP")(7=4 "Trabajador CP")(6=5 "Patron")(8/10=6 "Sin remuneracion")(11=7 "Jornalero"), g(ocupacion)

gen edad=age
egen numnin = sum(edad < 18), by(id_hogar1)
egen numadu = sum(edad > 17), by(id_hogar1)
egen edad_mean = mean(edad), by(id_hogar1)
gen hheq = 1 + (0.5*(numadu-1)) + (0.3*numnin)
replace hheq = 1 if hheq<1


destring K45_MINUTOS , replace 
gen time_job=K45_MINUTOS if K45_MINUTOS!=. 

gen prevalence_30=(f44==1)
gen prevalence_dia=(f44==1 & f45==1)
gen intensity=f45_cuantos if prevalence_dia==1 | prevalence_30==1

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

keep if e1==1 // Jefe de hogar
merge 1:1 id_vivienda id_hogar using `filo', nogen keep(master match)


********************************************************************************
* Compile household level data
********************************************************************************
merge 1:1 id_hogar using "$project\EMB2011\derived\EMB2011_expenditures1.dta" , nogen
merge 1:1 id_hogar using `Ingreso2011' , nogen

gen persgast = totalExpenses/hheq
gen persingr = incomeHH/hheq

* These are the relevant variables!
sum totalExpenses age female educ_uptoPrim educ_uptoSec educ_tert 

save "$project\EMB2011\derived\EMB2011_tabaco1.dta", replace
