* Author: Susana Otálvaro Ramírez (susana.otalvaro@urosario.edu.co) 
* Based on: Metodología de cálculo de la variable ingreso ECV 2015
* Date: 2017.08.14
* Goal: produce total income of the HH for the ENCV2011 (no imputation or outlier analysis here!)

glo dropbox "C:\Users\Usuario\Dropbox\Tobacco-health-inequalities\data"
glo dropbox "C:\Users\susana.otalvaro\Dropbox\Tobacco-health-inequalities\data"
glo dropbox "C:\Users\\`c(username)'\Dropbox\tabacoDrive\\Tobacco-health-inequalities\data"


clear all
/* 
import delimited "$dropbox\ECVB2007\original\Cond_vida.txt"
save "$dropbox\ECVB2007\original\Cond_vida.dta", replace
clear all

import delimited "$dropbox\ECVB2007\original\Gastos.txt"
save "$dropbox\ECVB2007\original\Gastos.dta", replace
clear all

import delimited "$dropbox\ECVB2007\original\Hogar.txt"
save "$dropbox\ECVB2007\original\Hogar.dta", replace
clear all

import delimited "$dropbox\ECVB2007\original\Persona.txt"
save "$dropbox\ECVB2007\original\Persona.dta", replace
clear all

import delimited "$dropbox\ECVB2007\original\Vivienda.txt"
save "$dropbox\ECVB2007\original\Vivienda.dta", replace
*/

use "$dropbox\ECVB2007\original\Persona.dta"

foreach varDep in j41_primas j13_alim_pago j14_viv_pago j15_otros_pago j16_tiene_ruta j40_ing_lotes_fincas j44_inter_cdt_prest j17_sub_alim_mes_ant j42_cesantias j43_primas_pension ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
}
foreach varDep in 	j12_cuanto_gano  ///
					j1701_valor j1801_valor j1901_valor ///
					j4101_valor ///
					j22_ganancia  ///
					j1301_valor j1401_valor j1501_valor j1601_valor ///
					j3101_val_tot_recib j3401_valor ///
					j4001_valor ///
					j3801_valor j3901_valor j4301_valor ///
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99
}


//INCOME CATEGORIES (monthly)
* Labour monetary income *******************************************************
gen gan=.
replace gan= j22_ganancia/j23_cuantos_meses if j22_ganancia!=.

gen 	il_mon=j12_cuanto_gano														//main wage
replace il_mon=il_mon + j4101_valor/12 	if il_mon!=. & j4101_valor!=. 
replace il_mon=j4101_valor/12 if il_mon==. & j4101_valor!=.							//primas
replace il_mon=il_mon + gan if il_mon!=. & gan!=. 									//ganancias netas
replace il_mon=gan if il_mon==. & gan!=. 									

replace il_mon=il_mon + j3101_val_tot_recib if il_mon!=. &  j3101_val_tot_recib!=. 	//other jobs
replace il_mon=j3101_val_tot_recib if il_mon==. &  j3101_val_tot_recib!=. 	

replace il_mon=il_mon + j3401_valor if il_mon!=. &  j3401_valor!=. 					//other labour income
replace il_mon=j3401_valor if il_mon==. &  j3401_valor!=. 	

* Labour income (in-kind)********************************************************
gen il_ink=. 
replace il_ink= j1301_valor if j13_alim_pago==1 & j1301_valor!=. 
replace il_ink= il_ink + j1401_valor if j14_viv_pago==1 & j1401_valor!=.
replace il_ink= j1401_valor if il_ink==. & j14_viv_pago==1 & j1401_valor!=.
replace il_ink= il_ink + j1501_valor if j15_otros_pago==1 & j1501_valor!=.
replace il_ink= j1501_valor if il_ink==. & j15_otros_pago==1 & j1501_valor!=.
replace il_ink= il_ink + j1601_valor if j16_tiene_ruta==1 & j1601_valor!=.
replace il_ink= j1601_valor if il_ink==. & j16_tiene_ruta==1 & j1601_valor!=.

* Labour income (subsides)******************************************************
gen il_sub=.
replace il_sub= j1701_valor if j17_sub_alim_mes_ant==1 & j1701_valor!=.
replace il_sub= il_sub + j1801_valor if j18_aux_transp==1 & j1801_valor!=.  
replace il_sub= j1801_valor if il_sub==. & j18_aux_transp==1 & j1801_valor!=. 
replace il_sub= il_sub + j1901_valor if j19_sub_fam==1 & j1901_valor!=. 
replace il_sub= j1901_valor if il_sub==. & j19_sub_fam==1 & j1901_valor!=. 

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
gen i_cap= j4001_valor if j40_ing_lotes_fincas==1 & j4001_valor!=. 					//Ingresos por arriendo/venta de lotes 
replace i_cap= i_cap + j4201_valor if j42_cesantias==1 & j4201_valor!=.				//Cesantías
replace i_cap= j4201_valor if i_cap==. & j42_cesantias==1 & j4201_valor!=.


* Pension income or similars ***************************************************
gen i_pens=.
replace i_pens= j3801_valor if j38_ing_pension==1 & j3801_valor!=.
replace i_pens= i_pens + j3901_valor if j39_pens_alimento==1 & j3901_valor!=.
replace i_pens= j3901_valor if i_pens==. & j39_pens_alimento==1 & j3901_valor!=.
replace i_pens= i_pens + j4301_valor if j43_primas_pension==1 & j4301_valor!=. 
replace i_pens= j4301_valor if i_pens==. & j43_primas_pension==1 & j4301_valor!=. 

label var i_cap "Capital income"
label var i_pens "Pension income or similar"

keep identificador_viv id_depto id_loc nro_hogar e01_nro_orden b_reg_nro fex_calib i_lab i_cap i_pens j4201_valor

egen incomePer1=rowtotal(i_lab i_cap i_pens), missing
replace incomePer1=incomePer1-j4201_valor if j4201_valor!=. 
label var incomePer1 "Total individual income -LF info-(monthly)"

collapse(sum) incomeHH1=incomePer1, by(nro_hogar identificador_viv fex_calib)
label var incomeHH1 "Total HH income -Labour force info-"

save "$dropbox\ECVB2007\derived/ECVB2007_incomePers1.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// CHILDREN CARE INFORMATION
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\ECVB2007\original\Persona.dta"

********** Clean variables

foreach varDep in g20_almuerzo_gratis g21_recibe_med_nuev g22_recibe_onces ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
}
foreach varDep in 	g2001_cuanto_paga_dia g2002_cuanto_compra ///
					g2101_cuanto_paga_dia g2102_cuanto_compra ///
					g2201_cuanto_paga_dia g2202_cuanto_compra ///
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 // Missings
}

gen i_alim=. 
replace i_alim=(g2002_cuanto_compra - g2001_cuanto_paga_dia)*15 if g20_almuerzo_gratis==1 & g2001_cuanto_paga_dia!=. & g2002_cuanto_compra!=.
replace i_alim=i_alim + (g2102_cuanto_compra - g2101_cuanto_paga_dia)*15 if g21_recibe_med_nuev==1 & g2101_cuanto_paga_dia!=. & g2102_cuanto_compra!=.
replace i_alim=(g2102_cuanto_compra - g2101_cuanto_paga_dia)*15 if g21_recibe_med_nuev==1 & g2101_cuanto_paga_dia!=. & g2102_cuanto_compra!=. & i_alim==.
replace i_alim=i_alim + (g2202_cuanto_compra - g2201_cuanto_paga_dia)*15 if g22_recibe_onces==1 & g2201_cuanto_paga_dia!=. & g2202_cuanto_compra!=. 
replace i_alim=(g2202_cuanto_compra - g2201_cuanto_paga_dia)*15 if g22_recibe_onces==1 & g2201_cuanto_paga_dia!=. & g2202_cuanto_compra!=. & i_alim==.

keep identificador_viv id_depto id_loc nro_hogar e01_nro_orden b_reg_nro fex_calib i_alim

egen incomePer2= rowtotal(i_alim) , missing
label var incomePer2 "Total individual income -CC info-(monthly)"

collapse(sum) incomeHH2=incomePer2, by(nro_hogar identificador_viv fex_calib)
label var incomeHH2 "Total HH income -Children care info-"

save "$dropbox\ECVB2007\derived/ECVB2007_incomePers2.dta" ,replace

////////////////////////////////////////////////////////////////////////////////
////// EDUCATION INFORMATION
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\ECVB2007\original\Persona.dta"

*********** Clean variables

foreach varDep in i14_rec_com_gratis i1501_refrigerio i1502_desayuno i1503_almuerzo i30_rec_beca_ano i2701_din_asist_esc i2702_util_escol i2703_trans_esc i2704_cost_edu_grat i2705_din_bon_pag_mat i2901_sub_gob_nal i30_rec_beca_ano ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
}



foreach varDep in 	i1402_cuanto_pagaria i1401_cuanto_paga_dia ///
					i2803_valor i2801_valor ///
					i3103_valor i3101_valor ///
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 
}

gen i_educ=.
replace i_educ= (i1402_cuanto_pagaria - i1401_cuanto_paga_dia)*15 			if i14_rec_com_gratis==1 & i1501_refrigerio==1 & i1402_cuanto_pagaria!=. & i1401_cuanto_paga_dia!=. 				//Refrigerio
replace i_educ= i_educ + (i1402_cuanto_pagaria - i1401_cuanto_paga_dia)*15 	if i14_rec_com_gratis==1 & i1502_desayuno==1 & i1402_cuanto_pagaria!=. & i1401_cuanto_paga_dia!=. & i_educ!=.  		//Desayuno
replace i_educ= (i1402_cuanto_pagaria - i1401_cuanto_paga_dia)*15 			if i14_rec_com_gratis==1 & i1502_desayuno==1 & i1402_cuanto_pagaria!=. & i1401_cuanto_paga_dia!=. & i_educ==.  		
replace i_educ= i_educ + (i1402_cuanto_pagaria - i1401_cuanto_paga_dia)*15 	if i14_rec_com_gratis==1 & i1503_almuerzo==1 & i1402_cuanto_pagaria!=. & i1401_cuanto_paga_dia!=. & i_educ!=.  		//Almuerzo
replace i_educ= (i1402_cuanto_pagaria - i1401_cuanto_paga_dia)*15 			if i14_rec_com_gratis==1 & i1503_almuerzo==1 & i1402_cuanto_pagaria!=. & i1401_cuanto_paga_dia!=. & i_educ==.  		

replace i_educ= i_educ + i2801_valor/12 if (i2802_frecuencia==4 & i26_recibio_subsidio==1) | (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1) | (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i2702_util_esc==1) | (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i2703_trans_esc==1) | (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1) | (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1) //Subsidios educativos (anuales)
replace i_educ= i2801_valor/12 if (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i_educ==.) | (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1 & i_educ==.) | (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i2702_util_esc==1 & i_educ==.) | (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i2703_trans_esc==1 & i_educ==.) | (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1 & i_educ==.) | (i2802_frecuencia==4 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1 & i_educ==.) 	//Subsidios educativos (anuales)
replace i_educ= i_educ + i2801_valor/6  if (i2802_frecuencia==3 & i26_recibio_subsidio==1) | (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1) | (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i2702_util_esc==1) | (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i2703_trans_esc==1) | (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1) | (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1) 																	//Subsidios educativos (semestrales)
replace i_educ= i2801_valor/6  if (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i_educ==.) | (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1 & i_educ==.) | (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i2702_util_esc==1 & i_educ==.) | (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i2703_trans_esc==1 & i_educ==.) | (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1 & i_educ==.) | (i2802_frecuencia==3 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1 & i_educ==.) 	
replace i_educ= i_educ + i2801_valor/2  if (i2802_frecuencia==2 & i26_recibio_subsidio==1) | (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1) | (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i2702_util_esc==1) | (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i2703_trans_esc==1) | (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1) | (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1) 																	//Subsidios educativos (bimestrales)
replace i_educ= i2801_valor/2  if (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i_educ==.) | (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1 & i_educ==.) | (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i2702_util_esc==1 & i_educ==.) | (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i2703_trans_esc==1 & i_educ==.) | (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1 & i_educ==.) | (i2802_frecuencia==2 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1 & i_educ==.)
replace i_educ= i_educ + i2801_valor  if (i2802_frecuencia==1 & i26_recibio_subsidio==1) | (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1) | (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i2702_util_esc==1) | (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i2703_trans_esc==1) | (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1) | (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1) 																	//Subsidios educativos (bimestrales)
replace i_educ= i2801_valor  if (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i_educ==.) | (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1 & i_educ==.) | (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i2702_util_esc==1 & i_educ==.) | (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i2703_trans_esc==1 & i_educ==.) | (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1 & i_educ==.) | (i2802_frecuencia==1 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1 & i_educ==.)
replace i_educ= i_educ + (i2803_valor-i2801_valor)/12 if (i2804_frecuencia==4 & i26_recibio_subsidio==1) | (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1) | (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i2702_util_esc==1) | (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i2703_trans_esc==1) | (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1) | (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1) //Subsidios educativos (anuales)
replace i_educ= (i2803_valor-i2801_valor)/12 if (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i_educ==.) | (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1 & i_educ==.) | (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i2702_util_esc==1 & i_educ==.) | (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i2703_trans_esc==1 & i_educ==.) | (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1 & i_educ==.) | (i2804_frecuencia==4 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1 & i_educ==.) 	//Subsidios educativos (anuales)
replace i_educ= i_educ + (i2803_valor-i2801_valor)/6  if (i2804_frecuencia==3 & i26_recibio_subsidio==1) | (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1) | (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i2702_util_esc==1) | (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i2703_trans_esc==1) | (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1) | (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1) 																	//Subsidios educativos (semestrales)
replace i_educ= (i2803_valor-i2801_valor)/6  if (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i_educ==.) | (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1 & i_educ==.) | (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i2702_util_esc==1 & i_educ==.) | (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i2703_trans_esc==1 & i_educ==.) | (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1 & i_educ==.) | (i2804_frecuencia==3 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1 & i_educ==.) 	
replace i_educ= i_educ + (i2803_valor-i2801_valor)/2  if (i2804_frecuencia==2 & i26_recibio_subsidio==1) | (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1) | (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i2702_util_esc==1) | (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i2703_trans_esc==1) | (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1) | (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1) 																	//Subsidios educativos (bimestrales)
replace i_educ= (i2803_valor-i2801_valor)/2  if (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i_educ==.) | (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1 & i_educ==.) | (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i2702_util_esc==1 & i_educ==.) | (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i2703_trans_esc==1 & i_educ==.) | (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1 & i_educ==.) | (i2804_frecuencia==2 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1 & i_educ==.)
replace i_educ= i_educ + (i2803_valor-i2801_valor)  if (i2804_frecuencia==1 & i26_recibio_subsidio==1) | (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1) | (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i2702_util_esc==1) | (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i2703_trans_esc==1) | (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1) | (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1) 																	//Subsidios educativos (bimestrales)
replace i_educ= (i2803_valor-i2801_valor)  if (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i_educ==.) | (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i2701_din_asist_esc==1 & i_educ==.) | (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i2702_util_esc==1 & i_educ==.) | (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i2703_trans_esc==1 & i_educ==.) | (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i2704_cost_edu_grat==1 & i_educ==.) | (i2804_frecuencia==1 & i26_recibio_subsidio==1 & i2705_din_bon_pag_mat==1 & i_educ==.)

replace i_educ= i_educ + i3101_valor/12 if (i3102_frecuencia==4 & i30_rec_beca_ano==1)
replace i_educ= i3101_valor/12 if (i3102_frecuencia==4 & i30_rec_beca_ano==1 & i_educ==.)
replace i_educ= i_educ + i3101_valor/6 if (i3102_frecuencia==3 & i30_rec_beca_ano==1)
replace i_educ= i3101_valor/6 if (i3102_frecuencia==3 & i30_rec_beca_ano==1 & i_educ==.)
replace i_educ= i_educ + i3101_valor/2 if (i3102_frecuencia==2 & i30_rec_beca_ano==1)
replace i_educ= i3101_valor/2 if (i3102_frecuencia==2 & i30_rec_beca_ano==1 & i_educ==.)
replace i_educ= i_educ + i3101_valor if (i3102_frecuencia==1 & i30_rec_beca_ano==1)
replace i_educ= i3101_valor if (i3102_frecuencia==1 & i30_rec_beca_ano==1 & i_educ==.)

replace i_educ= i_educ + (i3103_valor-i3101_valor)/12 if (i3104_frecuencia==4 & i30_rec_beca_ano==1)
replace i_educ= (i3103_valor-i3101_valor)/12 if (i3104_frecuencia==4 & i30_rec_beca_ano==1 & i_educ==.)
replace i_educ= i_educ + (i3103_valor-i3101_valor)/6 if (i3104_frecuencia==3 & i30_rec_beca_ano==1)
replace i_educ= (i3103_valor-i3101_valor)/6 if (i3104_frecuencia==3 & i30_rec_beca_ano==1 & i_educ==.)
replace i_educ= i_educ + (i3103_valor-i3101_valor)/2 if (i3104_frecuencia==2 & i30_rec_beca_ano==1)
replace i_educ= (i3103_valor-i3101_valor)/2 if (i3104_frecuencia==2 & i30_rec_beca_ano==1 & i_educ==.)
replace i_educ= i_educ + (i3103_valor-i3101_valor) if (i3104_frecuencia==1 & i30_rec_beca_ano==1)
replace i_educ= (i3103_valor-i3101_valor) if (i3104_frecuencia==1 & i30_rec_beca_ano==1 & i_educ==.)


keep identificador_viv id_depto id_loc nro_hogar e01_nro_orden b_reg_nro fex_calib i_educ 
egen incomePer3= rowtotal(i_educ) , missing

label var incomePer3 "Total individual income -Education info-(monthly)"
collapse(sum) incomeHH3=incomePer3, by(nro_hogar identificador_viv fex_calib)
label var incomeHH3 "Total HH income -Education info-"


save "$dropbox\ECVB2007\derived/ECVB2007_incomePers3.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// HOUSING CONDITIONS AND LIVING
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\ECVB2007\original\Persona.dta"

*********** Clean variables
foreach varDep in 	j45_ing_ayudas j4601_sub_desempleo j4602_sub_adulto_mayor ///
					j4603_fam_jovenes_acc j4604_otro j47_ayuda_ong  j48_ayuda_ong ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
}

foreach varDep in 	j4501_valor ///
					j4701_valor j4801_valor ///					
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 
}

gen i_other=.
replace i_other= j4501_valor/12 if j45_ing_ayudas==1 & j4501_valor!=. 								//Ayudas de gobierno
replace i_other= j4501_valor/12 if j4601_sub_desempleo==1 & j45_ing_ayudas!=1 & j4501_valor!=. 		//Subsidio al desempleo por parte de empresas públicas
replace i_other= j4501_valor/12 if j4602_sub_adulto_mayor==1 & j45_ing_ayudas!=1 & j4501_valor!=. 	//Subsidio al adulto mayor por parte de empresas públicas
replace i_other= j4501_valor/12 if j4603_fam_jovenes_acc==1 & j45_ing_ayudas!=1 & j4501_valor!=. 	//Subsidio Familias en Acción por parte de empresas públicas
replace i_other= j4501_valor/12 if j4604_otro==1 & j45_ing_ayudas!=1 & j4501_valor!=. 				//Otros subsidios
replace i_other= j4701_valor/12 if j47_ayuda_ong==1 & j4701_valor!=.								//Ayudas ONG 
replace i_other= j4801_valor/12 if j48_ayuda_ong==1 & j4801_valor!=.

keep identificador_viv id_depto id_loc nro_hogar e01_nro_orden b_reg_nro fex_calib i_other
egen incomePer4= rowtotal(i_other) , missing

label var incomePer4 "Total individual income -Subsides-(monthly)"
collapse(sum) incomeHH4=incomePer4, by(nro_hogar identificador_viv fex_calib)
label var incomeHH4 "Total HH income -Housing conditions info-"

save "$dropbox\ECVB2007\derived/ECVB2007_incomePers4.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// HOUSE FINANCING
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\ECVB2007\original\Hogar.dta"

*********** Clean variables
foreach varDep in 	d01_viv_hog_tenencia ///
	{
	replace `varDep'=. if `varDep'==9 // Missings
}

foreach varDep in 	d02_valor_amortizacion ///
					d0602_valor_compra_construc ///
					d07_valor_considerado ///
					d11_pago_mes_arriendo ///
					d12_pago_mes_admon ///					
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 
}

gen i_hous=.
replace i_hous=d11_pago_mes_arriendo if (d01_viv_hog_tenencia==4 & d11_pago_mes_arriendo!=.) | (d01_viv_hog_tenencia==5 & d11_pago_mes_arriendo!=.)  							//They own the house or don't pay for living in it
replace i_hous=0 if d01_viv_hog_tenencia==2 & ((d11_pago_mes_arriendo-d02_valor_amortizacion)<0) & d11_pago_mes_arriendo!=. & d02_valor_amortizacion!=.    						//They have a credit to pay the house
replace i_hous=0 if (d01_viv_hog_tenencia==2 & d02_valor_amortizacion==.) | (d01_viv_hog_tenencia==2 & d11_pago_mes_arriendo==.)  
replace i_hous=(d11_pago_mes_arriendo-d02_valor_amortizacion) if  d01_viv_hog_tenencia==2 & d11_pago_mes_arriendo!=.  & d02_valor_amortizacion!=.  & ((d11_pago_mes_arriendo-d02_valor_amortizacion)>0) 
replace i_hous=(d07_valor_considerado-d0602_valor_compra_construc) if (d07_valor_considerado-d0602_valor_compra_construc)>0
replace i_hous=0 if (d07_valor_considerado-d0602_valor_compra_construc)<0


keep identificador_viv id_depto id_loc nro_hogar b_reg_nro fex_calib i_hous
egen incomeHog1= rowtotal(i_hous) , missing

label var incomeHog1 "Total individual income -HF info-(monthly)"

collapse(sum) incomeHH5=incomeHog1, by(nro_hogar identificador_viv fex_calib)
label var incomeHH5 "Total HH income -House financing info-"

save "$dropbox\ECVB2007\derived/ECVB2007_incomeHog1.dta" ,replace

//Merge all the information you have constructed in the last steps of the do file
use "$dropbox\ECVB2007\derived/ECVB2007_incomeHog1.dta" , clear

merge n:1 identificador_viv nro_hogar using "$dropbox\ECVB2007\derived/ECVB2007_incomePers4.dta" , keep(master match) 
drop _merge

merge n:1 identificador_viv nro_hogar using "$dropbox\ECVB2007\derived/ECVB2007_incomePers3.dta" , keep(master match) 
drop _merge 

merge n:1 identificador_viv nro_hogar using "$dropbox\ECVB2007\derived/ECVB2007_incomePers2.dta" , keep(master match) 
drop _merge

merge n:1 identificador_viv nro_hogar using "$dropbox\ECVB2007\derived/ECVB2007_incomePers1.dta" , keep(master match) 
drop _merge

egen incomeHH=rowtotal(incomeHH1 incomeHH2 incomeHH3 incomeHH4 incomeHH5)
label var incomeHH "Total Household Income"


saveold "$dropbox\ECVB2007\derived/ECVB2007_incomeHH.dta", replace 

*ssc install conindex
svyset identificador_viv [pw=fex_calib]
conindex incomeHH, rankvar(incomeHH) svy truezero graph


/*
---------------------------------------------------------------------------------------------------------
Index:                  | No. of obs.  | Index value            | Std. error             | p-value      |
---------------------------------------------------------------------------------------------------------
Gini                    | 26871        | .73491369              |.02657324               |  0.0000      |
---------------------------------------------------------------------------------------------------------
*/

