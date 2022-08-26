* Author: Susana Otálvaro Ramírez (susana.otalvaro@urosario.edu.co) 
* Based on: Metodología de cálculo de la variable ingreso ECV 2015
* Date: 2018.12.12
* Goal: produce total income of the HH for the EMB2011 (no imputation or outlier analysis here!)

glo dropbox "C:\Users\\`c(username)'\Dropbox\tabacoDrive\\Tobacco-health-inequalities\data"

use "$dropbox\EMB2011\derived\GEOVivienda_Hogar_Persona.dta", clear 

foreach varDep in K38 K39A K39B K39C K39D K39E K31 K32 K33 K34 K35 K36 K37 K46 K47 K51 K52 K53 K54 K55 K56 K57 {
	destring `varDep', replace
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
}
foreach varDep in K30_VALOR_MES	K38_VALOR K39A_VALOR K39B_VALOR K39C_VALOR K39D_VALOR K39E_VALOR K31_VALMES_EST K32_VALMES_EST K33_VALMES_EST K34_VALMES_EST K35_VALOR K36_VALOR K37_VALOR K40_GANACIA K41_MESES K46_VALOR K47_VALOR K51_VALOR K52_VALOR K53_VALOR K54_VALOR K55_VALOR K56_VALOR K57_VALOR{
	destring `varDep', replace 
	replace `varDep'=. if `varDep'==98 |`varDep'==99 | `varDep'==9999
}
*

//INCOME CATEGORIES (monthly)
* Labour monetary income *******************************************************
gen gan=.
replace gan= K40_GANACIA/K41_MESES if K40_GANACIA!=.

gen 	il_mon=K30_VALOR_MES														//main wage
replace il_mon=il_mon + K38_VALOR	 	if il_mon!=. & K38_VALOR!=.
replace il_mon=il_mon + K38_VALOR	 	if il_mon!=. & K38_VALOR!=. 
replace il_mon=il_mon + K39A_VALOR/12 	if il_mon!=. & K39A_VALOR!=.
replace il_mon=il_mon + K39B_VALOR/12 	if il_mon!=. & K39B_VALOR!=.
replace il_mon=il_mon + K39C_VALOR/12 	if il_mon!=. & K39C_VALOR!=.
replace il_mon=il_mon + K39D_VALOR/12 	if il_mon!=. & K39D_VALOR!=.
replace il_mon=il_mon + K39E_VALOR/12 	if il_mon!=. & K39E_VALOR!=.
replace il_mon=K38_VALOR	 if il_mon==. & K38_VALOR!=.							//primas
replace il_mon=K39A_VALOR/12 if il_mon==. & K39A_VALOR!=.							//primas
replace il_mon=K39B_VALOR/12 if il_mon==. & K39B_VALOR!=.
replace il_mon=K39C_VALOR/12 if il_mon==. & K39C_VALOR!=.
replace il_mon=K39D_VALOR/12 if il_mon==. & K39D_VALOR!=.
replace il_mon=K39E_VALOR/12 if il_mon==. & K39E_VALOR!=.
replace il_mon=il_mon + gan if il_mon!=. & gan!=. 									//ganancias netas
replace il_mon=gan if il_mon==. & gan!=. 									

replace il_mon=il_mon + K46_VALOR 	if il_mon!=. &  K46_VALOR!=. 						//other jobs
replace il_mon=K46_VALOR 			if il_mon==. &  K46_VALOR!=. 	

replace il_mon=il_mon + K47_VALOR 	if il_mon!=. &  K47_VALOR!=. 					//other labour income
replace il_mon=K47_VALOR 			if il_mon==. &  K47_VALOR!=. 	

* Labour income (in-kind)********************************************************
gen il_ink=. 
replace il_ink= K31_VALMES_EST 			if K31==1 & K31_VALMES_EST!=. 
replace il_ink= il_ink + K32_VALMES_EST if K32==1 & K32_VALMES_EST!=.
replace il_ink= K32_VALMES_EST 			if il_ink==. & K32==1 & K32_VALMES_EST!=.
replace il_ink= il_ink + K33_VALMES_EST if K33==1 & K33_VALMES_EST!=.
replace il_ink= K33_VALMES_EST 			if il_ink==. & K33==1 & K33_VALMES_EST!=.
replace il_ink= il_ink + K34_VALMES_EST if K34==1 & K34_VALMES_EST!=.
replace il_ink= K34_VALMES_EST 			if il_ink==. & K34==1 & K34_VALMES_EST!=.

* Labour income (subsides)******************************************************
gen il_sub=.
replace il_sub= K35_VALOR 				if K35==1 & K35_VALOR!=.
replace il_sub= il_sub + K36_VALOR 		if K36==1 & K36_VALOR!=.  
replace il_sub= K36_VALOR 				if il_sub==. & K36==1 & K36_VALOR!=. 
replace il_sub= il_sub + K37_VALOR 		if K37==1 & K37_VALOR!=. 
replace il_sub= K37_VALOR 				if il_sub==. & K37==1 & K37_VALOR!=. 

* Labour income (total)******************************************************
gen     i_lab=il_mon
replace i_lab=i_lab+il_ink if il_ink!=. & i_lab!=.
replace i_lab=il_ink if i_lab==. & il_ink!=.
replace i_lab=i_lab+il_sub if il_sub!=. & i_lab!=.
replace i_lab=il_sub if i_lab==. &il_sub!=.

label var il_ink "Labour income: In-kind"
label var il_mon "Labour income: Monetary"
label var il_sub "Labour income: Subsides"

label var i_lab "Labour income: total"

* Capital income ***************************************************************
gen i_cap= K53_VALOR 					if K53==1 & K53_VALOR!=. 					//Ingresos por arriendo/venta de lotes 
replace i_cap= i_cap + K57_VALOR/12		if K57==1 & K57_VALOR!=.				//Cesantías
replace i_cap= (K57_VALOR/12) 			if i_cap==. & K57==1 & K57_VALOR!=.


* Pension income or similars ***************************************************
gen i_pens=.
replace i_pens= K51_VALOR 				if K51==1 & K51_VALOR!=.
replace i_pens= i_pens + K52_VALOR 		if K52==1 & K52_VALOR!=.
replace i_pens= K52_VALOR 				if i_pens==. & K52==1 & K52_VALOR!=.
replace i_pens= i_pens + (K54_VALOR/12) if K54==1 & K54_VALOR!=. 
replace i_pens= (K54_VALOR/12)			if i_pens==. & K54==1 & K54_VALOR!=. 

label var i_cap "Capital income"
label var i_pens "Pension income or similar"

keep id_vivienda localidad id_hogar orden estrato fex_c i_lab i_cap i_pens K57_VALOR

egen incomePer1=rowtotal(i_lab i_cap i_pens), missing
replace incomePer1=incomePer1-(K57_VALOR/12) if K57_VALOR!=. 
label var incomePer1 "Total individual income -LF info-(monthly)"

collapse(sum) incomeHH1=incomePer1, by(id_hogar fex_c)
label var incomeHH1 "Total HH income -Labour force info-"

save "$dropbox\EMB2011\derived/EMB2011_incomePers1.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// CHILDREN CARE INFORMATION
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\EMB2011\derived\GEOVivienda_Hogar_Persona.dta", clear 

********** Clean variables

foreach varDep in G13 {
	replace `varDep'=0 if `varDep'==2
}
foreach varDep in 	G13_VALORPAG G13_VALOREST{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 // Missings
}

gen i_alim=. 
replace i_alim=(G13_VALOREST - G13_VALORPAG)*4 if G13==1 & G13_VALOREST!=. & G13_VALORPAG!=.

keep id_vivienda localidad id_hogar orden estrato fex_c  i_alim

egen incomePer2= rowtotal(i_alim) , missing
label var incomePer2 "Total individual income -CC info-(monthly)"

collapse(sum) incomeHH2=incomePer2, by(id_hogar fex_c)
label var incomeHH2 "Total HH income -Children care info-"

save "$dropbox\EMB2011\derived/EMB2011_incomePers2.dta" ,replace

////////////////////////////////////////////////////////////////////////////////
////// EDUCATION INFORMATION
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\EMB2011\derived\GEOVivienda_Hogar_Persona.dta", clear 

*********** Clean variables

foreach varDep in H22 H26A H26B H26C H28A H28B H28C	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
}
*
foreach varDep in 	H22_PAGADO H22_ESTIMADO ///
					H28A_VALOR  H28B_VALOR ///
					H26A_VALOR H26B_VALOR {
	replace `varDep'=. if `varDep'==98 |`varDep'==99 
}
*
foreach variable in H28A_PERIODO H28B_PERIODO H26A_PERIODO H26B_PERIODO{
	replace `variable'= 6 if `variable'==3
	replace `variable'= 12 if `variable'==4
}

gen i_educ=.
replace i_educ= (H22_ESTIMADO - H22_PAGADO)*4 		if H22==1 	//Comida gratis

replace i_educ= i_educ + H28A_VALOR/H28A_PERIODO 	if H28A==1 & H28A_VALOR!=.  //Subsidios educativos (anuales)
replace i_educ= H28A_VALOR/H28A_PERIODO 			if i_educ==. & H28A==1 & H28A_VALOR!=.  //Subsidios educativos (anuales)

replace i_educ= i_educ + H26A_VALOR/H26A_PERIODO 	if H26A==1 & H26A_VALOR!=.  		// Beca 
replace i_educ= H26A_VALOR/H26A_PERIODO 			if i_educ==. & H26A==1 & H26A_VALOR!=.  //Beca

keep id_vivienda localidad id_hogar orden estrato fex_c i_educ 
egen incomePer3= rowtotal(i_educ) , missing

label var incomePer3 "Total individual income -Education info-(monthly)"
collapse(sum) incomeHH3=incomePer3, by(id_hogar fex_c)
label var incomeHH3 "Total HH income -Education info-"


save "$dropbox\EMB2011\derived/EMB2011_incomePers3.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// HOUSING CONDITIONS AND LIVING
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\EMB2011\derived\GEOVivienda_Hogar_Persona.dta", clear 

*********** Clean variables
foreach varDep in 	K55	{
	destring `varDep', replace 
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
}
*
foreach varDep in 	K55_VALOR {
	destring K55_VALOR, replace
	replace `varDep'=. if `varDep'==98 |`varDep'==99 
}
*
gen i_other=.
replace i_other= K55_VALOR/12 if K55==1 & K55_VALOR!=. 								//Ayudas PERSONAS O INSTITUCIONES

keep id_vivienda localidad id_hogar orden estrato fex_c i_other
egen incomePer4= rowtotal(i_other) , missing

label var incomePer4 "Total individual income -Subsides-(monthly)"
collapse(sum) incomeHH4=incomePer4, by(id_hogar fex_c)
label var incomeHH4 "Total HH income -Housing conditions info-"

save "$dropbox\EMB2011\derived/EMB2011_incomePers4.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// HOUSE FINANCING
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\EMB2011\derived\GEOVivienda_Hogar_Persona.dta", clear 

*********** Clean variables
foreach varDep in 	c1 {
	replace `varDep'=. if `varDep'==9 // Missings
}
*
foreach varDep in 	c14 c16 c17 {
	replace `varDep'=0 if `varDep'==2 
	replace `varDep'=. if `varDep'==9 // Missings
}
*
foreach varDep in 	c2_valor c5_valor c7 c9_valor c10_valor c14_valor c16_valor c17_valorest {
	replace `varDep'=. if `varDep'==98 |`varDep'==99 
}
*
gen i_hous=.
replace i_hous=c10_valor if (c1==3 & c10_valor!=.) | (c1==4 & c10_valor!=.)  							//They own the house or don't pay for living in it
replace i_hous=0 if c1==2 & ((c9_valor-c2_valor)<0) & c9_valor!=. & c2_valor!=.    						//They have a credit to pay the house
replace i_hous=0 if (c1==2 & c2_valor==.) | (c1==2 & c9_valor==.)  
replace i_hous=(c9_valor-c2_valor) if  c1==2 & c9_valor!=.  & c2_valor!=.  & ((c9_valor-c2_valor)>0) 
replace i_hous=(c5_valor-c7) if (c5_valor-c7)>0
replace i_hous=0 if (c5_valor-c7)<0


keep id_vivienda localidad id_hogar orden estrato fex_c i_hous
egen incomeHog1= rowtotal(i_hous) , missing

label var incomeHog1 "Total individual income -HF info-(monthly)"

collapse(sum) incomeHH5=incomeHog1, by(id_hogar fex_c)
label var incomeHH5 "Total HH income -House financing info-"

save "$dropbox\EMB2011\derived/EMB2011_incomeHog1.dta" ,replace

//Merge all the information you have constructed in the last steps of the do file
use "$dropbox\EMB2011\derived/EMB2011_incomeHog1.dta" , clear

merge n:1 id_hogar using "$dropbox\EMB2011\derived/EMB2011_incomePers4.dta" , keep(master match) nogen
merge n:1 id_hogar using "$dropbox\EMB2011\derived/EMB2011_incomePers3.dta" , keep(master match) nogen
merge n:1 id_hogar using "$dropbox\EMB2011\derived/EMB2011_incomePers2.dta" , keep(master match) nogen
merge n:1 id_hogar using "$dropbox\EMB2011\derived/EMB2011_incomePers1.dta" , keep(master match) nogen 


egen incomeHH=rowtotal(incomeHH1 incomeHH2 incomeHH3 incomeHH4 incomeHH5)
label var incomeHH "Total Household Income"

save "$dropbox\EMB2011\derived/EMB2011_incomeHH.dta", replace 

*ssc install conindex
svyset id_hogar [pw=fex_c]
conindex incomeHH, rankvar(incomeHH) svy truezero graph


