* Author: Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2018.08.31
* Goal: 

if "`c(username)'"=="paul.rodriguez" {
	glo mainE="D:\Paul.Rodriguez\Dropbox\tabacoDrive\Tobacco-health-inequalities" //Paul
}
else {
	glo mainE="C:\Users\\`c(username)'\Dropbox\tabacoDrive\Tobacco-health-inequalities" // Susana
}

glo mainF="$mainE\data" // Susana

use "$mainF\ECVB2007\derived\ECVB2007_1.dta", clear


la var numadu "Nro. adultos en el hogar"
la var numnin "Nro. niños en el hogar"
la var GastoCte "Current Expenditures"

recode edad (16/25=1 "16 to 25") (26/35=2 "26 to 35") (36/45=3 "36 to 45") (46/55=4 "46 to 55") (56/64=5 "56 to 64") (65/150=6 "65+"), g(edadg)
recode edad (10/19=1 "10 to 19") (20/29=2 "20 to 29") (30/39=3 "30 to 39") (40/49=4 "40 to 49") (50/59=5 "50 to 59") (60/150=6 "60+"), g(edadg1)
replace edadg=. if edad<16
replace edadg1=. if edad<10

svyset id_hogar [pw=fex_calib], strata(id_loc)


gen numcig=tabacoExpenses/cigprice if tabacoExpenses!=. & cigprice!=. & cigprice!=0

gen tabexpper = tabacoExpenses/totalExpenses if totalExpenses!=. & totalExpenses!=0
replace tabexpper=. if tabexpper>1 

gen tabexpper_c = tabacoExpenses/GastoCte if GastoCte!=. & GastoCte!=0
replace tabexpper_c = . if tabexpper_c>1

gen tabac01 =0
replace tabac01=1 if tabexpper>0

gen lngast=ln(persgast)
gen 	curexpper=GastoCte/totalExpenses
replace curexpper=. if curexpper>1 & curexpper!=. 


preserve 
glo maps "C:\Users\susana.otalvaro\Google Drive\Tesis_Susana\Mapas\InputData"
keep if tabac01==0
export delimited 	depto id_loc fex_calib id_hogar tabac01  tabacoExpenses ///
					quintile ManCodigo ECV x_dest y_dest dist1_m dist2_m dist3_m ///
					dist4_m dist5_m dist6_m dist7_m dist8_m sitios_d d1 d2 d3 d4 ///
					d5 d6 d7 d8 cigprice numcig tabexpper ///
					using "$maps\BaseECVB2007NoFumadores.csv", nolabel replace
restore

preserve 
glo maps "C:\Users\susana.otalvaro\Google Drive\Tesis_Susana\Mapas\InputData"
keep if tabac01==1
export delimited 	depto id_loc fex_calib id_hogar tabac01  tabacoExpenses ///
					quintile ManCodigo ECV x_dest y_dest dist1_m dist2_m dist3_m ///
					dist4_m dist5_m dist6_m dist7_m dist8_m sitios_d d1 d2 d3 d4 ///
					d5 d6 d7 d8 cigprice numcig tabexpper ///
					using "$maps\BaseECVB2007Fumadores.csv", nolabel replace
restore



********************************************************************************
** Expenses Categories as a proportion of Total Expenses and Current Expenses **
********************************************************************************
// 1. Food Budget share
* Total Expenses
gen alimexpper = alimExpenses/totalExpenses
replace alimexpper=. if alimexpper>1 
gen alimexpperFUM=alimexpper if numcig>0
gen alimexpperNOFUM=alimexpper if numcig==0

rename alimExpenses1 alimExpensesa
* Total expenses (previous construction of food expenses)
gen alimexppera = alimExpensesa/totalExpenses
replace alimexppera=. if alimexppera>1 
gen alimexpperFUMa=alimexppera if numcig>0
gen alimexpperNOFUMa=alimexppera if numcig==0

* Current expenses
gen alimexpper_c = alimExpenses/GastoCte
replace alimexpper_c=. if alimexpper_c>1 
gen alimexpperFUM_c=alimexpper_c if numcig>0
gen alimexpperNOFUM_c=alimexpper_c if numcig==0

* Current expenses (previous construction of food expenses)
gen alimexppera_c = alimExpensesa/GastoCte
replace alimexppera_c=. if alimexppera_c>1 
gen alimexpperFUMa_c=alimexppera_c if numcig>0
gen alimexpperNOFUMa_c=alimexppera_c if numcig==0


// 1.a. Alcohol 
* Total Expenses
gen alcexpper = alcoholExpenses/totalExpenses
replace alcexpper=. if alcexpper>1 
gen alcexpperFUM=alcexpper if numcig>0
gen alcexpperNOFUM=alcexpper if numcig==0

* Current expenses
gen alcexpper_c = alcoholExpenses/GastoCte
replace alcexpper_c=. if alcexpper_c>1 
gen alcexpperFUM_c=alcexpper_c if numcig>0
gen alcexpperNOFUM_c=alcexpper_c if numcig==0

// 2. Clothing and footwear BS 
* Total Expenses 
gen clothexpper = T2_expen_m2/totalExpenses
replace clothexpper=. if clothexpper>1

*Current Expenses
gen clothexpper_c = T2_expen_m2/GastoCte
replace clothexpper_c=. if clothexpper_c>1

// 3. Household services BS(Rent, home public services, domestic service) -Has no sense to do it with current expenditure-
* Total Expenses
gen houseexpper=T2_expen_m3/totalExpenses
replace houseexpper=. if houseexpper>1
gen houseexpperFUM=houseexpper if numcig>0
gen houseexpperNOFUM=houseexpper if numcig==0

* Current Expenses
gen houseexpper_c=T2_expen_m3/GastoCte
replace houseexpper_c=. if houseexpper_c>1
gen houseexpperFUM_c=houseexpper_c if numcig>0
gen houseexpperNOFUM_c=houseexpper_c if numcig==0

// 4. Furniture BS 
* Total Expenses
gen furnexpper = T2_expen_m4/totalExpenses
replace furnexpper=. if furnexpper>1

* Current Expenses
gen furnexpper_c=T2_expen_m4/GastoCte
replace furnexpper_c=. if furnexpper_c>1

// 5. Health Budget share -Has no sense to do it with current expenditure-
* Total Expenses
gen healthexpper=T2_expen_m5/totalExpenses
replace healthexpper=. if healthexpper>1 
gen healthexpperFUM=healthexpper if numcig>0
gen healthexpperNOFUM=healthexpper if numcig==0

* Current Expenses
gen healthexpper_c=T2_expen_m5/GastoCte
replace healthexpper_c=. if healthexpper_c>1 
gen healthexpperFUM_c=healthexpper_c if numcig>0
gen healthexpperNOFUM_c=healthexpper_c if numcig==0

// 6. Transport and Communication
* Total Expenses 
gen transexpper=T2_expen_m6/totalExpenses
replace transexpper=. if transexpper>1
gen transexpperFUM=transexpper if numcig>0
gen transexpperNOFUM=transexpper if numcig==0

* Current Expenses
gen transexpper_c=T2_expen_m6/GastoCte
replace transexpper_c=. if transexpper_c>1
gen transexpperFUM_c=transexpper_c if numcig>0
gen transexpperNOFUM_c=transexpper_c if numcig==0

// 7. Cultural Services BS
* Total Expenses 
gen cultexpper=T2_expen_m7/totalExpenses
replace cultexpper=. if cultexpper>1
gen cultexpperFUM=cultexpper if numcig>0
gen cultexpperNOFUM=cultexpper if numcig==0

* Current Expenses
gen cultexpper_c=T2_expen_m7/GastoCte
replace cultexpper_c=. if cultexpper_c>1
gen cultexpperFUM_c=cultexpper_c if numcig>0
gen cultexpperNOFUM_c=cultexpper_c if numcig==0

// 8. Education BS(Enrollment fee, uniforms, equipment, etc) -Has no sense to do it with current expenditure-
* Total Expenses
gen educexpper=T2_expen_m8/totalExpenses
replace educexpper=. if educexpper>1
gen educexpperFUM=educexpper if numcig>0
gen educexpperNOFUM=educexpper if numcig==0

* Current Expenses
gen educexpper_c=T2_expen_m8/GastoCte
replace educexpper_c=. if educexpper_c>1
gen educexpperFUM_c=educexpper_c if numcig>0
gen educexpperNOFUM_c=educexpper_c if numcig==0

// 9. Personal services and other payments BS(Household durables) 
* Total Expenses
gen persserexpper=T2_expen_m9/totalExpenses
replace persserexpper=. if persserexpper>1
gen persserexpperFUM=persserexpper if numcig>0
gen persserexpperNOFUM=persserexpper if numcig==0

* Current Expenses
gen persserexpper_c=T2_expen_m9/GastoCte
replace persserexpper_c=. if persserexpper_c>1
gen persserexpperFUM_c=persserexpper_c if numcig>0
gen persserexpperNOFUM_c=persserexpper_c if numcig==0


********************************************************************************
gen     educacion=1 if educ_uptoSec==0 & educ_tert==0
replace educacion=2 if educ_uptoSec==1
replace educacion=3 if educ_tert==1

replace numcig=numcig/numadu
replace numcig=5000 if numcig>5000 & numcig<30000

gen numcigFUM=numcig if numcig>0
gen tabexpperFUM=tabexpper if numcig>0
gen tabexpperFUM_c=tabexpper_c if numcig>0
gen anycig=numcig>0

la def female 1 "Female" 0 "Male"
la val female female

gen 	kids_adults=0
replace kids_adults=numnin/numadu if (numnin!=0 & numadu!=0)

egen 	total_indiv=rowtotal(numnin numadu)
*replace total_indiv=. if (numnin==. & numadu==.)

*gen 	kids_total=numnin/total_indiv if numnin!=.
gen 	adul_total=numadu/total_indiv if numadu!=.


la var female "Gender (Female==1)"
la var educ_uptoPrim "Educ. Level (Primary)"
la var educ_uptoSec "Educ. Level (Secondary)"
la var educ_tert "Educ. Level (Tertiary)"
la var kids_adults "Ratio Kids/Adults"

xtile quint=persgast if (T1_expen_m1!=. & T2_expen_m2!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m8!=. & T2_expen_m9!=.), n(5)
tab quint, g(qi_)

*table year quintile [pweight = fex] if numcig>0 , contents(mean persexpper) // 
*table year quintile [pweight = fex] , contents(mean persexpper) // 

foreach var in d1 d3 d2 d4 d5 d6 d7 d8{
replace `var'=. if `var'>4
}


if 1==0{
preserve	  
	collapse (mean) anycig numcigFUM tabexpperFUM  (semean) anycigSE=anycig numcigFUMSE=numcigFUM tabexpperFUMSE=tabexpperFUM , by(quint)
	foreach varDep in anycig numcigFUM tabexpperFUM {
		gen `varDep'lb=`varDep'-1.69*`varDep'SE
		gen `varDep'ub=`varDep'+1.69*`varDep'SE
	}
	order anycig* numcigFUM* tabexpperFUM* 
	sort quint
	drop if quint==.
	
	*reshape wide tabexpperFUM tabexpperFUMSE , i( quintile) j(year) // Para Excel
	replace anycig=anycig*100
	graph bar (mean) anycig, over(quint) bar(1, color(blue)) blabel(bar, format(%3.1f) si(medium))  name(a1, replace) title(Prevalence of Smoking) ytitle("% Smokers") 
	graph bar (mean) numcigFUM,over(quint) blabel(bar, format(%3.1f) si(medium)) name(a2, replace) title(N cigs | smoking)
restore
}
********************************************************************************
* DESCRIPTIVES
********************************************************************************				
if 1==0{
la def educ_uptoSec 0 "Below secondary" 1 "Up to secondary"
la val educ_uptoSec educ_uptoSec 


* Characterization of the All HH
preserve
keep if year==1997 | year==2011
bys year: count 

table year , contents(mean edad) // Age
table year if edadg>1, contents(mean female) // Gender
table year , contents(mean educ_uptoPrim) // Education
table year , contents(mean educ_uptoSec) // Education
table year , contents(mean educ_tert) // Education
forval i=1(1)5{
table year , contents(mean q_`i') // Quintiles
}
table year  if edadg>1, contents(mean zona)  // Zone
table year  , contents(mean kids_adults)  // Ratio Kids_Adults
table year  , contents(mean total_indiv)  // Individuos
table year  , contents(mean logincome)  // Individuos

restore

* Descriptives of All HH with expenses info available
preserve 
keep if year==1997 | year==2011
keep if (T1_expen_m1!=. & T2_expen_m2!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m8!=. & T2_expen_m9!=.)
bys year: count 

table year , contents(mean edad) // Age
table year  if edadg>1, contents(mean female) // Gender
table year , contents(mean educ_uptoPrim) // Education
table year , contents(mean educ_uptoSec) // Education
table year , contents(mean educ_tert) // Education
forval i=1(1)5{
table year , contents(mean q_`i') // Quintiles
}
table year  if edadg>1, contents(mean zona)  // Zone
table year  , contents(mean kids_adults)  // Ratio Kids_Adults
table year  , contents(mean total_indiv)  // Individuos
table year  , contents(mean logincome)  // Individuos

restore

* Descriptives of All HH with expenses info available (Smokers - Non Smokers)
preserve
keep if year==1997 | year==2011
keep if (T1_expen_m1!=. & T2_expen_m2!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m8!=. & T2_expen_m9!=.)
gen smokers= (numcig>0)
bys year: count if smokers==1
bys year: count if smokers==0
gen nonsmokers=1-smokers

** Smokers
table year  if smokers==1, contents(mean edad) // Age
table year  if edadg>1 & smokers==1, contents(mean female) // Gender
table year  if smokers==1, contents(mean educ_uptoPrim) // Education
table year  if smokers==1, contents(mean educ_uptoSec) // Education
table year  if smokers==1, contents(mean educ_tert) // Education
forval i=1(1)5{
table year  if smokers==1, contents(mean q_`i') // Quintiles
}
table year  if edadg>1 & smokers==1, contents(mean zona)  // Zone
table year  if smokers==1, contents(mean kids_adults)  // Ratio Kids_Adults
table year  if smokers==1, contents(mean total_indiv)  // Individuos
table year  if smokers==1, contents(mean logincome)  // Individuos

** Non-smokers
table year  if smokers==0, contents(mean edad) // Age
table year  if edadg>1 & smokers==0, contents(mean female) // Gender
table year  if smokers==0, contents(mean educ_uptoPrim) // Education
table year  if smokers==0, contents(mean educ_uptoSec) // Education
table year  if smokers==0, contents(mean educ_tert) // Education
forval i=1(1)5{
table year  if smokers==0, contents(mean q_`i') // Quintiles
}
table year  if edadg>1 & smokers==0, contents(mean zona)  // Zone
table year  if smokers==0, contents(mean kids_adults)  // Ratio Kids_Adults
table year  if smokers==0, contents(mean total_indiv)  // Individuos
table year  if smokers==0, contents(mean logincome)  // Individuos

foreach i of num 1997 2011{
foreach varDep in edad female educ_uptoPrim educ_uptoSec educ_tert q_1 q_2 q_3 q_4 q_5 zona kids_adults total_indiv logincome {
disp in red "Este es `varDep' en `i'"
reg `varDep' smokers if year==`i'
}
}
restore

preserve
keep if (T1_expen_m1!=. & T2_expen_m2!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m8!=. & T2_expen_m9!=.)
gen All=1 
tempfile All
save `All'

use "$mainF\ECVrepeat\derived\ECVrepeat_BASE.dta", clear
append using `All' 
replace All=0 if All==.

foreach i of num 1997 2011{
foreach varDep in edad female educ_uptoPrim educ_uptoSec educ_tert q_1 q_2 q_3 q_4 q_5 zona kids_adults total_indiv logincome {
disp in red "Este es `varDep' en `i'"
reg `varDep' All if year==`i'
}
}

save "$mainF\ECVrepeat\derived\ECVrepeat_BASEComparacion.dta", replace
restore


if 1==0{
* Characterization of the smokers
table year [pw = fex] if numcig>0, contents(mean edad ) // Age
table year [pw = fex] if (edadg>1 & numcig>0), contents(mean female) // Gender
table year [pw = fex] if (edadg>1 & numcig>0), contents(mean zona)  // Zone
table year [pw = fex] if numcig>0, contents(mean educ_uptoSec) // Education
table year [pw = fex] if numcig>0, contents(mean educ_uptoPrim) // Education
table year [pw = fex] if numcig>0, contents(mean educ_tert) 
table year [pw = fex] if numcig>0, contents(mean mala_salud) 

* Prevalence by characteristic
table edadg year [pw = fex], contents(mean anycig )  //Prevalence by age group 
table female year [pw = fex] if edadg>1, contents(mean anycig) 
table zona year [pw = fex] if edadg>1, contents(mean anycig) 
table educ_uptoSec year [pw = fex], contents(mean anycig) 
*table year educ_tert [pw = fex], contents(mean anycig) 



* Characterization by quintile (all sample)
table year quintile [pw = fex], contents(mean edad) 
table year quintile [pw = fex] if edadg>1, contents(mean female) 
table year quintile [pw = fex] if edadg>1, contents(mean zona)
table year quintile [pw = fex] if edadg>1, contents(mean educ_uptoSec)
*table year quintile [pw = fex] if edadg>1, contents(mean educ_tert)
table year quintile [pw = fex] if edadg>1, contents(mean mala_salud)

* Characterization by quintile (smokers)
table year quintile [pw = fex] if numcig>0, contents(mean edad) 
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean female) 
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean zona)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean educ_uptoSec)
table year quintile [pw = fex] if edadg>1 & numcig>0 & year==1997, contents(mean educ_tert)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean educ_tert)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean educ_uptoPrim)
table year quintile [pw = fex] if edadg>1 & numcig>0 & year==2011, contents(mean educ_uptoPrim)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean mala_salud)


* Prevalence by characteristic
table edadg quintile [pw = fex], contents(mean anycig)  //Prevalence by age group and quintile 
table female quintile [pw = fex], contents(mean anycig)  //Prevalence by gender and quintile 
table zona quintile [pw = fex], contents(mean anycig)  //Prevalence by zone and quintile 
table educ_uptoSec quintile [pw = fex], contents(mean anycig)  //Prevalence by terciary education and quintile 
*table educ_tert quintile [pw = fex], contents(mean anycig)  //Prevalence by terciary education and quintile 
table mala_salud quintile [pw = fex], contents(mean anycig)  //Prevalence by health status and quintile 


* Prevalence by characteristic and year
table edadg quintile [pw = fex] if year==1997, contents(mean anycig )  //Prevalence by age group and quintile - 1997 
table edadg quintile [pw = fex] if year==2011, contents(mean anycig )  //Prevalence by age group and quintile - 2011

table female quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by gender and quintile 
table female quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by gender and quintile 

table zona quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by zone and quintile 
table zona quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by zone and quintile 

table educ_uptoSec quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by terciary education and quintile 
table educ_uptoSec quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by terciary education and quintile 

table educ_tert quintile [pw = fex] if edadg>1 & numcig>0 & year==1997, contents(mean anycig)
table educ_tert quintile [pw = fex] if edadg>1 & numcig>0 & year==2011, contents(mean anycig)
table educ_uptoPrim quintile [pw = fex] if edadg>1 & numcig>0 & year==1997, contents(mean anycig)
table educ_uptoPrim quintile [pw = fex] if edadg>1 & numcig>0 & year==2011, contents(mean anycig)

table mala_salud quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by health status and quintile 
table mala_salud quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by health status and quintile 

forvalues i=1/9 {
*table year region_`i' [pweight = fex], contents(mean anycig )
table year quintile [pw = fex] if region_`i'==1, contents(mean anycig )
}
*

foreach i in 1 2 3 4 ///
{
table year [pweight = fex], contents(mean sr_health`i') 
table year [pweight = fex] if numcig>0, contents(mean sr_health`i') 
table year quintile [pweight = fex] if sr_health`i'==1, contents(mean anycig )
}
*

*Smokers and Non-Smokers
table quintile year [pw = fex] if anycig!=0, contents(mean edad ) // Age Smokers
table quintile year [pw = fex] if anycig==0, contents(mean edad ) // Age Non-Smokers

table quintile year [pw = fex] if (edadg1>1 & anycig!=0), contents(mean female) // Gender Smokers
table quintile year [pw = fex] if (edadg1>1 & anycig==0), contents(mean female) // Gender Non-Smokers

table quintile year [pw = fex] if (edadg1>1 & anycig!=0), contents(mean zona)  // Zone
table quintile year [pw = fex] if (edadg1>1 & anycig==0), contents(mean zona)  // Zone

table quintile year [pw = fex] if anycig!=0, contents(mean educ_uptoSec) // Education
table quintile year [pw = fex] if anycig==0, contents(mean educ_uptoSec) // Education

table quintile year [pw = fex] if anycig!=0, contents(mean educ_tert) // Education
table quintile year [pw = fex] if anycig==0, contents(mean educ_tert) // Education

*table year [pw = fex], contents(mean educ_tert) 
table year [pw = fex], contents(mean mala_salud) 
}


********************************************************************************	
label var numcigFUM "Cig. consumed"
*label var LnumcigFUM "Cig. consumed (precio bajo)"
*label var UnumcigFUM "Cig. consumed (precio alto)"
label var persgast "HH Consumption"
	
	loc i=1
	foreach y in 1997 2008 2011 {
		qui conindex numcigFUM if year==`y' [pw=fex], rankvar(persgast)  truezero graph
		loc CI   : disp %3.2f r(CI)
		loc CIse : disp %3.2f r(CIse)
		graph rename a`i', replace
		gr_edit .title.text.Arrpush "`y'"
		gr_edit .subtitle.text.Arrpush "CI: `CI' (`CIse')"
		loc i=1+`i'
	}
	graph combine a1 a2 a3, scheme(plotplain) cols(2) rows(2)
graph export "$mainE\document\images\Tobacco_CI.pdf", as(pdf) replace
graph export "$mainE\document\images\Tobacco_CI.png", as(png) replace
									
table year quintile [pweight = fex], contents(mean numcigFUM ) // Pero los que queda son los que mas fuman
						

}

cd "C:\Users\\`c(username)'\Google Drive\Tesis_Susana\Resultados"
********************************************************************************
* ESTRATEGIA METODOLÓGICA
********************************************************************************
keep if (T1_expen_m1!=. & T2_expen_m2!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m8!=. & T2_expen_m9!=.)
svyset id_hogar [pw=fex_calib], strata(AG)

glo controles "edad female i.educacion i.quint i.id_loc kids_adults total_indiv"
reg anycig d1 d2 d3 d4 d5 d6 d7 d8 [pw=fex_calib]
outreg2 using iniciales, replace tex(fragment) ctitle(Prevalence) label keep(d1 d2 d3 d4 d5 d6 d7 d8) addtext(Controls, No, Robust Errors, No, Clustered Errors, No)
reg tabexpper d1 d2 d3 d4 d5 d6 d7 d8  [pw=fex_calib]
outreg2 using iniciales, append tex(fragment) ctitle(Tobacco BS) label keep(d1 d2 d3 d4 d5 d6 d7 d8) addtext(Controls, No, Robust Errors, No, Clustered Errors, No)

reg anycig d1 d2 d3 d4 d5 d6 d7 d8  [pw=fex_calib], r
outreg2 using iniciales, append tex(fragment) ctitle(Prevalence) label keep(d1 d2 d3 d4 d5 d6 d7 d8) addtext(Controls, No, Robust Errors, Yes, Clustered Errors, No)
reg tabexpper d1 d2 d3 d4 d5 d6 d7 d8  [pw=fex_calib], r
outreg2 using iniciales, append tex(fragment) ctitle(Tobacco BS) label keep(d1 d2 d3 d4 d5 d6 d7 d8) addtext(Controls, No, Robust Errors, Yes, Clustered Errors, No)

reg anycig d1 d2 d3 d4 d5 d6 d7 d8 $controles [pw=fex_calib], r
outreg2 using iniciales, append tex(fragment) ctitle(Prevalence) label keep(d1 d2 d3 d4 d5 d6 d7 d8) addtext(Controls, Yes, Robust Errors, Yes, Clustered Errors, No)
reg tabexpper d1 d2 d3 d4 d5 d6 d7 d8 $controles [pw=fex_calib], r
outreg2 using iniciales, append tex(fragment) ctitle(Tobacco BS) label keep(d1 d2 d3 d4 d5 d6 d7 d8) addtext(Controls, Yes, Robust Errors, Yes, Clustered Errors, No)

reg anycig d1 d2 d3 d4 d5 d6 d7 d8 $controles [pw=fex_calib] , vce(cluster AG)
outreg2 using iniciales, append tex(fragment) ctitle(Prevalence) label keep(d1 d2 d3 d4 d5 d6 d7 d8) addtext(Controls, Yes, Robust Errors, No, Clustered Errors, Yes) 
reg tabexpper d1 d2 d3 d4 d5 d6 d7 d8 $controles [pw=fex_calib] , vce(cluster AG)
outreg2 using iniciales, append tex(fragment) ctitle(Tobacco BS) label keep(d1 d2 d3 d4 d5 d6 d7 d8) addtext(Controls, Yes, Robust Errors, No, Clustered Errors, Yes) 

forval j=1/8{
lpoly anycig d`j' , nosca ci name(prev_`j', replace)
}

tw (scatter y_dest x_dest)(scatter  y_dest x_dest if d6!=., color(red)) (scatter  y_dest x_dest if d7!=., color(orange))(scatter  y_dest x_dest if d8!=., color(yellow))
