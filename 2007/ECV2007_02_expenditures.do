* Author: Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2018.08.20
* Goal: produce total income of the HH for the ENCV2011 (no imputation or outlier analysis here!)


if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}


// Programa para limpiar variables
cap program drop cleanvars
program define cleanvars , rclass
	args lista
	disp "Cleaning! `lista'"
	foreach varDep in `lista'	{
		destring `varDep', replace
		* For yes and no questions, set the "no"s as 0s
		cap recode `varDep' (2=0) (8 9 99 98 =.), g(_`varDep')
		cap drop `varDep'
		cap rename _`varDep' `varDep'
	}
end
////////////////////////////////////////////////////////////////////////////////
// Mean imputation for expenditures made individually
////////////////////////////////////////////////////////////////////////////////
cap program drop meanimput
program define meanimput , rclass
	args lista
	disp "Imputation of mean values at the individual level"
	foreach varDep in `lista' {
		cap gen nomiss_`varDep'=`varDep' if (`varDep'==98 | `varDep'==99)
		cap egen mean_`varDep'=mean(nomiss_`varDep'), by(b04012)
		cap replace `varDep'=mean_`varDep' if (`varDep'==98 | `varDep'==99)
		cap egen hogar_`varDep'=total(`varDep') if `varDep'!=., by (id_hogar)
		cap drop nomiss_`varDep' mean_`varDep' `varDep'
		cap rename hogar_`varDep' `varDep'
	}
end 
////////////////////////////////////////////////////////////////////////////////
// Mean imputation for expenditures made at the household level
////////////////////////////////////////////////////////////////////////////////
cap program drop meanimput_h
program define meanimput_h , rclass
	args lista
	disp "Imputation of mean values at the household level"
	foreach varDep in `lista' {
		cap gen nomiss_`varDep'=`varDep' if (`varDep'!=98 & `varDep'!=99 & `varDep'!=.) 
		cap egen mean_`varDep'=mean(nomiss_`varDep'), by(b04012)
		cap replace `varDep'=mean_`varDep' if (`varDep'==98 | `varDep'==99)
		cap drop nomiss_`varDep' mean_`varDep'
	}
end 


use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\ViviendaGEO.dta", clear 

rename identificador_viv id_vivienda
rename nro_hogar id_hogar
rename b040101_serv_energ_estrato b04012
destring id_vivienda b04012, replace

la def estrato 0 "Sin estrato (Pirata)" 1 "Bajo-Bajo" 2 "Bajo" 3 "Medio-Bajo" 4 "Medio" 5 "Medio-Alto" 6 "Alto" 9 "No sabe, planta"
la val b04012 estrato

tempfile viviendas1
save `viviendas1'

use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Hogar.dta", clear 
rename identificador_viv id_vivienda
rename nro_hogar id_hogar

tostring id_vivienda, replace format(%7.0f)
tostring id_hogar , replace format(%02.0f)

egen id_hogar1=concat(id_vivienda id_hogar)
destring id_vivienda id_hogar id_hogar1, replace

merge n:1 id_vivienda using `viviendas1', nogen 

tempfile viviendas
save `viviendas'

save "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Vivienda_Hogar.dta", replace

* Members of the household individual expenditures imputation*****************************

if 1==1{
// GASTOS INDIVIDUALES: EDUCACION 
**** EDUCACION MENORES 
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Persona.dta", clear
rename identificador_viv id_vivienda
rename nro_hogar id_hogar
rename e01_nro_orden orden 
destring id_vivienda , replace 
format id_vivienda  %20.0f

tostring id_vivienda, replace format(%7.0f)
tostring id_hogar , replace format(%02.0f)

egen id_hogar1=concat(id_vivienda id_hogar)
destring id_vivienda id_hogar id_hogar1, replace

merge n:1 id_hogar1 using `viviendas', nogen

cleanvars 	"g12_pag_matr g13_pago_unif g14_pago_utiles g15_comp_util_fuera_inst g16_pension_cuota g17_ruta g18_alimentacion g19_otro_pago g20_almuerzo_gratis g21_recibe_med_nuev g22_recibe_onces"
sort id_vivienda id_hogar orden
meanimput "g1201_valor g1301_valor g1401_valor g1501_valor g1601_valor g1701_valor g1801_valor g1901_valor g2001_cuanto_paga_dia g2002_cuanto_compra  g2101_cuanto_paga_dia g2102_cuanto_compra  g2201_cuanto_paga_dia g2202_cuanto_compra "

cleanvars 	"i16_pago_matr i17_uniforme i18_utiles i19_complementarios i20_bono_vol i21_pension i22_transp_escol i23_alimentacion i24_util_mes_ant i25_otros_pagos i26_recibio_subsidio i30_rec_beca_ano i33_rec_cred_ano"

***********************************************o*********************************
// Subsidios y Becas a la Educacion mensualizados
foreach x in  i2802_frecuencia i2804_frecuencia i3102_frecuencia i3104_frecuencia i3402_frecuencia{
replace `x'=6 	if `x'==3
replace `x'=12 	if `x'==4 
}

// Subsidios en dinero o especie
replace i2801_valor=i2801_valor/i2802_frecuencia if i2802_frecuencia!=. & i2801_valor!=0 & i2801_valor!=.
replace i2803_valor=i2803_valor/i2804_frecuencia if i2804_frecuencia!=. & i2803_valor!=0 & i2803_valor!=.

// Beca en dinero o en especie
replace i3101_valor=i3101_valor/i3102_frecuencia if i3102_frecuencia!=. & i3101_valor!=0 & i3101_valor!=.
replace i3103_valor=i3103_valor/i3104_frecuencia if i3104_frecuencia!=. & i3103_valor!=0 & i3103_valor!=.

// Credito educativo
replace i3401_valor=i3401_valor/i3402_frecuencia if i3402_frecuencia!=. & i3401_valor!=0 & i3401_valor!=.

sort id_vivienda id_hogar orden
meanimput "i1601_valor i1701_valor i1801_valor i1901_valor i2001_valor i2101_valor i2201_valor i2301_valor i2401_valor i2501_valor i2801_valor i2803_valor i3101_valor i3103_valor i3401_valor"

tempfile Educ
save `Educ'

foreach vard in g1201_valor g1301_valor g1401_valor g1501_valor g1601_valor g1701_valor g1801_valor g1901_valor g2001_cuanto_paga_dia g2002_cuanto_compra  g2101_cuanto_paga_dia g2102_cuanto_compra  g2201_cuanto_paga_dia g2202_cuanto_compra i1601_valor i1701_valor i1801_valor i1901_valor i2001_valor i2101_valor i2201_valor i2301_valor i2401_valor i2501_valor i2801_valor i2803_valor i3101_valor i3103_valor i3401_valor{ 
	replace `vard'=0 if g12_pag_matr==. & g13_pago_unif==. & g14_pago_utiles==. & g15_comp_util_fuera_inst==. & g16_pension_cuota==. & g17_ruta==. & g18_alimentacion==. & g19_otro_pago==. & g20_almuerzo_gratis==. & g21_recibe_med_nuev==. & g22_recibe_onces==. & i16_pago_matr==. & i17_uniforme==. & i18_utiles==. & i19_complementarios==. & i20_bono_vol==. & i21_pension==. & i22_transp_escol==. & i23_alimentacion==. & i24_util_mes_ant==. & i25_otros_pagos==. & i26_recibio_subsidio==. & i30_rec_beca_ano==. & i33_rec_cred_ano==.
}
save "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Gasto_Educ.dta", replace



// GASTOS INDIVIDUALES: SALUD
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Persona.dta", clear
rename identificador_viv id_vivienda
rename nro_hogar id_hogar
rename e01_nro_orden orden 

format id_vivienda id_hogar %20.0f
tostring id_vivienda, replace format(%7.0f)
tostring id_hogar , replace format(%02.0f)

egen id_hogar1=concat(id_vivienda id_hogar)
destring id_vivienda id_hogar id_hogar1, replace

merge n:1 id_hogar1 using `viviendas', nogen // Todos hicieron match

rename f01_afilia_seg_soc f01
 
gen 	f0801=.
replace f0801=0 if f0805_ningun_plan==1
replace f0801=1 if (f0801_poliza_hosp_cir!=. | f0802_med_prepagada!=. | f0803_plan_complem_eps!=. | f0804_otro_plan_seg!=.) & f0805_ningun_plan!=1
la var f0801 "Plan de salud complementario"

gen 	f0501=.
replace f0501=0 if f06_quien_paga_salud==. | f06_quien_paga_salud==8
replace f0501=1 if f06_quien_paga_salud==1 | f06_quien_paga_salud==2 | f06_quien_paga_salud==3 | f06_quien_paga_salud==4 | f06_quien_paga_salud==5 | f06_quien_paga_salud==7
la var f0501 "Plan básico de salud"

cleanvars "f01 f0501 f0801 f24 f19_hosp_ult_12meses f34_med_prepag f35_cons_med f36_trat_odont f37_vacunas f38_medicamentos f39_lab_clinico f40_transporte f41_rehabilitacion f42_med_alternat f43_lentes_aparatos f44_pago_cirugias" // 

meanimput "f07_pago_afilia f09_pago_plan_salud f3401_valor f3501_valor f3601_valor f3701_valor_vacunas f3801_valor_med f3901_valor_lab_clin f4001_valor_med f4101_valor_med f4201_valor_alternat f21_pago_tot_hosp f4301_valor_lent_ap f4401_valor_cirugias"

replace f21_pago_tot_hosp=f21_pago_tot_hosp*(1/12) if f19_hosp_ult_12meses==1 & f21_pago_tot_hosp!=.
replace f4301_valor_lent_ap=f4301_valor_lent_ap*(1/12) if f43_lentes_aparatos==1 & f4301_valor_lent_ap!=.
replace f4401_valor_cirugias=f4401_valor_cirugias*(1/12) if f44_pago_cirugias==1 & f4401_valor_cirugias!=.

// Ultimos 30 días
** f07_pago_afilia f09_pago_plan_salud f3401_valor f3501_valor f3601_valor f3701_valor_vacunas f3801_valor_med f3901_valor_lab_clin f4001_valor_med f4101_valor_med f4201_valor_alternat  

// 12 meses 
** f21_pago_tot_hosp f4301_valor_lent_ap f4401_valor_cirugias

merge 1:1 id_hogar1 orden using "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Gasto_Educ.dta" , nogen

save "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Gasto_SaludEduc.dta", replace
}
*

// GASTOS DEL HOGAR: ALIMENTOS, ALCOHOL Y TABACO, VESTIDO Y CALZADO, SERVICIOS DEL HOGAR, 
// MUEBLES Y ENSERES, TRANSPORTE Y COMUNICACIONES, SERVICIOS CULTURALES Y ENTRETENIMIENTO,
// SERVICIOS PERSONALES Y OTROS. 
if 1==1{
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos.dta", clear
rename identificador_viv id_vivienda
rename nro_hogar id_hogar

tostring id_vivienda, replace format(%7.0f)
tostring id_hogar , replace format(%02.0f)

egen id_hogar1=concat(id_vivienda id_hogar)
destring id_vivienda id_hogar id_hogar1, replace

rename l03_compra compra
rename l06_adq_sin_compra adq_no_com
rename l04_val_pagado vr_compra
rename l07_val_estimado vr_estimado
rename l02_cod_articulo articulos

cleanvars "compra adq_no_com"

replace vr_compra=. if compra!=1	
replace vr_compra=. if vr_compra==98 | vr_compra==99 // Missings for all
replace vr_estimado=. if adq_no_com!=1	
replace vr_estimado=. if vr_estimado==98 | vr_estimado==99 // Missings for all

gen     periodicity=.
replace periodicity=1 if inrange(articulos,1,23)	// HH weekly   ****Por qué los gastos semanales y anuales llevan la misma periodicidad
replace periodicity=1 if inrange(articulos,24,30) 	// Personales
replace periodicity=2 if inrange(articulos,31,42)	// Monthly
replace periodicity=3 if inrange(articulos,43,46)	// Quarterly
replace periodicity=4 if inrange(articulos,47,60)	// Yearly

label def periodicity ///
	1 "Weekly" ///
	2 "Monthly" ///
	3 "Quarterly" ///
	4 "Yearly" , replace
label val periodicity periodicity

save "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", replace
}
*
if 1==1{
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T1_infoav=rowtotal(compra adq_no_com) if articulos<=23
egen T1_expen_7d=rowtotal(vr_compra vr_estimado) if T1_infoav>0 & T1_infoav!=. , missing
replace T1_expen_7d=T1_expen_7d*(30/7) if T1_expen_7d!=.
rename T1_expen_7d T1_expen_m1_a

collapse (sum) T1_expen_m1_a T1_infoav ///
		 (last) id_vivienda, by(id_hogar1)
replace T1_expen_m1_a=. if T1_infoav==0 // If no data was collected, it is clearly a missing!

gen alimExpenses=T1_expen_m1_a
sum alimExpenses, d
scalar a=r(p99)
dis a
replace alimExpenses = a if alimExpenses>a & alimExpenses!=.

label var T1_expen_m1_a "Food expenses 7days (monthly)"

merge 1:1 id_hogar1 using `viviendas' , nogen

meanimput_h "T1_expen_m1_a"

rename T1_expen_m1_a T1_expen_m1
label var T1_expen_m1 "Food expenses 7days (monthly)"

tempfile gastor1_food
save `gastor1_food'


* 2. Alcohol and Tobacco *******************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav1=rowtotal(compra adq_no_com) if (articulos==24 | articulos==26 ) // 24 Tobacco 26 Alcohol
egen T2_expen_7d1=rowtotal(vr_compra vr_estimado) if (T2_infoav1>0 & T2_infoav1!=.), missing
replace T2_expen_7d1=T2_expen_7d1*(30/7) if T2_expen_7d1!=.
rename T2_expen_7d1 T2_expen_m1

egen T2_infoav1tab=rowtotal(compra adq_no_com) if (articulos==24)
egen tabacoExpenses=rowtotal(vr_compra vr_estimado) if (T2_infoav1tab>0 & T2_infoav1tab!=.), missing 
replace  tabacoExpenses=tabacoExpenses*(30/7) if tabacoExpenses!=.

egen T2_infoav1alc=rowtotal(compra adq_no_com) if (articulos==26)
egen alcoholExpenses= rowtotal(vr_compra vr_estimado) if (T2_infoav1alc>0 & T2_infoav1alc!=.), missing
replace alcoholExpenses=alcoholExpenses*(30/7) if alcoholExpenses!=. 


collapse (sum) T2_expen_m1 tabacoExpenses alcoholExpenses T2_infoav1 T2_infoav1tab T2_infoav1alc ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m1 "Tob-Alc 7 days (monthly)"
label var tabacoExpenses "Tabaco expenses (monthly)"
replace T2_expen_m1=. if T2_infoav1==0  // If no data was collected, it is clearly a missing!
sum tabacoExpenses, d
scalar b=r(p99)
dis b
*replace tabacoExpenses = b if tabacoExpenses>a & tabacoExpenses!=.

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m1"

tempfile gastor2_alcotob
save `gastor2_alcotob'



// VARIOS //
* 3. CLOTHING AND FOOTWEAR
* Mensuales
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav2_a=rowtotal(compra adq_no_com) if (articulos==33)
egen T2_expen_mon2a=rowtotal(vr_compra vr_estimado) if (T2_infoav2_a>0 & T2_infoav2_a!=.), missing
rename T2_expen_mon2a T2_expen_m2a

collapse (sum) T2_expen_m2a  T2_infoav2_a ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m2a "C&F (a)"
replace T2_expen_m2a=. if T2_infoav2_a==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m2a"

tempfile gastor3_cf
save `gastor3_cf'


* Trimestrales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav2_b=rowtotal(compra adq_no_com) if (articulos==43 | articulos==44)
egen T2_expen_q2b=rowtotal(vr_compra vr_estimado) if (T2_infoav2_b>0 & T2_infoav2_b!=.), missing
replace T2_expen_q2b=T2_expen_q2b/3 if T2_expen_q2b!=.
rename T2_expen_q2b T2_expen_m2b

collapse (sum) T2_expen_m2b  T2_infoav2_b ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m2b "C&F (b)"
replace T2_expen_m2b=. if T2_infoav2_b==0

merge 1:1 id_hogar1 using `viviendas' , nogen

meanimput_h "T2_expen_m2b"

merge 1:1 id_hogar1 using `gastor3_cf', nogen

egen T2_infoav2=rowtotal(T2_infoav2_b T2_infoav2_a)
egen T2_expen_m2=rowtotal(T2_expen_m2b T2_expen_m2a) if T2_infoav2>0 & T2_infoav2!=. , missing
la var T2_expen_m2 "Clothing and footwear (monthly)"

keep  id_hogar id_vivienda id_hogar1 b04012 T2_expen_m2 T2_infoav2 id_ag

tempfile CF
save `CF'
 

* 4. HOUSEHOLD SERVICES

* Semanales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav3_a=rowtotal(compra adq_no_com) if (articulos==28) // 
egen T2_expen_7d3a=rowtotal(vr_compra vr_estimado) if (T2_infoav3_a>0 & T2_infoav3_a!=.), missing
replace T2_expen_7d3a=T2_expen_7d3a*(30/7) if T2_expen_7d3a!=. 
rename T2_expen_7d3a T2_expen_m3a

collapse (sum) T2_expen_m3a  T2_infoav3_a ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m3a "HS (a)"
replace T2_expen_m3a=. if T2_infoav3_a==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m3a"

tempfile gastor2_hs
save `gastor2_hs'


* Mensuales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav3_b=rowtotal(compra adq_no_com) if (articulos==32 | articulos==37 | articulos==39 | articulos==40 | articulos==41 | articulos==42)
egen T2_expen_mon3b=rowtotal(vr_compra vr_estimado) if (T2_infoav3_b>0 & T2_infoav3_b!=.), missing
rename T2_expen_mon3b T2_expen_m3b

collapse (sum) T2_expen_m3b  T2_infoav3_b ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m3b "HS (b)"
replace T2_expen_m3b=. if T2_infoav3_b==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m3b"

tempfile gastor3_hs
save `gastor3_hs'


* Anuales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav3_c=rowtotal(compra adq_no_com) if (articulos==48)
egen T2_expen_y3c=rowtotal(vr_compra vr_estimado) if (T2_infoav3_c>0 & T2_infoav3_c!=.), missing
replace T2_expen_y3c=T2_expen_y3c*(1/12) if T2_expen_y3c!=.
rename T2_expen_y3c T2_expen_m3c

collapse (sum) T2_expen_m3c  T2_infoav3_c ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m3c "HS (c)"
replace T2_expen_m3c=. if T2_infoav3_c==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m3c"


forval x=2/3{
	merge 1:1  id_hogar1 using `gastor`x'_hs', nogen force
}

egen T2_infoav3=rowtotal(T2_infoav3_c T2_infoav3_b T2_infoav3_a)
egen T2_expen_m3=rowtotal(T2_expen_m3c T2_expen_m3b T2_expen_m3a) if T2_infoav3>0 & T2_infoav3!=. , missing
la var T2_expen_m3 "Household services (monthly)"

keep  id_hogar id_hogar1 id_vivienda b04012 T2_expen_m3 T2_infoav3 id_ag
tempfile HS
save `HS'


* 5. FURNITURE

* Anuales relacionados con Muebles y Enseres
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav4_a=rowtotal(compra adq_no_com) if (articulos==47)
egen T2_expen_y4a=rowtotal(vr_compra vr_estimado) if (T2_infoav4_a>0 & T2_infoav4_a!=.), missing
replace T2_expen_y4a=T2_expen_y4a*(1/12) if T2_expen_y4a!=.
rename T2_expen_y4a T2_expen_m4

collapse (sum) T2_expen_m4  T2_infoav4_a ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m4 "F (a)"
replace T2_expen_m4=. if T2_infoav4_a==0

merge 1:1 id_hogar1 using `viviendas' , nogen

meanimput_h "T2_expen_m4"

tempfile F
save `F'


* 7. TRANSPORT AND COMUNICATION

* Semanales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav6_a=rowtotal(compra adq_no_com) if (articulos==25 | articulos==27 | articulos==29) 
egen T2_expen_7d6a=rowtotal(vr_compra vr_estimado) if (T2_infoav6_a>0 & T2_infoav6_a!=.), missing
replace T2_expen_7d6a=T2_expen_7d6a*(30/7) if T2_expen_7d6a!=.
rename T2_expen_7d6a T2_expen_m6a

collapse (sum) T2_expen_m6a  T2_infoav6_a ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m6a "T&C (a)"
replace T2_expen_m6a=. if T2_infoav6_a==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m6a"

tempfile gastor2_tc
save `gastor2_tc'


* Trimestrales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav6_b=rowtotal(compra adq_no_com) if (articulos==45)
egen T2_expen_q6b=rowtotal(vr_compra vr_estimado) if (T2_infoav6_b>0 & T2_infoav6_b!=.), missing
replace T2_expen_q6b=T2_expen_q6b*(1/3) if T2_expen_q6b!=.
rename T2_expen_q6b T2_expen_m6b

collapse (sum) T2_expen_m6b  T2_infoav6_b ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m6b "T&C (b)"
replace T2_expen_m6b=. if T2_infoav6_b==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m6b"

tempfile gastor2_tc1
save `gastor2_tc1'

* Anuales
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav6_c=rowtotal(compra adq_no_com) if (articulos==60)
egen T2_expen_q6c=rowtotal(vr_compra vr_estimado) if (T2_infoav6_c>0 & T2_infoav6_c!=.), missing
replace T2_expen_q6c=T2_expen_q6c*(1/12) if T2_expen_q6c!=.
rename T2_expen_q6c T2_expen_m6c

collapse (sum) T2_expen_m6c  T2_infoav6_c ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m6c "T&C (c)"
replace T2_expen_m6c=. if T2_infoav6_c==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m6c"

merge 1:1  id_hogar1 using `gastor2_tc1', nogen 
merge 1:1  id_hogar1 using `gastor2_tc', nogen 

egen T2_infoav6=rowtotal(T2_infoav6_c T2_infoav6_b T2_infoav6_a)
egen T2_expen_m6=rowtotal(T2_expen_m6c T2_expen_m6b T2_expen_m6a) if T2_infoav6>0 & T2_infoav6!=. , missing
la var T2_expen_m6 "Transport and Comunications (monthly)"

keep  id_hogar1 id_vivienda b04012 T2_expen_m6 T2_infoav6 id_ag
tempfile TC
save `TC'


* 8. CULTURAL SERVICES AND ENTERTAINMENT 

* Semanales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear  
egen T2_infoav7_a=rowtotal(compra adq_no_com) if (articulos==30) 
egen T2_expen_7d7a=rowtotal(vr_compra vr_estimado) if (T2_infoav7_a>0 & T2_infoav7_a!=.), missing
replace T2_expen_7d7a=T2_expen_7d7a*(30/7) if T2_expen_7d7a!=. 
rename T2_expen_7d7a T2_expen_m7a

collapse (sum) T2_expen_m7a  T2_infoav7_a ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m7a "CS&E (a)"
replace T2_expen_m7a=. if T2_infoav7_a==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m7a"

tempfile gastor2_cse
save `gastor2_cse'


* Mensuales
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav7_b=rowtotal(compra adq_no_com) if (articulos==36)
egen T2_expen_mon7b=rowtotal(vr_compra vr_estimado) if (T2_infoav7_b>0 & T2_infoav7_b!=.), missing
rename T2_expen_mon7b T2_expen_m7b

collapse (sum) T2_expen_m7b  T2_infoav7_b ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m7b "CS&E (b)"
replace T2_expen_m7b=. if T2_infoav7_b==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m7b"

tempfile gastor3_cse
save `gastor3_cse'


* Trimestrales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav7_c=rowtotal(compra adq_no_com) if (articulos==46)
egen T2_expen_q7c=rowtotal(vr_compra vr_estimado) if (T2_infoav7_c>0 & T2_infoav7_c!=.), missing
replace T2_expen_q7c=T2_expen_q7c*(1/3) if T2_expen_q7c!=. 
rename T2_expen_q7c T2_expen_m7c

collapse (sum) T2_expen_m7c  T2_infoav7_c ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m7c "CS&E (c)"
replace T2_expen_m7c=. if T2_infoav7_c==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m7c"

tempfile gastor4_cse
save `gastor4_cse'


* Anuales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav7_d=rowtotal(compra adq_no_com) if (articulos==49)
egen T2_expen_y7d=rowtotal(vr_compra vr_estimado) if (T2_infoav7_d>0 & T2_infoav7_d!=.), missing
replace T2_expen_y7d=T2_expen_y7d*(1/12) if T2_expen_y7d!=.
rename T2_expen_y7d T2_expen_m7d

collapse (sum) T2_expen_m7d  T2_infoav7_d ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m7d "CS&E (d)"
replace T2_expen_m7d=. if T2_infoav7_d==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m7d"

forval x=2/4{
	merge 1:1  id_hogar1 using `gastor`x'_cse', nogen
}

egen T2_infoav7=rowtotal(T2_infoav7_a T2_infoav7_b T2_infoav7_c T2_infoav7_d)
egen T2_expen_m7=rowtotal(T2_expen_m7a T2_expen_m7b T2_expen_m7c T2_expen_m7d) if T2_infoav7>0 & T2_infoav7!=. , missing
la var T2_expen_m7 "Cultural Services and Entertainment(monthly)"

keep  id_hogar id_hogar1 id_vivienda b04012 T2_expen_m7 T2_infoav7 id_ag
tempfile CSE
save `CSE'


* 10. PERSONAL SERVICES AND OTHER PAYMENTS

* Mensuales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav9_b=rowtotal(compra adq_no_com) if (articulos==31 | articulos==34 | articulos==35 | articulos==38)
egen T2_expen_mon9b=rowtotal(vr_compra vr_estimado) if (T2_infoav9_b>0 & T2_infoav9_b!=.), missing
rename T2_expen_mon9b T2_expen_m9b

collapse (sum) T2_expen_m9b  T2_infoav9_b ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m9b "PS&OP (b)"
replace T2_expen_m9b=. if T2_infoav9_b==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m9b"

tempfile gastor3_psop
save `gastor3_psop'

* Anuales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear 
egen T2_infoav9_c=rowtotal(compra adq_no_com) if (articulos==50 | articulos==51 | articulos==52 | articulos==53 | articulos==54 | articulos==55 | articulos==56 | articulos==57 | articulos==58 | articulos==59)
egen T2_expen_y9c=rowtotal(vr_compra vr_estimado) if (T2_infoav9_c>0 & T2_infoav9_c!=.), missing
replace T2_expen_y9c=T2_expen_y9c*(1/12) if T2_expen_y9c!=.
rename T2_expen_y9c T2_expen_m9c

collapse (sum) T2_expen_m9c  T2_infoav9_c ///
		 (last) id_vivienda, by(id_hogar1)
label var T2_expen_m9c "CS&E (d)"
replace T2_expen_m9c=. if T2_infoav9_c==0

merge 1:1 id_hogar1 using `viviendas', nogen

meanimput_h "T2_expen_m9c"

merge 1:1  id_hogar1 using `gastor3_psop', nogen

egen T2_infoav9=rowtotal(T2_infoav9_b T2_infoav9_c)
egen T2_expen_m9=rowtotal(T2_expen_m9b T2_expen_m9c) if T2_infoav9>0 & T2_infoav9!=. , missing
la var T2_expen_m9 "Personal Services and other payments(monthly)"

keep  id_hogar id_hogar1 id_vivienda b04012 T2_expen_m9 T2_infoav9 id_ag

merge 1:1 id_hogar1 using `CSE', nogen
merge 1:1 id_hogar1 using `TC', nogen
merge 1:1 id_hogar1 using `F', nogen
merge 1:1 id_hogar1 using `HS', nogen
merge 1:1 id_hogar1 using `CF', nogen
merge 1:1 id_hogar1 using `gastor2_alcotob', nogen
merge 1:1 id_hogar1 using `gastor1_food', nogen

save "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Gasto_NoServiciosSaludEduc.dta", replace
}
*

// GASTOS INDIVIDUALES A NIVEL HOGAR
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Gasto_SaludEduc.dta", clear
egen T2_infoav5a=rowtotal(f01 f0501 f0801 f24 f19_hosp_ult_12meses f34_med_prepag f35_cons_med f36_trat_odont f37_vacunas f38_medicamentos f39_lab_clinico f40_transporte f41_rehabilitacion f42_med_alternat f43_lentes_aparatos f44_pago_cirugias), missing
egen T2_expen_mon5a=rowtotal(f07_pago_afilia f09_pago_plan_salud f3401_valor f3501_valor f3601_valor f3701_valor_vacunas f3801_valor_med f3901_valor_lab_clin f4001_valor_med f4101_valor_med f4201_valor_alternat f21_pago_tot_hosp f4301_valor_lent_ap f4401_valor_cirugias) if T2_infoav5a>0 & T2_infoav5a!=. , missing

egen T2_expen_m5a=rowtotal(T2_expen_mon5a) if T2_infoav5a>0 & T2_infoav5a!=. , missing
replace T2_expen_m5a=. if T2_infoav5a==0
rename T2_expen_m5a T2_expen_m5

gsort + id_hogar1 - T2_infoav5a + orden - T2_expen_m5
collapse (first) T2_expen_m5  T2_infoav5a id_vivienda id_ag, by(id_hogar1)

tempfile Health
save `Health'

use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Gasto_SaludEduc.dta", clear
* 9. Education *****************************************************************
replace g2002_cuanto_compra=g2002_cuanto_compra-g2001_cuanto_paga_dia if g20_almuerzo_gratis!=.
replace g2102_cuanto_compra=g2102_cuanto_compra-g2101_cuanto_paga_dia if g21_recibe_med_nuev!=.
replace g2202_cuanto_compra=g2202_cuanto_compra-g2201_cuanto_paga_dia if g22_recibe_onces!=.

egen T2_infoav8=rowtotal(g12_pag_matr g13_pago_unif g14_pago_utiles g15_comp_util_fuera_inst g16_pension_cuota g17_ruta g18_alimentacion g19_otro_pago g20_almuerzo_gratis g21_recibe_med_nuev g22_recibe_onces i16_pago_matr i17_uniforme i18_utiles i19_complementarios i20_bono_vol i21_pension i22_transp_escol i23_alimentacion i24_util_mes_ant i25_otros_pagos i26_recibio_subsidio i30_rec_beca_ano i33_rec_cred_ano)
egen T2_expen_7d8=rowtotal(g2002_cuanto_compra g2102_cuanto_compra g2202_cuanto_compra) if T2_infoav8>0 & T2_infoav8!=. , missing
replace T2_expen_7d8=T2_expen_7d8*(30) if T2_expen_7d8!=.
egen T2_expen_mon8=rowtotal(g1601_valor g1701_valor g1801_valor g1901_valor i2101_valor i2201_valor i2301_valor i2401_valor i2501_valor i2801_valor i2803_valor i3101_valor i3103_valor i3401_valor) if T2_infoav8>0 & T2_infoav8!=. , missing
egen T2_expen_y8=rowtotal(g1201_valor g1301_valor g1401_valor  g1501_valor i1601_valor i1701_valor i1801_valor i1901_valor i2001_valor )  if T2_infoav8>0 & T2_infoav8!=. , missing
replace T2_expen_y8=T2_expen_y8*(1/12) if T2_expen_y8!=.

egen T2_expen_m8=rowtotal(T2_expen_7d8 T2_expen_mon8 T2_expen_y8), missing
replace T2_expen_m8=. if T2_infoav8==0
replace T2_expen_m8=0 if g12_pag_matr==. & g13_pago_unif==. & g14_pago_utiles==. & g15_comp_util_fuera_inst==. & g16_pension_cuota==. & g17_ruta==. & g18_alimentacion==. & g19_otro_pago==. & g20_almuerzo_gratis==. & g21_recibe_med_nuev==. & g22_recibe_onces==. & i16_pago_matr==. & i17_uniforme==. & i18_utiles==. & i19_complementarios==. & i20_bono_vol==. & i21_pension==. & i22_transp_escol==. & i23_alimentacion==. & i24_util_mes_ant==. & i25_otros_pagos==. & i26_recibio_subsidio==. & i30_rec_beca_ano==. & i33_rec_cred_ano==.

gsort + id_hogar1 - T2_infoav8 + orden - T2_expen_m8
collapse (first) T2_expen_m8  T2_infoav8 id_vivienda id_ag, by(id_hogar1)
lab var T2_expen_m8 "HH Expenses on Education(monthly)"

merge 1:1 id_hogar1 using `Health', nogen
merge 1:1 id_hogar1 using "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Gasto_NoServiciosSaludEduc.dta", nogen

la var T2_expen_m5 "HH Expenses on Health (monthly)"
rename T2_infoav4_a T2_infoav4
drop T2_infoav5a T2_infoav1tab

save "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Gasto_NoServicios.dta", replace


// GASTOS DEL HOGAR: SERVICIOS Y ARRIENDO
use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Vivienda_Hogar.dta", clear 
cleanvars "c03_pagan_electricidad c07_paga_serv_alcantari c10_pago_serv_recol_basura c15_pagan_serv_acued c19_energia_cocinar c21_serv_tel_corriente c23_pagan_tel_corriente "


replace c04_valor_ult_pago_electricidad= c04_valor_ult_pago_electricidad/c0401_meses_pagados_electricidad if c04_valor_ult_pago_electricidad!=. & c04_valor_ult_pago_electricidad!=99 & c0401_meses_pagados_electricidad!=. & c0401_meses_pagados_electricidad!=0
replace c08_ult_pago_serv_alcantari= c08_ult_pago_serv_alcantari/c0801_meses_pagados_alcantari if c08_ult_pago_serv_alcantari!=. & c08_ult_pago_serv_alcantari!=99 & c0801_meses_pagados_alcantari!=. & c0801_meses_pagados_alcantari!=0
replace c11_ult_pago_serv_basura= c11_ult_pago_serv_basura/c1101_meses_pago_serv_basura if c11_ult_pago_serv_basura!=. & c11_ult_pago_serv_basura!=99 & c1101_meses_pago_serv_basura!=. & c1101_meses_pago_serv_basura!=0
replace c16_ult_pago_serv_acued= c16_ult_pago_serv_acued/c1601_meses_pagados_acued if c16_ult_pago_serv_acued!=. & c16_ult_pago_serv_acued!=99 & c1601_meses_pagados_acued!=. & c1601_meses_pagados_acued!=0
replace c20_gastos_cocinar=c20_gastos_cocinar if c20_gastos_cocinar!=. & c19_energia_cocinar!=.
replace c24_ult_pago_tel=c24_ult_pago_tel/c2401_meses_pago_tel if c24_ult_pago_tel!=. & c24_ult_pago_tel!=99 & c2401_meses_pago_tel!=. & c2401_meses_pago_tel!=0
replace d08_pago_predial_ano_ant=(d08_pago_predial_ano_ant/d0801_cuantos_anos_pago) if d0801_cuantos_anos_pago!=0 & d0801_cuantos_anos_pago!=. & d08_pago_predial_ano_ant!=. & d08_pago_predial_ano_ant!=98 & d08_pago_predial_ano_ant!=99

meanimput_h "c04_valor_ult_pago_electricidad c08_ult_pago_serv_alcantari c11_ult_pago_serv_basura c16_ult_pago_serv_acued c20_gastos_cocinar c24_ult_pago_tel d09_pago_valorizac_ano_ant d08_pago_predial_ano_ant d10_pago_considerado_arriendo d11_pago_mes_arriendo d12_pago_mes_admon"

egen T2_expen_mon3_a=rowtotal(c04_valor_ult_pago_electricidad c08_ult_pago_serv_alcantari c11_ult_pago_serv_basura c16_ult_pago_serv_acued c20_gastos_cocinar c24_ult_pago_tel d10_pago_considerado_arriendo d11_pago_mes_arriendo d12_pago_mes_admon), missing
egen T2_expen_y3_a=rowtotal(d09_pago_valorizac_ano_ant d08_pago_predial_ano_ant ), missing
replace T2_expen_y3_a=T2_expen_y3_a*(1/12) if T2_expen_y3_a!=.
egen T2_expen_m3_a=rowtotal(T2_expen_mon3_a  T2_expen_y3_a), missing

merge 1:1 id_hogar1 using "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\Gasto_NoServicios.dta",  nogen

rename T2_expen_m3 T2_expen_m3_b
egen T2_expen_m3=rowtotal(T2_expen_m3_b T2_expen_m3_a)
drop T2_expen_m3_b T2_expen_m3_a T2_expen_mon3_a T2_expen_y3_a
label var T2_expen_m3 "Household services (monthly)"

replace alimExpenses=0 if T1_expen_m1==0

* TOTAL EXPENSES HOUSEHOLD *****************************************************
*egen totalExpenses= rowtotal(T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9 ) if missing(T1_infoav,T2_infoav1,T2_infoav2,T2_infoav3,T2_infoav4,T2_infoav5,T2_infoav6,T2_infoav7,T2_infoav8,T2_infoav9)==0 & (T1_infoav>0 | T2_infoav1>0 | T2_infoav2>0 | T2_infoav3>0 | T2_infoav4>0 | T2_infoav5>0 | T2_infoav6>0 | T2_infoav7>0 | T2_infoav7>0 | T2_infoav8>0 | T2_infoav9>0)  , missing
egen totalExpenses= rowtotal(T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9), missing 
label var totalExpenses "Total expenses (monthly)"

keep 	id_hogar1 id_ag tabacoExpenses alcoholExpenses totalExpenses alimExpenses T1_expen_m1 T2_expen_m1 T2_expen_m2 ///
		T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 ///
		T2_expen_m8 T2_expen_m9 b04012

rename id_hogar1 id_hogar

save "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\ECVB2007_expenditures_a.dta", replace

use "$dropbox\Tobacco-health-inequalities\data\ECVB2007\original\Gastos1.dta", clear

egen expend=rowtotal(vr_compra vr_estimado), missing

gen     GastoCte=expend if periodicity==2
replace GastoCte=expend*(30/7) if periodicity==1
replace GastoCte=expend/3 if periodicity==3
replace GastoCte=expend/12 if periodicity==4

gen  T2_expen_pers=expend*4 if articulos>23 & articulos<31
label var T2_expen_pers "Personal expenses 7 days (monthly)"


gen pers_expenses=expend*4 if articulos>23 & articulos<31 & articulos!=24 
label var pers_expenses "Personal expenses rather than smoking"

rename vr_compra pago 
rename vr_estimado prec_estim
drop id_hogar 
rename id_hogar1 id_hogar 

collapse (sum) GastoCte T2_expen_pers pers_expenses, by(fex_calib id_hogar id_vivienda id_loc)

merge 1:1 id_hogar using "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived\ECVB2007_expenditures_a.dta" , nogen

gen dif= totalExpenses-GastoCte if totalExpenses!=. & GastoCte!=.
replace GastoCte=totalExpenses if dif<-0.002
drop dif

gen curexpper=GastoCte/totalExpenses
gen alimExpenses1= alimExpenses

recode b04012 (0/2= 1 "1")(3=2 "2")(4=3 "3")(5/6=4 "4+") , g(strata)
replace strata=. if strata==9

save "$dropbox\Tobacco-health-inequalities\data\ECVB2007\derived/ECVB2007_expenditures1.dta" ,replace
