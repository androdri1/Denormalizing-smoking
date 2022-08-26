* Author: Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2019.02.05
* Goal: Illustrate the commuting problem in the city of Bogotá in 2011

if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Drive\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}


if "`c(username)'"=="susana.otalvaro" {
	glo maps = "C:\Users\\`c(username)'\Google Drive\Tesis_Susana\Mapas"
}

glo project="$dropbox\Tobacco-health-inequalities" // Susana's folder
********************************************************************************
* Define individual level info
********************************************************************************
use "$project\data\EMB2011\derived\Gasto_NoServicios.dta", clear
gen year=2011

destring K45_MINUTOS K44* K1, replace 
gen 	time_job 	= K45_MINUTOS if K45_MINUTOS!=. 
gen 	time_study 	= H21 if H21!=. 

gen 	time_commuting = time_job if time_job!=. 
replace time_commuting = time_commuting + time_study if time_study!=.
replace time_commuting = time_study if time_commuting==. & time_study!=.
replace time_commuting = time_commuting /60
su time_commuting, d 
sca p99 = r(p99)
replace time_commuting= p99 if time_commuting>p99 & time_commuting!=. 

la var time_commuting "Commuting time (hours)"

gen 	transport_job = .
replace transport_job = 2 if K44B==1 | K44I==1
replace transport_job = 1 if K44A==1
replace transport_job = 5 if K44F==1 & transport_job==.
replace transport_job = 4 if K44E==1
replace transport_job = 3 if K44C==1 | K44D==1 | K44G==1
replace transport_job = 6 if K44H==1 & transport_job==.
replace transport_job = 0 if transport_job==. & K44J==1

gen 	transport_study = .
replace transport_study = 2 if H20B==1 | H20I==1 
replace transport_study = 1 if H20A==1 
replace transport_study = 5 if H20F==1 & transport_study==. 
replace transport_study = 4 if H20E==1 
replace transport_study = 3 if H20C==1 | H20D==1 | H20G==1 
replace transport_study = 6 if H20H==1 & transport_study==. 
replace transport_study = 0 if transport_study==. & H20J==1


gen 	transport = transport_job 	if time_commuting!=. & transport_job!=. & transport_study==. 
replace	transport = transport_job 	if time_commuting!=. & transport_job!=. & transport_study!=. & K1==1
replace transport = transport_study if time_commuting!=. & transport_study!=. & transport_job==.
replace	transport = transport_study	if time_commuting!=. & transport_job!=. & transport_study!=. & K1==3


la def transporte 1 "Transmilenio" 2 "Bus" 3 "Auto" 4 "Moto" 5 "Bicycle" 6 "Walking" 0 "Other"
la val transport_job transporte
la val transport_study transporte
la val transport transporte

gen 	distance_commuting = .
replace distance_commuting = time_commuting*35 		if transport==1
replace distance_commuting = time_commuting*4.5 	if transport==6
replace distance_commuting = time_commuting*12.5 	if transport==5
replace distance_commuting = time_commuting*20 		if transport==2
replace distance_commuting = time_commuting*27.5 	if transport==3
replace distance_commuting = time_commuting*32.5 	if transport==4
replace distance_commuting = time_commuting*19.5 	if transport==0
su distance_commuting, d
sca p90_d = r(p90)
replace distance_commuting= p90_d if distance_commuting>p90_d & distance_commuting!=. 

egen com_time = mean(time_commuting), by(id_hogar)
egen com_dist = mean(distance_commuting), by(id_hogar)

keep if e1==1 // Jefe de hogar

keep year id_hogar com_dist com_time distance_commuting time_commuting

tempfile transport2011
save `transport2011'

use "$project\data\ECVB2007\derived\Gasto_SaludEduc.dta", clear
gen year=2007
replace j29_tiempo_transp = . if j29_tiempo_transp==999
replace g11_tiempo_gast_instit = . if g11_tiempo_gast_instit==999
replace j28_transp_trab = . if j28_transp_trab==99 

recode j28_transp_trab (1/2=2 "Bus")(3=6 "Walking")(4=1 "Transmilenio")(5/7=3 "Auto")(8/9=0 "Other")(10=4 "Moto or bike")(11=0)(12=.), g(transport1)

gen 	transport = . 
replace transport = transport1 if transport1!=. & g11_tiempo_gast_instit==. & j29_tiempo_transp!=.
replace transport = 6 if g11_tiempo_gast_instit>0 & g11_tiempo_gast_instit!=. & transport==.

rename j29_tiempo_transp 		time_job 
rename g11_tiempo_gast_instit 	time_study

gen 	time_commuting = time_job if time_job!=. 
replace time_commuting = time_commuting + time_study if time_study!=.
replace time_commuting = time_study if time_commuting==. & time_study!=. 
replace time_commuting = time_commuting /60
su time_commuting, d 
sca p99 = r(p99)
replace time_commuting= p99 if time_commuting>p99 & time_commuting!=. 

la var time_commuting "Commuting time (hours)"

la def transporte 1 "Transmilenio" 2 "Bus" 3 "Auto" 4 "Moto or bike" 6 "Walking" 0 "Other"
la val transport transporte

gen 	distance_commuting = .
replace distance_commuting = time_commuting*35 		if transport==1
replace distance_commuting = time_commuting*4.5 	if transport==6
replace distance_commuting = time_commuting*20 		if transport==2
replace distance_commuting = time_commuting*27.5 	if transport==3
replace distance_commuting = time_commuting*22.5 	if transport==4
replace distance_commuting = time_commuting*19.5 	if transport==0
su distance_commuting, d
sca p90_d = r(p90)
replace distance_commuting= p90_d if distance_commuting>p90_d & distance_commuting!=. 

egen com_time = mean(time_commuting), by(id_hogar1)
egen com_dist = mean(distance_commuting), by(id_hogar1)

keep if orden==1 // Jefe de hogar

keep year id_hogar1 com_dist com_time distance_commuting time_commuting
rename id_hogar1 id_hogar

append using `transport2011'


save "$project\data\ECVB2007\derived\Transport.dta", replace
save "$maps\InputData\Finales\Hogares\Transport.dta", replace

