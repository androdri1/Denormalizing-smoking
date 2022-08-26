* Author: Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2018.10.18
* Goal: produce total income of the HH for the ENCV2011 (no imputation or outlier analysis here!)


if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Drive\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive\Tobacco-health-inequalities\data" // Susana
}


			** PROGRAMAS DE IMPUTACIÓN Y LIMPIEZA DE VARIABLES **
if 1==1{
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

// Mean imputation for expenditures made individually
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

// Mean imputation for expenditures made at the household level
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
}


					** ARREGLANDO LA BASE DE DATOS **
if 1==1{
use "$dropbox\EMB2011\data\raw\capg.dta", clear 
gen hogar= substr(DIRECTORIO_PER,1,8)

destring DIRECTORIO_HOG directorio DIRECTORIO_PER hogar, replace
format DIRECTORIO_PER %15.0f
drop DIRECTORIO_HOG 
rename hogar DIRECTORIO_HOG

tempfile menores
save `menores'

use "$dropbox\EMB2011\data\raw\caph.dta", clear 
gen hogar= substr(DIRECTORIO_PER,1,8)

destring DIRECTORIO_HOG directorio DIRECTORIO_PER hogar, replace
format DIRECTORIO_PER %15.0f
drop DIRECTORIO_HOG 
rename hogar DIRECTORIO_HOG

tempfile educacion
save `educacion'

use "$dropbox\EMB2011\data\raw\capj.dta", clear 
gen hogar= substr(DIRECTORIO_PER,1,8)

destring DIRECTORIO_HOG directorio DIRECTORIO_PER hogar, replace
format DIRECTORIO_PER %15.0f
drop DIRECTORIO_HOG 
rename hogar DIRECTORIO_HOG

tempfile organizaciones
save `organizaciones'

use "$dropbox\EMB2011\data\raw\capk.dta", clear 
gen hogar= substr(DIRECTORIO_PER,1,8)

destring DIRECTORIO_HOG directorio DIRECTORIO_PER hogar, replace
format DIRECTORIO_PER %15.0f
drop DIRECTORIO_HOG 
rename hogar DIRECTORIO_HOG

tempfile trabajo
save `trabajo'

use "$dropbox\EMB2011\data\raw\capm.dta", clear 
destring DIRECTORIO_HOG directorio, replace
tempfile gastos1
save `gastos1'

use "$dropbox\EMB2011\data\raw\capm2.dta", clear 
destring DIRECTORIO_HOG directorio, replace
tempfile gastos2
save `gastos2'

use "$dropbox\EMB2011\geo\EMB2011.dta", clear 
drop _merge

rename directorio_hog DIRECTORIO_HOG
rename directorio_per DIRECTORIO_PER

format DIRECTORIO_PER %15.0f

merge 1:1 DIRECTORIO_HOG DIRECTORIO_PER using `menores', gen(matchM)
drop if matchM==2 // 0.1% 

merge 1:1 DIRECTORIO_HOG DIRECTORIO_PER using `educacion', gen(matchE)
drop if matchE==2 // 1.5%

merge 1:1 DIRECTORIO_HOG DIRECTORIO_PER using `organizaciones', gen(matchO)
drop if matchO==2 // 1.4%

merge 1:1 DIRECTORIO_HOG DIRECTORIO_PER using `trabajo', gen(matchT)
drop if matchT==2 // 1.5%

merge n:1 DIRECTORIO_HOG using `gastos1', gen(matchG1)
drop if matchG1==2 // 0.4%

merge n:1 DIRECTORIO_HOG using `gastos2', gen(matchG2)
drop if matchG2==2 // 0.4%

rename directorio id_vivienda
rename DIRECTORIO_HOG id_hogar
rename DIRECTORIO_PER orden
rename d9_estrato b04012
destring id_vivienda b04012, replace

la def estrato 0 "Sin estrato (Pirata)" 1 "Bajo-Bajo" 2 "Bajo" 3 "Medio-Bajo" 4 "Medio" 5 "Medio-Alto" 6 "Alto" 9 "No sabe, planta"
la val b04012 estrato

qui destring H* G* M*, replace 

save "$dropbox\EMB2011\derived\GEOVivienda_Hogar_Persona.dta", replace
}


					 **	HOUSEHOLD EXPENDITURES	**
					 
* Members of the household individual expenditures imputation ..................
if 1==1{

	// Gastos individuales: EDUCACION 
		cleanvars 	"G7 G8 G9 G10 G11 G12 G13"
		sort id_vivienda id_hogar orden
		meanimput "G7_VALOR G8_VALOR G9_VALOR G10_VALOR G11_VALOR G12_VALOR G13_VALORPAG G13_VALOREST"

		cleanvars 	"H17 H18 H22 H23A H23B H24 H25 H26A H26B H26C H28A H28B H28C H30"

		***********************************************o*********************************
		// Subsidios y Becas a la Educacion mensualizados
		foreach x in  H26A_PERIODO H26B_PERIODO H28A_PERIODO H28B_PERIODO H30_PERIODO {
		replace `x'=6 	if `x'==3
		replace `x'=12 	if `x'==4
		}

		// Subsidios en dinero o especie
		replace H28A_VALOR=H28A_VALOR/H28A_PERIODO if H28A_PERIODO!=. & H28A_VALOR!=0 & H28A_VALOR!=.
		replace H28B_VALOR=H28B_VALOR/H28B_PERIODO if H28B_PERIODO!=. & H28B_VALOR!=0 & H28B_VALOR!=.

		// Beca en dinero o en especie
		replace H26A_VALOR=H26A_VALOR/H26A_PERIODO if H26A_PERIODO!=. & H26A_VALOR!=0 & H26A_VALOR!=.
		replace H26B_VALOR=H26B_VALOR/H26B_PERIODO if H26B_PERIODO!=. & H26B_VALOR!=0 & H26B_VALOR!=.

		// Credito educativo
		replace H30_VALOR=H30_VALOR/H30_PERIODO if H30_PERIODO!=. & H30_VALOR!=0 & H30_VALOR!=.

		sort id_vivienda id_hogar orden
		meanimput "H17_VALOR H18_VALOR H22_PAGADO H22_ESTIMADO H23A_VALOR H23B_VALOR H24_VALOR H25_VALOR H26A_VALOR H26B_VALOR H28A_VALOR H28B_VALOR H30_VALOR"

		tempfile Educ
		save `Educ'

		foreach vard in G7_VALOR G8_VALOR G9_VALOR G10_VALOR G11_VALOR G12_VALOR G13_VALORPAG G13_VALOREST H17_VALOR H18_VALOR H22_PAGADO H22_ESTIMADO H23A_VALOR H23B_VALOR H24_VALOR H25_VALOR H26A_VALOR H26B_VALOR H28A_VALOR H28B_VALOR H30_VALOR{ 
			replace `vard'=0 if G7==. & G8==. & G9==. & G10==. & G11==. & G12==. & G13==. & H17==. & H18==. & H22==. & H23A==. & H23B==. & H24==. & H25==. & H26A==. & H26B==. & H28A==. & H28B==. & H30==. 
		}
		save "$dropbox\EMB2011\derived\Gasto_Educ.dta", replace



	// Gastos individuales: SALUD
		rename f1 f01
		 
		gen 	f0801=.
		replace f0801=0 if f13e==1
		replace f0801=1 if (f13a!=. | f13b!=. | f13c!=. | f13d!=.) & f13e!=1
		la var f0801 "Plan de salud complementario"

		gen 	f0501=.
		replace f0501=0 if f5d==1 | f5e==1 
		replace f0501=1 if f5a==1 | f5b==1 | f5c==1 
		la var f0501 "Plan básico de salud"

		cleanvars "f01 f0501 f0801 f31 f38a f38b f38c f38d f38e f38f f41a f41b" // 
		
		replace f14_periodo = 6 if f14_periodo==3
		replace f14_periodo = 12 if f14_periodo==4
		
		replace f14_valor=f14_valor/f14_periodo
		
		meanimput "f6 f14_valor f31_valor f38a_pago f38b_pago f38c_pago f38d_pago f38e_pago f38f_pago f40 f41a_valor f41b_valor"

		replace f31_valor=f31_valor*(1/12) if f31==1 & f31_valor!=.
		replace f41a_valor =f41a_valor *(1/12) if f41a==1 & f41a_valor !=.
		replace f41b_valor=f41b_valor*(1/12) if f41b==1 & f41b_valor!=.

		save "$dropbox\EMB2011\derived\Gasto_SaludEduc.dta", replace
}
*

// GASTOS DEL HOGAR: ALIMENTOS, ALCOHOL Y TABACO, VESTIDO Y CALZADO, SERVICIOS DEL HOGAR, 
// MUEBLES Y ENSERES, TRANSPORTE Y COMUNICACIONES, SERVICIOS CULTURALES Y ENTRETENIMIENTO,
// SERVICIOS PERSONALES Y OTROS. 
if 1==1{
use "$dropbox\EMB2011\derived\Gasto_SaludEduc.dta", clear 
format id_hogar %13.0f
destring M*, replace 
drop 	M1A M1B M1C M1D M1E M1F M1F_DIAS M4* M64* M84* M82F M83D_VALOREST M83F_VALOREST M83G_VALOREST  M82D M62C M63C* ///
		M104* M124*

cleanvars "M3 M511 M521 M531 M541 M551 M61 M62A M62B M62D M62E M711 M721 M731 M741 M751 M761 M771 M781 M8 M82A M82B M82C M82E M82G M82H M911 M921 M931 M941 M951 M101 M1111 M1121 M1131 M1141 M1151 M1161 M1171 M1181 M1191 M11101 M11111 M11121 M11131 M11141 M11151 M11161 M11171 M11181 M11191 M11201 M11211 M11221 M11231 M121 M102A M102B M102C M102D M102E M122A M122B M122C M122D M122E M122F M122G M122H M122I M122J M122K M122L M122M M122N M122O M122P M122Q M122R M122S M122T M122U"

save "$dropbox\EMB2011\derived\Gasto_SaludEduc1.dta", replace
}
*
if 1==1{

* 1. FOOD **********************************************************************
use "$dropbox\EMB2011\derived\Gasto_SaludEduc1.dta", clear 
egen T1_infoav=rowtotal(M3 M511 M521 M531 M541 M551 M61 M62A M62B M62D M62E M711 M721 M731 M741 M751 M761 M771 M781 M8 M82A M82B M82C M82E M82G M82H), missing
egen T1_expen_7d=rowtotal(M2A_VALOR M2B_VALOR ), missing
replace T1_expen_7d=T1_expen_7d*(30/7) if T1_expen_7d!=.
egen T1_expen_15d=rowtotal(M2C_VALOR) , missing
replace T1_expen_15d=T1_expen_15d*(30/15) if T1_expen_15d!=.
egen T1_expen_20d=rowtotal(M2D_VALOR) , missing
replace T1_expen_20d=T1_expen_20d*(30/20) if T1_expen_20d!=.
egen T1_expen_30d=rowtotal(M2E_VALOR M3_VALOREST) , missing

egen T1_expen_m1b=rowtotal(T1_expen_7d T1_expen_15d T1_expen_20d T1_expen_30d), missing
rename T1_expen_m1b T1_expen_m1_a

gen alimExpenses=T1_expen_m1_a
sum alimExpenses, d
scalar a=r(p99)
dis a
replace alimExpenses = a if alimExpenses>a & alimExpenses!=.

label var T1_expen_m1_a "Food expenses 7days (monthly)"

meanimput_h "T1_expen_m1_a"

rename T1_expen_m1_a T1_expen_m1
label var T1_expen_m1 "Food expenses 7days (monthly)"


* 2. ALCOHOL AND TOBACCO *******************************************************
egen T2_expen_7d1 = rowtotal(M512_VALOR M63A_VALOREST), missing
replace T2_expen_7d1 = T2_expen_7d1*(30/7) if T2_expen_7d1!=.
rename T2_expen_7d1 T2_expen_m1

meanimput_h "T2_expen_m1"

* -----------------------------------------------------------------------------*
* VARIOS 
* -----------------------------------------------------------------------------*

* 3. CLOTHING AND FOOTWEAR
* Mensuales
* -----------------------------------------------------------------------------*
egen T2_expen_m2a=rowtotal(M732_VALOR M83A_VALOREST) if M731==1 | M82C==1, missing
meanimput_h "T2_expen_m2a"

* Trimestrales 
* -----------------------------------------------------------------------------*
egen T2_infoav2_b=rowtotal(M911 M921 M931 M941 M951 M101 M1111 M1121 M1131 M1141 M1151 M1161 M1171 M1181 M1191 M11101 M11111 M11121 M11131 M11141 M11151 M11161 M11171 M11181 M11191 M11201 M11211 M11221 M11231 M121 M102A M102B M102C M102D M102E M122A M122B M122C M122D M122E M122F M122G M122H M122I M122J M122K M122L M122M M122N M122O M122P M122Q M122R M122S M122T M122U), missing
egen T2_expen_q2b=rowtotal(M912_VALOR_CONTADO M912_VALOR_CREDITO M922_VALOR_CONTADO M922_VALOR_CREDITO M942_VALOR_CONTADO M942_VALOR_CREDITO M103A_VALOREST M103B_VALOREST M103D_VALOREST) if (T2_infoav2_b>0 & T2_infoav2_b!=.), missing
replace T2_expen_q2b=T2_expen_q2b/3 if T2_expen_q2b!=.
rename T2_expen_q2b T2_expen_m2b

meanimput_h "T2_expen_m2b"

egen T2_infoav2=rowtotal(T2_infoav2_b T1_infoav)
egen T2_expen_m2=rowtotal(T2_expen_m2b T2_expen_m2a), missing
la var T2_expen_m2 "Clothing and footwear (monthly)"


* 4. HOUSEHOLD SERVICES

* Mensuales 
* -----------------------------------------------------------------------------*
egen T2_expen_mon3b=rowtotal(M712_VALOR M782_VALOR M83A_VALOREST M83H_VALOREST) , missing
rename T2_expen_mon3b T2_expen_m3b
meanimput_h "T2_expen_m3b"

* Anuales 
* -----------------------------------------------------------------------------*
egen T2_expen_y3c=rowtotal(M11202_VALOR_CONTADO M11202_VALOR_CREDITO M11212_VALOR_CONTADO M11212_VALOR_CREDITO M123T_VALOREST M123U_VALOREST) , missing
replace T2_expen_y3c=T2_expen_y3c*(1/12) if T2_expen_y3c!=.
rename T2_expen_y3c T2_expen_m3c
meanimput_h "T2_expen_m3c"


egen T2_expen_m3=rowtotal(T2_expen_m3c T2_expen_m3b) , missing
la var T2_expen_m3 "Household services (monthly)"


* 5. FURNITURE

* Anuales relacionados con Muebles y Enseres
* -----------------------------------------------------------------------------*
egen T2_expen_y4a=rowtotal(M1112_VALOR_CONTADO M1112_VALOR_CREDITO M123A_VALOREST M1122_VALOR_CONTADO M1122_VALOR_CREDITO M123B_VALOREST M1132_VALOR_CONTADO M1132_VALOR_CREDITO M123C_VALOREST M1192_VALOR_CONTADO M1192_VALOR_CREDITO M123I_VALOREST M11102_VALOR_CONTADO M11102_VALOR_CREDITO M123J_VALOREST M1142_VALOR_CONTADO M1142_VALOR_CREDITO M123D_VALOREST), missing
replace T2_expen_y4a=T2_expen_y4a*(1/12) if T2_expen_y4a!=.
rename T2_expen_y4a T2_expen_m4

meanimput_h "T2_expen_m4"


* 7. TRANSPORT AND COMUNICATION

* Semanales 
* -----------------------------------------------------------------------------*
egen T2_expen_7d6a=rowtotal(M522_VALOR M532_VALOR M542_VALOR M63B_VALOREST M63D_VALOREST), missing
replace T2_expen_7d6a=T2_expen_7d6a*(30/7) if T2_expen_7d6a!=.
rename T2_expen_7d6a T2_expen_m6a

meanimput_h "T2_expen_m6a"


* Trimestrales 
* -----------------------------------------------------------------------------*
egen T2_expen_q6b=rowtotal(M952_VALOR_CONTADO M952_VALOR_CREDITO M103E_VALOREST) , missing
replace T2_expen_q6b=T2_expen_q6b*(1/3) if T2_expen_q6b!=.
rename T2_expen_q6b T2_expen_m6b

meanimput_h "T2_expen_m6b"

* Anuales
* -----------------------------------------------------------------------------*
egen T2_expen_q6c=rowtotal(M11152_VALOR_CONTADO M11152_VALOR_CREDITO M123E_VALOREST M1172_VALOR_CONTADO M1172_VALOR_CREDITO M123G_VALOREST), missing
replace T2_expen_q6c=T2_expen_q6c*(1/12) if T2_expen_q6c!=.
rename T2_expen_q6c T2_expen_m6c

meanimput_h "T2_expen_m6c"

egen T2_expen_m6=rowtotal(T2_expen_m6c T2_expen_m6b T2_expen_m6a), missing
la var T2_expen_m6 "Transport and Comunications (monthly)"


* 8. CULTURAL SERVICES AND ENTERTAINMENT 

* Mensuales
* -----------------------------------------------------------------------------*
egen T2_expen_mon7b=rowtotal(M772_VALOR), missing
rename T2_expen_mon7b T2_expen_m7b

meanimput_h "T2_expen_m7b"

* Trimestrales 
* -----------------------------------------------------------------------------*
egen T2_expen_q7c=rowtotal(M932_VALOR_CONTADO M932_VALOR_CREDITO M103C_VALOREST), missing
replace T2_expen_q7c=T2_expen_q7c*(1/3) if T2_expen_q7c!=. 
rename T2_expen_q7c T2_expen_m7c

meanimput_h "T2_expen_m7c"

* Anuales 
* -----------------------------------------------------------------------------*
egen T2_expen_y7d=rowtotal(M11142_VALOR_CONTADO M11142_VALOR_CREDITO M11152_VALOR_CONTADO M11152_VALOR_CREDITO M11172_VALOR_CONTADO M11172_VALOR_CREDITO M123N_VALOREST M123O_VALOREST M123Q_VALOREST), missing
replace T2_expen_y7d=T2_expen_y7d*(1/12) if T2_expen_y7d!=.
rename T2_expen_y7d T2_expen_m7d

meanimput_h "T2_expen_m7d"

egen T2_expen_m7=rowtotal(T2_expen_m7b T2_expen_m7c T2_expen_m7d) , missing
la var T2_expen_m7 "Cultural Services and Entertainment(monthly)"


* 10. PERSONAL SERVICES AND OTHER PAYMENTS

* Semanales
* -----------------------------------------------------------------------------*
egen T2_expen_7d9a=rowtotal(M552_VALOR M63E_VALOREST), missing
replace T2_expen_7d9a = T2_expen_7d9a*(30/7) if T2_expen_7d9a!=. 
rename T2_expen_7d9a T2_expen_m9a

meanimput_h "T2_expen_m9a"


* Mensuales 
* -----------------------------------------------------------------------------*
egen T2_expen_mon9b=rowtotal(M722_VALOR M742_VALOR M752_VALOR M762_VALOR M83B_VALOREST) , missing
rename T2_expen_mon9b T2_expen_m9b

meanimput_h "T2_expen_m9b"

* Anuales 
********************************************************************************
egen T2_expen_y9c=rowtotal(M1162_VALOR_CONTADO M11162_VALOR_CONTADO M1182_VALOR_CONTADO M1182_VALOR_CREDITO M11112_VALOR_CONTADO M11112_VALOR_CREDITO M11122_VALOR_CONTADO M11122_VALOR_CREDITO M11132_VALOR_CONTADO M11132_VALOR_CREDITO M11162_VALOR_CONTADO M11162_VALOR_CREDITO M11182_VALOR_CONTADO M11182_VALOR_CREDITO M11192_VALOR_CONTADO M11192_VALOR_CREDITO M123H_VALOREST M123K_VALOREST M123L_VALOREST M123M_VALOREST M123P_VALOREST M123R_VALOREST M123S_VALOREST) , missing
replace T2_expen_y9c=T2_expen_y9c*(1/12) if T2_expen_y9c!=.
rename T2_expen_y9c T2_expen_m9c

meanimput_h "T2_expen_m9c"

egen T2_expen_m9=rowtotal(T2_expen_m9a T2_expen_m9b T2_expen_m9c) , missing
la var T2_expen_m9 "Personal Services and other payments(monthly)"

save "$dropbox\EMB2011\derived\Gasto_NoServiciosSaludEduc.dta", replace
}
*

// GASTOS INDIVIDUALES A NIVEL HOGAR
* Salud ........................................................................
use "$dropbox\EMB2011\derived\Gasto_NoServiciosSaludEduc.dta", clear
egen T2_infoav5a=rowtotal(f01 f0501 f0801 f31 f38a f38b f38c f38d f38e f38f f41a f41b), missing
egen T2_expen_mon5a=rowtotal(f6 f14_valor f31_valor f38a_pago f38b_pago f38c_pago f38d_pago f38e_pago f38f_pago f40 f41a_valor f41b_valor) if T2_infoav5a>0 & T2_infoav5a!=. , missing

egen T2_expen_m5a=rowtotal(T2_expen_mon5a) if T2_infoav5a>0 & T2_infoav5a!=. , missing
replace T2_expen_m5a=. if T2_infoav5a==0
rename T2_expen_m5a T2_expen_m5


*Educacion .....................................................................
* Alimentos en la escuela 
gen 	G13_VALORMES = G13_VALORPAG-G13_VALOREST if G13!=. 
replace G13_VALORMES = G13_VALORMES*4 if G13_VALORMES!=. 
gen 	H22_VALORMES = H22_PAGADO- H22_ESTIMADO if H22!=. 
replace H22_VALORMES = H22_VALORMES*4 if H22_VALORMES!=. 

egen T2_infoav8=rowtotal(G7 G8 G9 G10 G11 G12 G13 H17 H18 H22 H23A H23B H24 H25 H26A H26B H26C H28A H28B H28C H30)
egen T2_expen_mon8=rowtotal(G10_VALOR G11_VALOR G12_VALOR G13_VALORMES H17_VALOR H18_VALOR H22_VALORMES H24_VALOR H25_VALOR H26A_VALOR H26B_VALOR H28A_VALOR H28B_VALOR H30_VALOR) if T2_infoav8>0 & T2_infoav8!=. , missing
egen T2_expen_y8=rowtotal(G7_VALOR G8_VALOR G9_VALOR H23A_VALOR H23B_VALOR)  if T2_infoav8>0 & T2_infoav8!=. , missing
replace T2_expen_y8=T2_expen_y8*(1/12) if T2_expen_y8!=.

egen T2_expen_m8=rowtotal(T2_expen_mon8 T2_expen_y8), missing
replace T2_expen_m8=. if T2_infoav8==0
replace T2_expen_m8=0 if G7==. & G8==. & G9==. & G10==. & G11==. & G12==. & G13==. & H17==. & H18==. & H22==. & H23A==. & H23B==. & H24==. & H25==. & H26A==. & H26B==. & H26C==. & H28A==. & H28B==. & H28C==. & H30==. 

lab var T2_expen_m8 "HH Expenses on Education(monthly)"

la var T2_expen_m5 "HH Expenses on Health (monthly)"

save "$dropbox\EMB2011\derived\Gasto_NoServicios.dta", replace

// GASTOS DEL HOGAR: SERVICIOS Y ARRIENDO
cleanvars "d13 d19 d24 d5 d29 d33"


replace d15_pago= d15_pago/d15_meses if d15_pago!=. & d15_pago!=99 & d15_meses!=. & d15_meses!=0
replace d21_pago= d21_pago/d21_meses if d21_pago!=. & d21_pago!=99 & d21_meses!=. & d21_meses!=0
replace d25a_valor= d25a_valor/d25a_meses if d25a_valor!=. & d25a_valor!=99 & d25a_meses!=. & d25a_meses!=0
replace d7_pago= d7_pago/d7_meses if d7_pago!=. & d7_pago!=99 & d7_meses!=. & d7_meses!=0
replace d25b_valor=d25b_valor/d25b_meses if d25b_valor!=. & d25b_meses!=.
replace d25c_valor=d25c_valor/c25c_meses if d25c_valor!=. & d25c_valor!=99 & c25c_meses!=. & c25c_meses!=0
replace d30=d30/d30_meses if d30!=. & d30_meses!=. 
replace d34=d34/d34_meses if d34_recibo!=. & d34_meses!=. 

meanimput_h "d15_pago d21_pago d25a_valor d7_pago d25b_valor d25c_valor d30 d34 c9_valor c10_valor c14_valor"

egen T2_expen_mon3_a=rowtotal(d15_pago d21_pago d25a_valor d7_pago d25b_valor d25c_valor d30 d34 c9_valor c10_valor c14_valor), missing
egen T2_expen_m3_a=rowtotal(T2_expen_mon3_a), missing

rename T2_expen_m3 T2_expen_m3_b
egen T2_expen_m3=rowtotal(T2_expen_m3_b T2_expen_m3_a)
cap drop T2_expen_m3_b T2_expen_m3_a T2_expen_mon3_a T1_expen_30d T1_expen_20d T1_expen_15d T1_expen_7d T2_infoav2_b T2_expen_m2b T2_expen_m2a T2_infoav2 T2_expen_m3b T2_expen_m3c T2_expen_m6a T2_expen_m6b T2_expen_m6c T2_expen_m7b T2_expen_m7c T2_expen_m7d T2_expen_m9a T2_expen_m9b T2_expen_m9c T2_expen_mon5a T2_expen_mon8 T2_expen_y8
label var T2_expen_m3 "Household services (monthly)"

replace alimExpenses=0 if T1_expen_m1==0

* TOTAL EXPENSES HOUSEHOLD *****************************************************
*egen totalExpenses= rowtotal(T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9 ) if missing(T1_infoav,T2_infoav1,T2_infoav2,T2_infoav3,T2_infoav4,T2_infoav5,T2_infoav6,T2_infoav7,T2_infoav8,T2_infoav9)==0 & (T1_infoav>0 | T2_infoav1>0 | T2_infoav2>0 | T2_infoav3>0 | T2_infoav4>0 | T2_infoav5>0 | T2_infoav6>0 | T2_infoav7>0 | T2_infoav7>0 | T2_infoav8>0 | T2_infoav9>0)  , missing
egen totalExpenses= rowtotal(T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9), missing 
label var totalExpenses "Total expenses (monthly)"


gsort + id_hogar - T1_infoav - T2_infoav5a - T2_infoav8 + orden 
collapse (first) alimExpenses T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9  totalExpenses T2_infoav8 T2_infoav5a id_vivienda ManCodigo b04012, by(id_hogar)

la var T1_expen_m1 "Food expenses"
la var alimExpenses "Food expenses (no tails)"
la var T2_expen_m1 "Alcohol and Tobacco expenses"
la var T2_expen_m2 "Clothing and footwear (monthly)"
la var T2_expen_m3 "Household services (monthly)"
la var T2_expen_m4 "Furniture (monthly)"
la var T2_expen_m5 "Health expenses (monthly)"
la var T2_expen_m6 "Transportation (monthly)"
la var T2_expen_m7 "Cultural and recreational services(monthly)"
la var T2_expen_m8 "Education expenses(monthly)"
la var T2_expen_m9 "Other payments(monthly)"

keep 	id_hogar ManCodigo totalExpenses alimExpenses T1_expen_m1 T2_expen_m1 T2_expen_m2 ///
		T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 ///
		T2_expen_m8 T2_expen_m9 b04012
		
recode b04012 (1=1 "1")(2=2 "2")(3=3 "3")(4/6=4 "4+") , g(strata)
replace strata=. if strata==9		

save "$dropbox\EMB2011\derived\EMB2011_expenditures_a.dta", replace

save "$dropbox\EMB2011\derived\EMB2011_expenditures1.dta" ,replace
