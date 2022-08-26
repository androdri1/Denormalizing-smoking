* Author: Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2019.02.11
* Goal: Estimate the effect of the tobacco control policy over the prevalence du to physical exposure to tobacco use.

if "`c(username)'"=="paul.rodriguez" {
	glo mainE ="D:\Paul.Rodriguez\Dropbox\tabaco\tabacoDrive" //Paul
	*glo mainE ="C:\Users\paul.rodriguez\Dropbox\tabaco\tabacoDrive"
	glo thesis="$mainE\tesisSusana\Mapas\OutputData\Final"
	glo maps  ="$mainE\tesisSusana\Mapas\"
}
else {
	glo mainE="C:\Users\\`c(username)'\Dropbox\tabacoDrive\Tobacco-health-inequalities" // Susana
	glo thesis="C:\Users\\`c(username)'\Google Drive\Tesis_Susana\OutputData\Final"
	glo maps="C:\Users\\`c(username)'\Google Drive\Tesis_Susana\Mapas"
}

glo mainF="$mainE\data" // Susana

********************************************************************************
**# ORGANIZING DATABASE
********************************************************************************
if 1==0 {



	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_1.dta", clear
	cap drop _merge
	merge 1:1 year id_hogar using "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\income.dta", nogen
	merge 1:1 year id_hogar using "$maps\InputData\Finales\Hogares\Transport.dta", nogen

	la var numadu "Nro. adultos en el hogar"
	la var numnin "Nro. niños en el hogar"

	recode edad (16/25=1 "16 to 25") (26/35=2 "26 to 35") (36/45=3 "36 to 45") (46/55=4 "46 to 55") (56/64=5 "56 to 64") (65/150=6 "65+"), g(edadg)
	recode edad (10/19=1 "10 to 19") (20/29=2 "20 to 29") (30/39=3 "30 to 39") (40/49=4 "40 to 49") (50/59=5 "50 to 59") (60/150=6 "60+"), g(edadg1)
	replace edadg=. if edad<16
	replace edadg1=. if edad<10

	svyset id_hogar [pw=fex_calib], strata(AG)

	gen numcig=tabacoExpenses/cigprice if tabacoExpenses!=. & cigprice!=. & cigprice!=0

	gen tabexpper = tabacoExpenses/totalExpenses if totalExpenses!=. & totalExpenses!=0
	replace tabexpper=. if tabexpper>1 
	replace tabexpper=0 if tabacoExpenses==0 | tabacoExpenses==.

	gen tabac01 =0
	replace tabac01=1 if tabexpper>0

	gen lngast=ln(persgast)
	gen lningr=ln(persingr)

	la def id_loc 	1 "Usaquen" 2 "Chapinero" 3 "Santa Fe" 4 "San Cristobal" 5 "Usme" ///
					6 "Tunjuelito" 7 "Bosa" 8 "Kennedy" 9 "Fontibon" 10 "Engativa" ///
					11 "Suba" 12 "Barrios Unidos" 13 "Teusaquillo" 14 "Los Martires" ///
					15 "Antonio Narino" 16 "Puente Aranda" 17 "Candelaria" 18 "Rafael Uribe Uribe" ///
					19 "Ciudad Bolivar"
					
	la val id_loc id_loc
		
	recode id_loc (11 =1) (1 2 12 13 =2) (9 10 = 3) (3 14 16 17 = 4) (6 7 8 19 = 5) (4 5 15 18 = 6)  , gen(zonas)
	la def zonas  1 "north-west" 	/// //(Suba), 
			2 "north-east" 	/// //(Usaquen, Chapinero, Barrios Unidos, Teusaquillo) ,
			3 "central-west" 	/// //(Fontibon and Engativa), 
			4 "central-east" 	/// //(Santa Fe, Los Martires, Puente Aranda, Rafael Uribe), 
			5 "south-west" 	/// //(Bosa, Kennedy, Ciudad Bolivar and Tunjuelito), 
			6 "south-east"       //(San Cristobal, Antonio Nari\~no, Usme) . 
	la val zonas zonas
					
	recode UPZ 	(1=1 "20 de Julio")(2=2 "Alamos")(4=3 "Americas")(5=4 "Apogeo") ///
				(6=5 "Arborizadora")(7=6 "Bavaria")(8=7 "Bolivia")(9=8 "Bosa Central") ///
				(10=9 "Bosa Occidental")(11=10 "Boyaca Real")(12=11 "Britalia")(13=12 "Calandaima") ///
				(14=13 "Capellania")(15=14 "Carvajal")(16=15 "Casa Blanca Suba")(17=16 "Castilla") ///
				(18=17 "Chapinero")(19=18 "Chico Lago")(20=19 "Ciudad Jardin")(21=20 "Ciudad Montes") ///
				(22=21 "Ciudad Salitre Occidental")(23=22 "Ciudad Salitre Oriental")(26=23 "Corabastos")(27=24 "Country Club") ///
				(28=25 "Danubio")(29=26 "Diana Turbay")(30=27 "Doce de octubre")(31=28 "El porvenir") ///
				(32=29 "El Prado")(33=30 "El Refugio")(34=31 "El Rincon")(36=32 "Engativa") ///
				(37=33 "Fontibon")(38=34 "Fontibon San Pablo")(39=35 "Galerias")(40=36 "Garces Navas") ///
				(41=37 "Gran Britalia")(42=38 "Gran Yomasa")(43=39 "Granjas de Techo")(44=40 "Ismael Perdomo") ///
				(45=41 "Jerusalem")(46=42 "Kennedy Central")(47=43 "La Alhambra")(48=44 "La Candelaria") ///
				(49=45 "La Esmeralda")(51=46 "La Floresta")(52=47 "La Gloria")(53=48 "La Macarena") ///
				(54=49 "La Sabana")(55=50 "La Uribe")(56=51 "Las Cruces")(57=52 "Las Ferias") ///
				(58=53 "Las Margaritas")(59=54 "Las Nieves")(60=55 "Los Alcazares")(61=56 "Los Andes") ///
				(62=57 "Los Cedros")(63=58 "Los Libertadores")(64=59 "Lourdes")(65=60 "Lucero") ///
				(66=61 "Marco Fidel Suarez")(67=62 "Marruecos")(68=63 "Minuto de Dios")(69=64 "Modelia") ///
				(70=65 "Muzu")(71=66 "Niza")(72=67 "Pardo Rubio")(73=68 "Parque Salitre") ///
				(74=69 "CAN")(76=70 "Patio Bonito")(77=71 "Puente Aranda")(78=72 "Quinta Paredes") ///
				(79=73 "Quiroga")(80=74 "Restrepo")(81=75 "Sagrado Corazon")(82=76 "San Blas") ///
				(83=77 "San Cristobal Norte")(84=78 "San Francisco")(85=79 "San Isidro")(86=80 "San Jose") ///
				(87=81 "San Jose de Bavaria")(88=82 "San Rafael")(89=83 "Santa Barbara")(90=84 "Santa Cecilia") ///
				(91=85 "Santa Isabel")(92=86 "Sosiego")(93=87 "Suba")(94=88 "Teusaquillo") ///
				(95=89 "Tibabuyes")(96=90 "Timiza")(97=91 "Tintal Norte")(98=92 "Tintal Sur") ///
				(99=93 "Toberin")(100=94 "Tunjuelito")(101=95 "UPR Rio Tunjuelito")(102=96 "Usaquen") ///
				(103=97 "Venecia")(104=98 "Verbenal")(105=99 "Zona Franca")(106=100 "Zona Industrial"), g(upz1)

	if 1==0{
		preserve 
		glo maps "C:\Users\Usuario\Google Drive\Tesis_Susana\Mapas\InputData"
		keep if tabac01==0
		export delimited 	year id_loc fex_calib id_hogar tabac01  tabacoExpenses ///
							quintile AG x_* y_* cigprice numcig tabexpper ///
							using "$maps\BaseNoFumadores.csv", nolabel replace
		restore

		preserve 
		glo maps "C:\Users\Usuario\Google Drive\Tesis_Susana\Mapas\InputData"
		keep if tabac01==1
		export delimited 	year id_loc fex_calib id_hogar tabac01  tabacoExpenses ///
							quintile AG x_* y_* cigprice numcig tabexpper ///
							using "$maps\BaseFumadores.csv", nolabel replace
		restore
	}


	** Expenses Categories as a proportion of Total Expenses and Current Expenses **
	// 1. Food Budget share
	* Total Expenses
	gen alimexpper = alimExpenses/totalExpenses
	replace alimexpper=. if alimexpper>1 
	gen alimexpperFUM=alimexpper if numcig>0
	gen alimexpperNOFUM=alimexpper if numcig==0

	// 1.a. Alcohol 
	* Total Expenses
	gen alcexpper = alcoholExpenses/totalExpenses
	replace alcexpper=. if alcexpper>1 
	gen alcexpperFUM=alcexpper if numcig>0
	gen alcexpperNOFUM=alcexpper if numcig==0

	// 1.b. Alcohol+Tobacco 
	* Total Expenses
	replace T2_expen_m1=0 if T2_expen_m1==. 
	gen altobexpper = T2_expen_m1/totalExpenses
	replace altobexpper=. if altobexpper>1 
	gen altobexpperFUM=altobexpper if numcig>0 | alcoholExpenses>0
	gen altobexpperNOFUM=altobexpper if numcig==0

	// 2. Clothing and footwear BS 
	* Total Expenses 
	gen clothexpper = T2_expen_m2/totalExpenses
	replace clothexpper=. if clothexpper>1

	// 3. Household services BS(Rent, home public services, domestic service) -Has no sense to do it with current expenditure-
	* Total Expenses
	gen houseexpper=T2_expen_m3/totalExpenses
	replace houseexpper=. if houseexpper>1
	gen houseexpperFUM=houseexpper if numcig>0
	gen houseexpperNOFUM=houseexpper if numcig==0

	// 4. Furniture BS 
	* Total Expenses
	gen furnexpper = T2_expen_m4/totalExpenses
	replace furnexpper=. if furnexpper>1

	// 5. Health Budget share -Has no sense to do it with current expenditure-
	* Total Expenses
	gen healthexpper=T2_expen_m5/totalExpenses
	replace healthexpper=. if healthexpper>1 
	gen healthexpperFUM=healthexpper if numcig>0
	gen healthexpperNOFUM=healthexpper if numcig==0

	// 6. Transport and Communication
	* Total Expenses 
	gen transexpper=T2_expen_m6/totalExpenses
	replace transexpper=. if transexpper>1
	gen transexpperFUM=transexpper if numcig>0
	gen transexpperNOFUM=transexpper if numcig==0

	// 7. Cultural Services BS
	* Total Expenses 
	gen cultexpper=T2_expen_m7/totalExpenses
	replace cultexpper=. if cultexpper>1
	gen cultexpperFUM=cultexpper if numcig>0
	gen cultexpperNOFUM=cultexpper if numcig==0

	// 8. Education BS(Enrollment fee, uniforms, equipment, etc) -Has no sense to do it with current expenditure-
	* Total Expenses
	gen educexpper=T2_expen_m8/totalExpenses
	replace educexpper=. if educexpper>1
	gen educexpperFUM=educexpper if numcig>0
	gen educexpperNOFUM=educexpper if numcig==0

	// 9. Personal services and other payments BS(Household durables) 
	* Total Expenses
	gen persserexpper=T2_expen_m9/totalExpenses
	replace persserexpper=. if persserexpper>1
	gen persserexpperFUM=persserexpper if numcig>0
	gen persserexpperNOFUM=persserexpper if numcig==0


	gen		educacion=1 if educ_uptoSec==0 & educ_tert==0
	replace educacion=2 if educ_uptoSec==1
	replace educacion=3 if educ_tert==1

	replace numcig=numcig/numadu
	replace numcig=5000 if numcig>5000 & numcig<30000

	gen numcigFUM=numcig if numcig>0
	gen tabexpperFUM=tabexpper if numcig>0
	gen anycig=numcig>0

	gen 	anycig2=prevalence_30 if year==2011 
	replace anycig2=anycig if year==2007

	la var anycig2 "Prevalence (smokers)"
	la var anycig "Prevalence (HH has spent in tobacco products)"

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

	la def educ_uptoSec 0 "Below secondary" 1 "Up to secondary"
	la val educ_uptoSec educ_uptoSec 

	xtile quint=persgast if (T1_expen_m1!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m8!=. & T2_expen_m9!=.), n(5)
	tab quint, g(qi_)

	replace comm_density = 0 if comm_density ==.

	replace comm_density = comm_density + 0.00000001 if comm_density==0

	su inf_density2, d
	gen 	inf_d = .
	replace inf_d = (inf_density2>r(mean))
	su for_density2, d
	gen 	for_d = .
	replace for_d = (for_density2>r(mean))
	su comm_density, d
	gen 	sit_d = .
	replace sit_d = (comm_density>r(mean))

	tab quint_income, g(q_inc)

	su NEAR_DENS if densit==1 & year==2011, d
	sca meanDens = r(p25)
	// Reordering variables
	rename NEAR_DIST Dist // Kilometros
	rename I_time Post
	rename sit_d Densd // Densidad dicotomica (mayor a la media)
	rename NEAR_DENS Dens // Densidad 
	rename edad Age
	rename female Gender
	rename kids_adults KidsAdults
	rename total_indiv TotIndiv
	rename educ_uptoPrim Primary
	rename educ_uptoSec	Secondary
	rename educ_tert	Tertiary
	rename inf_d InformalDens // Dicotómica
	rename for_d FormalDens 
	rename inf_density2 InformalDensity
	rename for_density2 FormalDensity

	replace Dist=Dist*1000 // Distancia en metros
	su Dist if Dist>0


	gen 	invDist = 1/Dist

	su Dist if year==2007, d
	sca a2007 = 2.61
	replace Dist = a2007 if Dist>a2007 & year==2007

	su Dist if year==2011, d
	sca a2011 = 2.61
	replace Dist = a2011 if Dist>a2011 & year==2011

	gen _peso1=. 
	gen _matchscore1=.


	format Dist %8.7f
	*replace Dist=round(Dist, 0.001)

	// Distance descriptives .......................................................
	if 1==0{
		tw (lpoly anycig2 Dist if year==2007, k(gau))(lpoly anycig2 Dist if year==2011, k(gau)),  ///
		xline(2.61) legend(cols(1) pos(4) order (1 "2007" 2 "2011")) ytitle("Prevalence", size(vsmall)) xtitle("Distance (km)", size(vsmall)) name(distancePrevA, replace)
		
		kdensity Dist, k(epan2) bw(0.3) nor ///
			ytitle("", size(vsmall)) xtitle("Distance", size(vsmall)) ///
			legend(pos(6) off) note(" ") name(Kdensity_DistA, replace)

		tw (lpoly anycig2 Dist if year==2007 & Dist<a2007, k(gau))(lpoly anycig2 Dist if year==2011 & Dist<a2011, k(gau)),  ///
		xline(2.61) legend(cols(1) pos(4) order (1 "2007" 2 "2011")) ytitle("Prevalence", size(vsmall)) xtitle("Distance (km)", size(vsmall)) name(distancePrevB, replace)

		kdensity Dist, k(epan2) bw(0.3) nor ///
			ytitle("", size(vsmall)) xtitle("Distance", size(vsmall)) ///
			legend(pos(6) on r(1)) title(" ") note(" ") name(Kdensity_DistB, replace)

		graph combine distancePrevA distancePrevB, r(1) c(1) title("Smoking prevalence and distance to nearest commerce spot", size(vsmall)) ///
			note("Source: ECVB 2007, EMB2011 and Encuesta Nacional de Empresas (DANE). Author's calculations", size(tiny)) name(Prevalence_Distance, replace)
		graph display Prevalence_Distance, xsize(6) ysize(4.5) 
		graph export "$thesis\Images\Distance_Prevalence.pdf", as(pdf) replace 
		
		graph combine Kdensity_DistA Kdensity_DistB, r(2) c(1) title("Distance to nearest commerce spot distribution", size(vsmall)) ///
			note("Source: Encuesta Nacional de Empresas (DANE). Author's calculations", size(tiny)) name(Distance_distribution, replace)
		graph display Distance_distribution, xsize(5) ysize(5.5) 
		graph export "$thesis\Images\Distance_distribution.pdf", as(pdf) replace 

		graph close _all
	}
	// .............................................................................
	
	*hist Dist if Dist >0.05
		
	replace Dist = 1/Dist 

	*hist Dist if Dist<9000

	egen DistSD=std(Dist)
	egen DensSD=std(Dens)

	egen invDistSD=std(invDist)

	su DensSD if year==2007, d
	sca DensSDmean_07=r(mean)
	
	su DensSD if year==2011 , d
	sca DensSDmean_11=r(mean)
	
	gen DensSD_mean=(DensSD>DensSDmean_07) if DensSD!=. & year==2007
	replace DensSD_mean=(DensSD>DensSDmean_11) if DensSD!=. & year==2011
	
	*** 2022.08.10: En vez de usar la media de cada año, se usa un numero general, 334 metros
	su DistSD if year==2007 & Dist<10000, d
	sca DistSDmean_07=-1.0168633 //r(mean) -1.0168767
	disp r(mean)
	su DistSD if year==2011 & Dist<10000, d
	sca DistSDmean_11=-1.0168633 //r(mean) // -1.0168633
disp r(mean)


	
	gen DistSD_mean=(DistSD<DistSDmean_07) if DistSD!=. & year==2007      
	replace DistSD_mean=(DistSD<DistSDmean_11) if DistSD!=. & year==2011  

	
	*	gen DistSD_mean2 = Dist< (1/0.343)
	*	drop DistSD_mean
	*	rename DistSD_mean2 DistSD_mean
	
	*** 2022.08.10: De nuevo, vamos a usar un valor fijo, 1.69 tiendas x Km2
		*su Dens if year==2007, d 
		sca Densmean_07=1.69 //r(mean)
		*su Dens if year==2011 , d
		sca Densmean_11=1.69 //r(mean)
	
	gen Dens_mean=(Dens>Densmean_07) if Dens!=. & year==2007
	replace Dens_mean=(Dens>Densmean_11) if Dens!=. & year==2011
	
	su Dist if year==2007 & Dist<10000, d
	sca Distmean_07=r(mean)
	
	su Dist if year==2011 & Dist<10000, d
	sca Distmean_11=r(mean)

	gen Dist_mean=(Dist<Distmean_07) if Dist!=. & year==2007
	replace Dist_mean=(Dist<Distmean_11) if Dist!=. & year==2011
	
	su Dist if year==2007 & Dist<10000, d
	sca Distp25_07=r(p25)
	sca Distp75_07=r(p75)

	su Dist if year==2011 & Dist<10000, d
	sca Distp25_11=r(p25)
	sca Distp75_11=r(p75)
	
	gen Dist_p25=(Dist<Distp25_07) if Dist!=. & year==2007
	replace Dist_p25=(Dist<Distp25_11) if Dist!=. & year==2011

	gen Dist_p75=(Dist>Distp75_07) if Dist!=. & year==2007
	replace Dist_p75=(Dist>Distp75_11) if Dist!=. & year==2011
			
	save "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\Base_completa_20210726.dta", replace 
}

// Chosing controls
glo b_controls "Age Gender KidsAdults TotIndiv Primary Secondary Tertiary com_time com_dist q_inc1 q_inc2 q_inc3 q_inc4 q_inc5"
if 1==0{
		
		
		mat C = J(1,`: word count $b_controls ',.)
		mat colname C = $b_controls
		
		local i 0
		foreach v of global b_controls {
			local ++i
			ttest `v', by(Post)
			mat C[1,`i'] = r(p)
		}

		preserve

			clear
			
			svmat C, name(matcol)
			gen n=1
			reshape long C, i(n) j(var) string
			sort C
			keep in 1/5 //keep 5 lowest p-values
			reshape wide C, i(n) j(var) string
			rename C* *
			ds n, not //create a global of selected control variables
			global ctrl_var `r(varlist)'

		restore

		mat TT = J(`: word count $b_controls',6,.)
		mat rownames TT = $b_controls
		mat colnames TT = "Mean Treated" "SD Treated" "Mean Control" "SD Control" "Diff." "p-value"
		
		local i 0
		foreach control of global b_controls{
			local ++i
			ttest `control', by(Post)
			mat TT[`i',1] = round(r(mu_1),.001)
			mat TT[`i',2] = round(r(sd_1),.001)
			mat TT[`i',3] = round(r(mu_2),.001)
			mat TT[`i',4] = round(r(sd_2),.001)
			mat TT[`i',5] = round(r(mu_1)-r(mu_2),.001)
			mat TT[`i',6] = round(r(p),.001)
		}

		outtable using "$thesis\ttest_baseline", replace mat(TT) nobox center caption(Test de diferencia de medias) clabel(tab:ttest_base) f(%9.3f %9.3f %9.3f %9.3f %9.3f %05.3f)

}
*

cd "$thesis"

********************************************************************************
**# * DESCRIPTIVE STATISTICS PRE-MATCHING -- Sample_balance_wavesA
********************************************************************************
if 1==0 {


	
	
	// *************************************************************************
	
		
	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\Base_completa_20210726.dta", clear
	drop if Post==.

	glo b_controls Age Gender Primary Secondary Tertiary KidsAdults TotIndiv hm_age hm_female hm_educ_uptoPrim hm_educ_uptoSec hm_educ_tert  com_time com_dist q_inc1 q_inc2 q_inc3 q_inc4 q_inc5 
		
	tab Post, g(wave_)
	tab DistSD_mean , g(trait_) // DistSD_mean = 1 is Far ( bys DistSD_mean : sum Dist )
	tab DensSD_mean , g(dens_)  // DensSD_mean = 1 is High (  bys DensSD_mean : sum Dens  )

	bys Post: tab DistSD_mean DensSD_mean

	la var Age "Age"
	la var Gender "Gender"
	la var KidsAdults "Ratio Kids/Adults"
	la var TotIndiv "Total individuals"
	la var hm_age "Mean age of non-children"
	la var hm_female "Prop. female of non-children"
	la var hm_educ_uptoPrim "Prop. primary ed. of non-children"
	la var hm_educ_uptoSec "Prop. secondary ed. of non-children"
	la var hm_educ_tert "Prop. tertiary ed. of non-children"
	la var Primary "Primary"
	la var Secondary "Secondary"
	la var Tertiary "Tertiary" 
	la var com_time "Commuting time" 
	la var com_dist "Commuted distance (aprox.)"
	la var q_inc1 "Quintile 1" 
	la var q_inc2 "Quintile 2" 
	la var q_inc3 "Quintile 3" 
	la var q_inc4 "Quintile 4" 
	la var q_inc5 "Quintile 5" 
	la var Dist "Distance (nearest)"
	la var Dens "Commercial Density (nearest)"
	la var anycig2 "Prevalence"
	la var anycig "Prevalence (expenditure)"

	replace Dist = (1/Dist)*1000

	cap texdoc close
		texdoc init Sample_balance_wavesA, replace force
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{Descriptive Statistics by year and treatment assignment \label{tab:waves_sample_balance1}}
		tex \begin{tabular}{lcccccccc}			
		tex \toprule
		tex  		& \multicolumn{8}{c}{Mean}\\
		tex 		& \multicolumn{4}{c}{ 2007} 																				& \multicolumn{4}{c}{2011} \\
		tex 		& \multicolumn{2}{c}{Near} 						  &\multicolumn{2}{c}{Far}								& \multicolumn{2}{c}{Near}  						& \multicolumn{2}{c}{Far} \\ 
		tex Variable& \multicolumn{1}{c}{Low} & \multicolumn{1}{c}{High} & \multicolumn{1}{c}{Low} & \multicolumn{1}{c}{High} &  \multicolumn{1}{c}{Low} & \multicolumn{1}{c}{High} & \multicolumn{1}{c}{Low} & \multicolumn{1}{c}{High} \\  
		tex \midrule
	foreach varDep in $b_controls Dist Dens anycig2 anycig {
		qui{
			local labelo : variable label `varDep'		
		
			mean `varDep' if (wave_1==1 & DistSD_mean==0 & DensSD_mean==0)
			mat A=r(table)
			loc v0 : di %7.3f A[1,1]
			
			mean `varDep' if (wave_1==1 & DistSD_mean==0 & DensSD_mean==1)
			mat A=r(table)
			loc v1 : di %7.3f A[1,1]
			
			
			mean `varDep' if (wave_1==1 & DistSD_mean==1 & DensSD_mean==0)
			mat A=r(table)
			loc v2 : di %7.3f A[1,1]
			
			mean `varDep' if (wave_1==1 & DistSD_mean==1 & DensSD_mean==1)
			mat A=r(table)
			loc v3 : di %7.3f A[1,1]
			
			mean `varDep' if (wave_1==0 & DistSD_mean==0 & DensSD_mean==0)
			mat A=r(table)
			loc v4 : di %7.3f A[1,1]	
			
			mean `varDep' if (wave_1==0 & DistSD_mean==0 & DensSD_mean==1)
			mat A=r(table)
			loc v5 : di %7.3f A[1,1]	
			
			mean `varDep' if (wave_1==0 & DistSD_mean==1 & DensSD_mean==0)
			mat A=r(table)
			loc v6 : di %7.3f A[1,1]
			
			mean `varDep' if (wave_1==0 & DistSD_mean==1 & DensSD_mean==1)
			mat A=r(table)
			loc v7 : di %7.3f A[1,1]
			
			disp "2007 near, high: `v0' , 2007 near, low: `v1', 2007 far, high: `v2', 2007 far, low: `v3'"
			disp "2011 near, high: `v4' , 2011 near, low: `v5', 2011 far, high: `v6', 2011 far, low: `v7'"
			
	
				
			reg `varDep' wave_1 if DistSD_mean==0 & DensSD_mean==0
			loc dif0 : di %7.3f _b[wave_1]
			loc difse0 : di %7.3f _se[wave_1]			
			loc tbef0 = _b[wave_1]/_se[wave_1]
			loc pbef0 : di %7.3f 2*ttail(e(df_r),abs(`tbef0'))	
			di `pbef0'
			
			reg `varDep' wave_1 if DistSD_mean==0 & DensSD_mean==1
			loc dif1 : di %7.3f _b[wave_1]
			loc difse1 : di %7.3f _se[wave_1]			
			loc tbef1 = _b[wave_1]/_se[wave_1]
			loc pbef1 : di %7.3f 2*ttail(e(df_r),abs(`tbef1'))	
			di `pbef1'
			
			reg `varDep' wave_1 if DistSD_mean==1 & DensSD_mean==0
			loc dif2 : di %7.3f _b[wave_1]
			loc difse2 : di %7.3f _se[wave_1]			
			loc tbef2 = _b[wave_1]/_se[wave_1]
			loc pbef2 : di %7.3f 2*ttail(e(df_r),abs(`tbef2'))	
			di `pbef2'
			
			reg `varDep' wave_1 if DistSD_mean==1 & DensSD_mean==1
			loc dif3 : di %7.3f _b[wave_1]
			loc difse3 : di %7.3f _se[wave_1]			
			loc tbef3 = _b[wave_1]/_se[wave_1]
			loc pbef3 : di %7.3f 2*ttail(e(df_r),abs(`tbef3'))	
			di `pbef3'
												
			count if e(sample)==1 
			loc nreg=`r(N)'			
			count if wave_1==1 & `varDep'!=0
			loc n1=`r(N)'
			count if wave_1==0 & `varDep'!=0
			loc n0=`r(N)'
			
			local staru0 = ""
			if ((`pbef0' < 0.1) )  local staru0 = "*" 
			if ((`pbef0' < 0.05) ) local staru0 = "**" 
			if ((`pbef0' < 0.01) ) local staru0 = "***" 
			
			local staru1 = ""
			if ((`pbef1' < 0.1) )  local staru1 = "*" 
			if ((`pbef1' < 0.05) ) local staru1 = "**" 
			if ((`pbef1' < 0.01) ) local staru1 = "***" 
			
			local staru1 = ""
			if ((`pbef2' < 0.1) )  local staru1 = "*" 
			if ((`pbef2' < 0.05) ) local staru1 = "**" 
			if ((`pbef2' < 0.01) ) local staru1 = "***" 
			
			local staru1 = ""
			if ((`pbef3' < 0.1) )  local staru1 = "*" 
			if ((`pbef3' < 0.05) ) local staru1 = "**" 
			if ((`pbef3' < 0.01) ) local staru1 = "***" 
		}
				
		tex \parbox[l]{3.3cm}{`labelo'}  &  `v0' & `v1' & `v2' & `v3' & `v4'`staru0' & `v5'`staru1' & `v6'`staru2' & `v7'`staru3'\\
	}	
		
	
	// N observations .......................................................
	count if (wave_1==1 & DistSD_mean==0 & DensSD_mean==0)
	loc v0=r(N)
		
	count if (wave_1==1 & DistSD_mean==0 & DensSD_mean==1)
	loc v1=r(N)
		
	count if (wave_1==1 & DistSD_mean==1 & DensSD_mean==0)
	loc v2=r(N)
		
	count if (wave_1==1 & DistSD_mean==1 & DensSD_mean==1)
	loc v3=r(N)
		
	count if (wave_1==0 & DistSD_mean==0 & DensSD_mean==0)
	loc v4=r(N)	
		
	count if (wave_1==0 & DistSD_mean==0 & DensSD_mean==1)
	loc v5=r(N)		
		
	count if (wave_1==0 & DistSD_mean==1 & DensSD_mean==0)
	loc v6=r(N)
		
	count if (wave_1==0 & DistSD_mean==1 & DensSD_mean==1)
	loc v7=r(N)
		
	disp "2007 near, high: `v0' , 2007 near, low: `v1', 2007 far, high: `v2', 2007 far, low: `v3'"
	disp "2011 near, high: `v4' , 2011 near, low: `v5', 2011 far, high: `v6', 2011 far, low: `v7'"
	tex \parbox[l]{3.3cm}{Observations}  &  `v0' & `v1' & `v2' & `v3' & `v4' & `v5' & `v6' & `v7' \\
				
	
	tex \bottomrule
	tex \multicolumn{9}{l}{\parbox[l]{14cm}{\scriptsize \textbf{Source:} ECVB 2007, EMB2011 and DANE's Commercial Database}}\\
	tex \multicolumn{9}{l}{\parbox[l]{14cm}{\scriptsize\textbf{Notes:} Near and Far correspond to the extent in which a household is exposed to tobacco use, given their closeness to commercial activity. A household is classified as being Near, if the distance from the household block to the nearest commerce block is lower than the average distance, it is classified as being Far otherwise. Gender is a dummy variable, where female is one and male is zero. Commuting time is measured as a fraction of an hour, while commuted distance is expressed in kilometers. Distance represents the distance of a household to the nearest commerce spot in its surroundings, and it is measured in meters, while commerce density is measured as the number of commerce spots within a block by block's total area. A difference in means is conducted across time, and stars correspond to \sym{*} \(p<.1\), \sym{**} \(p<.05\), \sym{***} \(p<.01\)}}
	tex \end{tabular}
	tex \end{table}
	texdoc close	
	
}

********************************************************************************
* EMPIRICAL STRATEGY
********************************************************************************
**# /* MATCHING TECHNIQUE: Propensity Score -- Sample_balance_wavesB  */
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
if 1==0 {
	** Matching by grouping on Borough
	
	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\Base_completa_20210726.dta", clear
	drop if Post==.

	glo b_Match "Age Gender KidsAdults TotIndiv Primary Secondary Tertiary com_time com_dist q_inc1 q_inc2 q_inc3 q_inc4 q_inc5"
	glo b_controls Age Gender Primary Secondary Tertiary KidsAdults TotIndiv hm_age hm_female hm_educ_uptoPrim hm_educ_uptoSec hm_educ_tert  com_time com_dist q_inc1 q_inc2 q_inc3 q_inc4 q_inc5 
		
	// Proportion of the variation explained? Just 1%
	reg anycig2 $b_Match i.zonas i.DistSD_mean i.DensSD_mean , cluster(upz1)
		
	forval j=1(1)5{
	forval x=0(1)1{
	forval y=0(1)1{	
		disp "`j' `x' `y'"
		qui psmatch2 Post $b_Match Dist Dens if (zonas==`j' & DistSD_mean==`x' & DensSD_mean==`y'), com kernel  bw(0.01) 
		rename _weight peso_`j'`x'`y'
		rename _pscore pscore_`j'`x'`y'
		replace _peso1 =  peso_`j'`x'`y' if (zonas==`j' & DistSD_mean==`x' & DensSD_mean==`y')
		replace _matchscore1 =  pscore_`j' if (zonas==`j' & DistSD_mean==`x' & DensSD_mean==`y')
		cap drop peso_`j'`x'`y' pscore_`j'`x'`y'
		*graph close _all
	}
	}
	}
/*
	forval j=1(1)19{
	forval x=0(1)1{
		pstest $b_controls if zonas==`j' & DistSD_mean==`x', treated(Post) mweight(_peso1) rubin dist label
	}
	}
*/
	pstest $b_controls Dist Dens  if DistSD_mean==1, treated(Post) mweight(_peso1) rubin dist label
	pstest $b_controls Dist Dens  , treated(Post) mweight(_peso1) graph label
	graph export "$thesis\Matching_bias.pdf", as(pdf) replace

	
	save "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matchedv2.dta", replace

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matchedv2.dta", clear
	tab Post, g(wave_)
	tab DistSD_mean , g(trait_)
	tab DensSD_mean , g(dens_)


	la var Age "Age"
	la var Gender "Gender"
	la var KidsAdults "Ratio Kids/Adults"
	la var TotIndiv "Total individuals"
	la var Primary "Primary"
	la var Secondary "Secondary"
	la var Tertiary "Tertiary" 
	la var com_time "Commuting time" 
	la var com_dist "Commuted distance (aprox.)"
	la var q_inc1 "Quintile 1" 
	la var q_inc2 "Quintile 2" 
	la var q_inc3 "Quintile 3" 
	la var q_inc4 "Quintile 4" 
	la var q_inc5 "Quintile 5" 
	la var Dist "Distance (nearest)"
	la var Dens "Commercial Density (nearest)"
	la var anycig2 "Prevalence"

	pstest $b_controls Dist Dens anycig2 , treated(Post) mweight(_peso1) rubin dist label
	pstest $b_controls Dist Dens anycig2 , treated(Post) mweight(_peso1)  both hist label


	replace Dist = (1/Dist)*1000

	svyset id_hogar [pw=_peso1] 



	cap texdoc close
		texdoc init Sample_balance_wavesB, replace force
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{Sample Balance - Matching by City Area, distance to commercial areas, and commercial density \label{tab:waves_sample_balance2}}
		tex \begin{tabular}{lcccccccc}			
		tex \toprule
		tex  		& \multicolumn{8}{c}{Mean}\\
		tex 		& \multicolumn{4}{c}{ 2007} 																				& \multicolumn{4}{c}{2011} \\
		tex 		& \multicolumn{2}{c}{Near} 						  &\multicolumn{2}{c}{Far}								& \multicolumn{2}{c}{Near}  						& \multicolumn{2}{c}{Far} \\ 
		tex Variable& \multicolumn{1}{c}{High} & \multicolumn{1}{c}{Low} & \multicolumn{1}{c}{High} & \multicolumn{1}{c}{Low}  & \multicolumn{1}{c}{High} & \multicolumn{1}{c}{Low}& \multicolumn{1}{c}{High} & \multicolumn{1}{c}{Low} \\  
		tex \midrule
	foreach varDep in $b_controls Dist Dens anycig2{
			qui{
			local labelo : variable label `varDep'		
			
				svy: mean `varDep' if (wave_1==1 & DistSD_mean==0 & DensSD_mean==0)
				mat A=r(table)
				loc v0 : di %7.3f A[1,1]
				
				svy: mean `varDep' if (wave_1==1 & DistSD_mean==0 & DensSD_mean==1) 
				mat A=r(table)
				loc v1 : di %7.3f A[1,1]
				
				
				svy: mean `varDep' if (wave_1==1 & DistSD_mean==1 & DensSD_mean==0) 
				mat A=r(table)
				loc v2 : di %7.3f A[1,1]
				
				svy: mean `varDep' if (wave_1==1 & DistSD_mean==1 & DensSD_mean==1)
				mat A=r(table)
				loc v3 : di %7.3f A[1,1]
				
				svy: mean `varDep' if (wave_1==0 & DistSD_mean==0 & DensSD_mean==0)
				mat A=r(table)
				loc v4 : di %7.3f A[1,1]	
				
				svy: mean `varDep' if (wave_1==0 & DistSD_mean==0 & DensSD_mean==1)
				mat A=r(table)
				loc v5 : di %7.3f A[1,1]	
				
				svy: mean `varDep' if (wave_1==0 & DistSD_mean==1 & DensSD_mean==0)
				mat A=r(table)
				loc v6 : di %7.3f A[1,1]
				
				svy: mean `varDep' if (wave_1==0 & DistSD_mean==1 & DensSD_mean==1)
				mat A=r(table)
				loc v7 : di %7.3f A[1,1]
				
				disp "2007 near, high: `v0' , 2007 near, low: `v1', 2007 far, high: `v2', 2007 far, low: `v3'"
				disp "2011 near, high: `v4' , 2011 near, low: `v5', 2011 far, high: `v6', 2011 far, low: `v7'"
								
				svy: reg `varDep' wave_1 if  DistSD_mean==0 & DensSD_mean==0
				loc dif0 : di %7.3f _b[wave_1]
				loc difse0 : di %7.3f _se[wave_1]			
				loc tbef0 = _b[wave_1]/_se[wave_1]
				loc pbef0 : di %7.3f 2*ttail(e(df_r),abs(`tbef0'))	
				di `pbef0'
				
				svy: reg `varDep' wave_1 if  DistSD_mean==0 & DensSD_mean==1
				loc dif1 : di %7.3f _b[wave_1]
				loc difse1 : di %7.3f _se[wave_1]			
				loc tbef1 = _b[wave_1]/_se[wave_1]
				loc pbef1 : di %7.3f 2*ttail(e(df_r),abs(`tbef1'))	
				di `pbef1'
				
				svy: reg `varDep' wave_1 if DistSD_mean==1 & DensSD_mean==0
				loc dif2 : di %7.3f _b[wave_1]
				loc difse2 : di %7.3f _se[wave_1]			
				loc tbef2 = _b[wave_1]/_se[wave_1]
				loc pbef2 : di %7.3f 2*ttail(e(df_r),abs(`tbef2'))	
				di `pbef2'
				
				svy: reg `varDep' wave_1 if  DistSD_mean==1 & DensSD_mean==1
				loc dif3 : di %7.3f _b[wave_1]
				loc difse3 : di %7.3f _se[wave_1]			
				loc tbef3 = _b[wave_1]/_se[wave_1]
				loc pbef3 : di %7.3f 2*ttail(e(df_r),abs(`tbef3'))	
				di `pbef3'
													
				count if e(sample)==1 
				loc nreg=`r(N)'			
				count if wave_1==1 & `varDep'!=0
				loc n1=`r(N)'
				count if wave_1==0 & `varDep'!=0
				loc n0=`r(N)'
				
				local staru0 = ""
				if ((`pbef0' < 0.1) )  local staru0 = "*" 
				if ((`pbef0' < 0.05) ) local staru0 = "**" 
				if ((`pbef0' < 0.01) ) local staru0 = "***" 
				
				local staru1 = ""
				if ((`pbef1' < 0.1) )  local staru1 = "*" 
				if ((`pbef1' < 0.05) ) local staru1 = "**" 
				if ((`pbef1' < 0.01) ) local staru1 = "***" 
				
				local staru1 = ""
				if ((`pbef2' < 0.1) )  local staru1 = "*" 
				if ((`pbef2' < 0.05) ) local staru1 = "**" 
				if ((`pbef2' < 0.01) ) local staru1 = "***" 
				
				local staru1 = ""
				if ((`pbef3' < 0.1) )  local staru1 = "*" 
				if ((`pbef3' < 0.05) ) local staru1 = "**" 
				if ((`pbef3' < 0.01) ) local staru1 = "***" 
			}
				
			tex \parbox[l]{3.3cm}{`labelo'}  &  `v0' & `v1' & `v2' & `v3' & `v4'`staru0' & `v5'`staru1' & `v6'`staru2' & `v7'`staru3'\\
	}	
				
			
	// N observations .......................................................
	count if (wave_1==1 & DistSD_mean==0 & DensSD_mean==0) & _peso1!=.
	loc v0=r(N)
		
	count if (wave_1==1 & DistSD_mean==0 & DensSD_mean==1) & _peso1!=.
	loc v1=r(N)
		
	count if (wave_1==1 & DistSD_mean==1 & DensSD_mean==0) & _peso1!=.
	loc v2=r(N)
		
	count if (wave_1==1 & DistSD_mean==1 & DensSD_mean==1) & _peso1!=.
	loc v3=r(N)
		
	count if (wave_1==0 & DistSD_mean==0 & DensSD_mean==0) & _peso1!=.
	loc v4=r(N)	
		
	count if (wave_1==0 & DistSD_mean==0 & DensSD_mean==1) & _peso1!=.
	loc v5=r(N)		
		
	count if (wave_1==0 & DistSD_mean==1 & DensSD_mean==0) & _peso1!=.
	loc v6=r(N)
		
	count if (wave_1==0 & DistSD_mean==1 & DensSD_mean==1) & _peso1!=.
	loc v7=r(N)		
		
	disp "2007 near, high: `v0' , 2007 near, low: `v1', 2007 far, high: `v2', 2007 far, low: `v3'"
	disp "2011 near, high: `v4' , 2011 near, low: `v5', 2011 far, high: `v6', 2011 far, low: `v7'"
	tex \parbox[l]{3.3cm}{Observations}  &  `v0' & `v1' & `v2' & `v3' & `v4' & `v5' & `v6' & `v7' \\		
	
	tex \bottomrule
	tex \multicolumn{9}{l}{\parbox[l]{14cm}{\scriptsize \textbf{Source:} ECVB 2007, EMB2011 and DANE's Commercial Database}}\\
	tex \multicolumn{9}{l}{\parbox[l]{14cm}{\scriptsize\textbf{Notes:} Gender is a dummy variable, where female is one and male is zero. Commuting time is measured as a fraction of an hour, while commuted distance is expressed in kilometers. Distance represents the distance of a household to the nearest commerce spot in its surroundings, and it is measured in meters, while commerce density is measured as the number of commerce spots within a block by block's total area. }}
	tex \end{tabular}
	tex \end{table}
	texdoc close	
	
}	
		
	
	
// *************************************************************************
// 2022.08 Question on migration by a referee

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\data\raw\capc.dta" , clear
	rename DIRECTORIO_HOG id_hogar
	tempfile filo
	save `filo'

	
	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matchedv2.dta", clear 
	drop if year==2007
	merge 1:1 id_hogar using `filo'	
	
	destring C47 , replace
	gen mig3year = C47==1 | C47==2 if C47!=.
	tabulate DistSD_mean DensSD_mean, summarize(mig3year) // Más migración para los que viven cerca

	gen near=1-DistSD_mean
	
	label var near "NEAR"
	label var DensSD_mean "DENSE"
	label var mig3year "Living in the area 3 years or less"
	
	est drop _all
	reg mig3year near DensSD_mean      // Misma para los niveles de densidad		
	est store r1
	reg mig3year near DensSD_mean [iw=_peso1]     // Misma para los niveles de densidad	
	est store r2
	
	esttab r1 r2, se label tex
	
		
	
**# /* DIFFERENCE IN DIFFERENCES */
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*** DISCRETE VERSION
if 1==0{

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matchedv2.dta", clear 
	keep if _matchscore1!=.
	cap drop loc_* 
	glo X "Age Gender KidsAdults TotIndiv Primary Secondary incomeHH com_time com_dist"
	rename DistSD_mean DistM
	rename DensSD_mean DensM
	
	gen DistXPost = DistM*Post
	foreach x of global X{
		gen `x'XPost = `x'*Post
	}
	gen DistXDensXPost = DistXPost*DensM
	gen DensXPost = DensM*Post
	gen DensXDist = DensM*DistM
	
	rename anycig2 Prevalence
	
	glo XPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"
	glo X2 "hm_age hm_female hm_educ_uptoPrim hm_educ_uptoSec hm_educ_tert	c.hm_age#c.DistXPost c.hm_female#c.DistXPost c.hm_educ_uptoPrim#c.DistXPost c.hm_educ_uptoSec#c.DistXPost c.hm_educ_tert#c.DistXPost incomeHH com_time com_dist"
	
	
		** Regressions - Discrete version 
*------------------------------------------------------------------------------*		
		*** First specification
		/*Prevalence*/
		
		reg Prevalence DistM Post DistXPost, r
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo b1a_p		

		*eststo b1_p: reg Prevalence DistM Post DistXPost [iw=_peso1], r
		*eststo b2_p: reg Prevalence DistM Post DistXPost [iw=_peso1], vce(cluster upz1)
		reg Prevalence DistM Post DistXPost $X i.upz1 [iw=_peso1], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo b3_p
		
		reg Prevalence DistM Post DistXPost $XPost i.upz1 [iw=_peso1], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo b4_p
		
		reg Prevalence DistM Post DistXPost $X $XPost i.upz1 [iw=_peso1], vce(cluster upz1) 
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo b5_p
		*eststo b6_p: reg Prevalence DistM Post DistXPost $X $XPost i.upz1, vce(cluster upz1)
		
	
		esttab b1a_p b3_p b4_p b5_p, se keep(DistXPost DistM Post) ///
				stats(Prev_mean Prev_sd N ag N_clust) ///
				star(* .1 ** .05 *** .01) title(Difference in Differences Results - Distance)  tex
				
	
*------------------------------------------------------------------------------*
		*** Second specification
		/*Prevalence*/
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost , r
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]		
		eststo a1a_p
		
		*eststo a1_p: reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost [iw=_peso1], r
		*eststo a2_p: reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost [iw=_peso1], vce(cluster upz1)
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X i.upz1 [iw=_peso1], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]		
		eststo a3_p
		
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $XPost i.upz1 [iw=_peso1], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]		
		eststo a4_p
		
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X $XPost i.upz1 [iw=_peso1], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo a5_p
		
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X2 i.upz1 [iw=_peso1], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo a6_p
		
		
		*eststo a6_p: reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X $XPost i.upz1, vce(cluster upz1)

		
		esttab a1a_p a3_p a4_p a5_p a6_p, se r2 keep(DistXDensXPost DistM Post DensM DensXDist DistXPost DensXPost) ///
				stats(Prev_mean Prev_sd N ag N_clust) ///
				star(* .1 ** .05 *** .01) title(Difference in Differences Results - Density)  tex nogaps
				
				
					
}

	
********************************************************************************
* HETEROGENEOUS EFFECTS
********************************************************************************
if 1==1 { // socio-demographic characteristics -  het_results.tex  --
/* Difference in differences - Age of HH head  */

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matched.dta", clear 
	keep if _matchscore1!=.
	cap drop loc_* 
	glo X "Age Gender KidsAdults TotIndiv Primary Secondary incomeHH com_time com_dist"
	rename DistSD_mean DistM
	rename DensSD_mean DensM
	
	gen DistXPost = DistM*Post
	foreach x of global X{
		gen `x'XPost = `x'*Post
	}
	gen DistXDensXPost = DistXPost*DensM
	gen DensXPost = DensM*Post
	gen DensXDist = DensM*DistM
	
	rename anycig2 Prevalence
	recode Age (16/49 = 1 "16 to 49")(50/105 = 0 "50+"), g(Young)
	gen Old = 1-Young
	
	glo XPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"

	/*Prevalence*/
		
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X $XPost i.upz1 [iw=_peso1] if Young==1, vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo d5_p

		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X $XPost i.upz1 [iw=_peso1] if Young==0, vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo e5_p
		
		* Joint regression which allows for the test
		reg Prevalence c.DistM#i.Young c.Post#i.Young c.DensM#i.Young c.DistXDensXPost#i.Young c.DensXDist#i.Young c.DistXPost#i.Young c.DensXPost#i.Young c.Age#i.Young c.Gender#i.Young c.KidsAdults#i.Young c.TotIndiv#i.Young c.Primary#i.Young c.Secondary#i.Young c.incomeHH#i.Young c.com_time#i.Young c.com_dist#i.Young c.AgeXPost#i.Young c.GenderXPost#i.Young c.KidsAdultsXPost#i.Young c.TotIndivXPost#i.Young c.PrimaryXPost#i.Young c.SecondaryXPost#i.Young i.upz1#i.Young [iw=_peso1] , vce(cluster upz1)
		test 0b.Young#c.DistXDensXPost 1.Young#c.DistXDensXPost

	/* Difference in differences - Number of Kids  */	

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matched.dta", clear 
	keep if _matchscore1!=.
	cap drop loc_* 
	glo X "Age Gender KidsAdults TotIndiv Primary Secondary incomeHH com_time com_dist"
	rename DistSD_mean DistM
	rename DensSD_mean DensM

	gen DistXPost = DistM*Post
	foreach x of global X{
		gen `x'XPost = `x'*Post
	}
	gen DistXDensXPost = DistXPost*DensM
	gen DensXPost = DensM*Post
	gen DensXDist = DensM*DistM
	
	rename anycig2 Prevalence
	gen Kids = (numnin>0)
	gen Kids2 = (numnin>1)
	
	
	glo XPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"

	/*Prevalence*/
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X $XPost i.upz1 [iw=_peso1] if Kids==0, vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo f5_p

		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X $XPost i.upz1 [iw=_peso1] if Kids==1, vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo g5_p

		* Joint regression which allows for the test
		reg Prevalence c.DistM#i.Kids c.Post#i.Kids c.DensM#i.Kids c.DistXDensXPost#i.Kids c.DensXDist#i.Kids c.DistXPost#i.Kids c.DensXPost#i.Kids c.Age#i.Kids c.Gender#i.Kids c.KidsAdults#i.Kids c.TotIndiv#i.Kids c.Primary#i.Kids c.Secondary#i.Kids c.incomeHH#i.Kids c.com_time#i.Kids c.com_dist#i.Kids c.AgeXPost#i.Kids c.GenderXPost#i.Kids c.KidsAdultsXPost#i.Kids c.TotIndivXPost#i.Kids c.PrimaryXPost#i.Kids c.SecondaryXPost#i.Kids i.upz1#i.Kids [iw=_peso1] , vce(cluster upz1)
		test 0b.Kids#c.DistXDensXPost 1.Kids#c.DistXDensXPost		
		
		
	/* Difference in differences - Occupation */

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matched.dta", clear 
	keep if _matchscore1!=.
	cap drop loc_* 
	glo X "Age Gender KidsAdults TotIndiv Primary Secondary incomeHH com_time com_dist"
	rename DistSD_mean DistM
	rename DensSD_mean DensM

	gen DistXPost = DistM*Post
	foreach x of global X{
		gen `x'XPost = `x'*Post
	}
	gen DistXDensXPost = DistXPost*DensM
	gen DensXPost = DensM*Post
	gen DensXDist = DensM*DistM
	
	rename anycig2 Prevalence
	gen white_collar = ((educacion>2 & (ocupacion!=3 | ocupacion!=6 | ocupacion!=7)) | (educacion>1 & (ocupacion!=1 | ocupacion!=3 | ocupacion!=6 | ocupacion!=7)))	
	rename white_collar  White
	

	glo XPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"

	/*Prevalence*/
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X $XPost i.upz1 [iw=_peso1] if White==0, vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo h5_p
		
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X $XPost i.upz1 [iw=_peso1] if White==1, vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		*di in red Prev_mean Prev_sd
		cap drop counter
		bys AG: gen counter = 1 if _n == 1 & e(sample)==1
		replace counter = sum(counter)
		display "Number of distinct values of AG is: " =counter[_N]
		estadd sca ag = counter[_N]
		eststo i5_p

		* Joint regression which allows for the test
		reg Prevalence c.DistM#i.White c.Post#i.White c.DensM#i.White c.DistXDensXPost#i.White c.DensXDist#i.White c.DistXPost#i.White c.DensXPost#i.White c.Age#i.White c.Gender#i.White c.KidsAdults#i.White c.TotIndiv#i.White c.Primary#i.White c.Secondary#i.White c.incomeHH#i.White c.com_time#i.White c.com_dist#i.White c.AgeXPost#i.White c.GenderXPost#i.White c.KidsAdultsXPost#i.White c.TotIndivXPost#i.White c.PrimaryXPost#i.White c.SecondaryXPost#i.White i.upz1#i.White [iw=_peso1] , vce(cluster upz1)
		test 0b.White#c.DistXDensXPost 1.White#c.DistXDensXPost

	esttab d5_p e5_p f5_p g5_p h5_p i5_p , se r2 keep(DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost) ///
				stats(Prev_mean Prev_sd N ag N_clust) ///
				star(* .1 ** .05 *** .01) title(Difference in Differences Results - Heterogeneous)  tex nogaps
	

}
xxx

********************************************************************************
* ROBUSTNESS CHECKS -- rob_blockpanel.tex --- (not in the main text)
********************************************************************************
if 1==0 {
/* Panel of Blocks  */

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\Base_completa_20210726.dta", replace
	label var Dist "Inverse of distance in Km"
	
	keep if Post!=.
	cap drop loc_* Dist Dens
	glo X "Age Gender KidsAdults TotIndiv Primary Secondary incomeHH com_time com_dist"
	rename DistSD Dist
	rename DensSD Dens
	rename DistSD_mean DistM
	rename DensSD_mean DensM
	
	collapse (mean) anycig2 DistM DensM Age Gender KidsAdults TotIndiv Primary Secondary incomeHH com_time com_dist ///
			 (max) upz1 , by(AG Post)
	duplicates tag AG, g(dups)
	drop if dups==0
	
	gen DistXPost = DistM*Post
	foreach x of global X{
		gen `x'XPost = `x'*Post
	}
	gen DistXDensXPost = DistXPost*DensM
	gen DensXPost = DensM*Post
	gen DensXDist = DensM*DistM
	
	rename anycig2 Prevalence
	
	glo XPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"
	
	merge n:1 AG using "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_4_Matched.dta"
	drop if _merge==2
	
		** Regressions - Discrete version 
*------------------------------------------------------------------------------*		
		*** First specification
		/*Prevalence*/
		reg Prevalence DistM Post DistXPost, r
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		di in red Prev_mean Prev_sd
		eststo b1a_p

		reg Prevalence DistM Post DistXPost $X i.upz1 [iw=weight_match], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		di in red Prev_mean Prev_sd
		eststo b3_p

		reg Prevalence DistM Post DistXPost $XPost i.upz1 [iw=weight_match], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		di in red Prev_mean Prev_sd
		eststo b4_p

		reg Prevalence DistM Post DistXPost $X $XPost i.upz1 [iw=weight_match], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		di in red Prev_mean Prev_sd
		eststo b5_p
	
	
*------------------------------------------------------------------------------*
		*** Second specification
		/*Prevalence*/
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost , r
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)		
		eststo a1a_p
		
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X i.upz1 [iw=weight_match], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)		
		eststo a3_p
		
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $XPost i.upz1 [iw=weight_match], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)		
		eststo a4_p
		
		reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X $XPost i.upz1 [iw=weight_match], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)		
		eststo a5_p

		tabstat Prevalence DistXPost DistXDensXPost, statistics( mean sd )

		/*
		   stats |  Preval~e  DistXP~t  DistXD~t
		---------+------------------------------
			mean |  .4623305  .1401395  .0079717
			  sd |  .4985865   .347137  .0889293
		----------------------------------------

		*/
		
		esttab b5_p a5_p, se r2 keep(DistM Post DistXPost DistXDensXPost) ///
						stats(Prev_mean Prev_sd N N_clust) ///
				star(* .1 ** .05 *** .01) title(Difference in Differences Results - Distance) tex
				

/* 25th vs 75th percentile of distance distribution */

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\Base_completa_20210726.dta", replace
	keep if Post!=.
	keep if Dist_p25==1 | Dist_p75==1 
	gen 	Dist_p = .
	replace Dist_p = 1 if Dist_p25==1 & Dist_p==.
	replace Dist_p = 0 if Dist_p75==1 & Dist_p==.
	drop if Dist_p==.
	
	cap drop loc_* Dist Dens
	glo X "Age Gender KidsAdults TotIndiv Primary Secondary incomeHH com_time com_dist"
	rename DistSD Dist
	rename DensSD Dens
	rename DensSD_mean DensM

	
	gen DistXPost = Dist_p*Post
	foreach x of global X{
		gen `x'XPost = `x'*Post
	}
	
	rename anycig2 Prevalence
	
	glo XPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"
	
	merge n:1 AG using "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_4_Matched.dta"
	drop if _merge==2
	
		** Regressions - Discrete version 
	*------------------------------------------------------------------------------*		
		*** First specification
		/*Prevalence*/	
		eststo c5_p: reg Prevalence Dist_p Post DistXPost $X $XPost i.upz1 [iw=weight_match], vce(cluster upz1)
		su Prevalence if e(sample)==1 
		estadd sca Prev_mean 	= r(mean)
		estadd sca Prev_sd 	= r(sd)
		di in red Prev_mean Prev_sd
		
		
* ~~~~~~~~~~~~~~~~~~~~~~~		
		
esttab b5_p a5_p c5_p, se r2 keep(DistM Post DistXPost DistXDensXPost Dist_p)  ///
						stats(Prev_mean Prev_sd N N_clust) ///
			star(* .1 ** .05 *** .01) title(Difference in Differences Results - Robustness) tex	nogap	
}

	

********************************************************************************
* SENSITIVITY ANALYSIS
********************************************************************************	


/* Difference in differences - Placebo tests DENSITY and DISTANCE */
if 1==1{
	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matched.dta", clear 
	rename anycig2 Prevalence
	glo X "Age Gender KidsAdults TotIndiv Primary Secondary incomeHH com_time com_dist"
	foreach x of global X{
		gen `x'XPost = `x'*Post
	}


	cap mat drop bigResults
	loc i=1
	forval i=1(1)500 {
		qui {			
		cap drop DensP_`i' DistP_`i'
		gen DensP_`i'=runiform(0, 5)
		gen DistP_`i'=runiform(0, 800)
		
		qui replace DistP_`i'=1/DistP_`i'
		
		gen DistPXPost_`i' = DistP_`i'*Post
		gen DistPXDensPXPost_`i' = DistPXPost_`i'*DensP_`i'
		gen DensPXPost_`i' = DensP_`i'*Post
		gen DensPXDistP_`i' = DensP_`i'*DistP_`i'
		
		reg Prevalence DistP_`i' Post DistPXPost_`i' $X $XPost i.upz1 [iw=_peso1], vce(cluster upz1)
		loc bDistPXPost_`i' :  di %7.4f _b[DistPXPost_`i']
		loc seDistPXPost_`i' : di %7.4f _se[DistPXPost_`i']
		
				
		reg Prevalence DistP_`i' DensP_`i' Post DistPXPost_`i' DensPXPost_`i' DensPXDistP_`i' DistPXDensPXPost_`i' $X $XPost i.upz1 [iw=_peso1], vce(cluster upz1)
		loc bDistPXDensPXPost_`i' :  di %7.4f _b[DistPXDensPXPost_`i']
		loc seDistPXDensPXPost_`i' : di %7.4f _se[DistPXDensPXPost_`i']
	
		mat resu = [`bDistPXDensPXPost_`i'',`seDistPXDensPXPost_`i'']
		mat bigResults =nullmat(bigResults) \ resu
		}
		loc i=`i'+1
	}	

	mat colname bigResults = beta se
	mat list bigResults
	svmat bigResults, names(col)
	
	keep if beta!=.
		
	hist beta, xline(-0.0962, lp(solid) lc(cranberry)) width(0.01) xscale(range(-0.2 0.2)) xtitle("Estimation of Theta") /// // title("Placebo Test") 
	xlabel(-0.19 "-0.19" -0.17 "0.17" -0.15 "-0.15" -0.13 "-0.13" -0.11 "-0.11" -0.09 "-0.09" -0.07 "-0.07" -0.05 "-0.05" -0.03 "-0.03" -0.01 "-0.01" 0 "0" 0.01 "0.01" 0.03 "0.03" 0.05 "0.05" 0.07 "0.07" 0.09 "0.09" 0.11 "0.11" 0.13 "0.13" 0.15 "0.15" 0.17 "0.17" 0.19 "0.19")
	*note("Note: Both distance and density are randomly set as dummies. Distance takes values from a uniform distribution, between" " 0 and 800 meters. It also draws artificial density values from a uniform distribution between zero and five. This procedure " " is executed a hundred times." "Source: Author's calculations.", size(vsmall))
	graph export "$thesis\Images\PlaceboDistDens1.pdf", as(pdf) replace 

}

	
/* Sensitivity analysis of Density*/
		
if 1==1{	
		
	glo mino=-3
		
	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matched.dta", clear 
	drop if Post==.
	rename anycig2 Prevalence
		
	rename DistSD_mean DistM
	gen DistXPost = DistM*Post

	glo b_controls "Age Gender KidsAdults TotIndiv Primary Secondary Tertiary com_time com_dist q_inc1 q_inc2 q_inc3 q_inc4 q_inc5"
	


	glo Z "Age Gender KidsAdults TotIndiv Primary Secondary incomeHH com_time com_dist"

	foreach z of global Z{
		gen `z'XPost = `z'*Post
	}

	glo ZPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"
	
	
	cap mat drop bigResults
	forval j=$mino(1)3 {
	
		*loc j=-3 // Test		
		
		su DensSD if year==2007, d
		loc DensSDmean_07=r(mean)
		
		su DensSD if year==2011 , d
		loc DensSDmean_11=r(mean)		
	
		loc x=`j'/10
	
		if `x'>0{
			loc name = `j'*10000
		}
		
		if `x'<=0{
			loc name = `j'*(-100)
		}
		
		gen DensSD_mean`name'=(DensSD>`DensSDmean_07'+(`x')) if DensSD!=. & year==2007
		replace DensSD_mean`name'=(DensSD>`DensSDmean_11'+(`x')) if DensSD!=. & year==2011
		rename DensSD_mean`name' DensM`name'
	
		* Matching step .............................................................

		gen _peso1`name'=. 
		gen _matchscore1`name'=.		
		
		forval j=1(1)5{
		forval x=0(1)1{
		forval y=0(1)1{	
			disp "`j' `x' `y'"
			qui{
				psmatch2 Post $b_controls Dist Dens if (zonas==`j' & DistM==`x' & DensM`name'==`y'), com kernel  bw(0.01) 
				rename _weight peso_`j'`x'`y'
				rename _pscore pscore_`j'`x'`y'
				replace _peso1`name' =  peso_`j'`x'`y' if (zonas==`j' & DistM==`x' & DensM`name'==`y')
				replace _matchscore1 =  pscore_`j' if (zonas==`j' & DistM==`x' & DensM`name'==`y')
				cap drop peso_`j'`x'`y' pscore_`j'`x'`y'
			}
		}
		}
		}	

		* DiD step .................................................................
		
		gen DistXDensXPost`name' = DistXPost*DensM`name'
		gen DensXPost`name' = DensM`name'*Post
		gen DensXDist`name' = DensM`name'*DistM
		
		
		eststo a_`name': reg Prevalence DistM Post DensM`name' DistXDensXPost`name' DensXDist`name' DistXPost DensXPost`name' $Z $ZPost i.upz1 [iw=_peso1`name'], vce(cluster upz1)
		loc bDistXDensXPost_`name'  = _b[DistXDensXPost`name']
		loc seDistXDensPost_`name' = _se[DistXDensXPost`name']
		
		mat resu = [`bDistXDensXPost_`name'',`seDistXDensPost_`name'']
		mat bigResults =nullmat(bigResults) \ resu
	}
	
	mat colname bigResults = Beta SE
	mat list bigResults
	
	svmat bigResults, names(col)
	keep if Beta!=. 
	keep Beta SE
	gen 	id=$mino+_n	
	replace id= id/10

	gen seUp_DistXDensXPost = Beta + 1.69*SE
	gen seLow_DistXDensXPost = Beta - 1.69*SE
	lab var seUp_DistXDensXPost "Upper CI"
	lab var seLow_DistXDensXPost "Lower CI"

	lab var Beta "DistXDensXPost"	
	
	tw (rcap seUp_DistXDensXPost seLow_DistXDensXPost id)(scatter Beta id),  ///
	xtitle("Variation in Density definition") ytitle("Estimate of Theta") /// // title(Sensitivity Analysis of Density)
	legend() yline(0, lp(dash)) yline(-0.108, lp(solid)) // note("Note: Density is defined using the average density as before plus an arbitrary value between -1" " and 1, with breaks of 0.1. For graphical representation, we normalize the cutoff to zero when using" "the average density." "Source: Author's calculations.", size(vsmall))
	graph export "$thesis\Images\SensDistanceDens.pdf", as(pdf) replace
	
	graph close _all
	
	save "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\sensitivity_results.dta", replace

}
*
	
	
	
	
/* Data for 1's and 0's map */
if 1==0{
	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matched.dta", clear
	keep year id_hogar AG OBJECTID SETR_CLSE_ SECR_SETR_ SECU_SETU_ ///
	SECU_SECU_ anycig2 DistSD_mean  ///
	DensSD_mean
	
	rename AG MANZ_CAG
	
	collapse 	(mean) DistSD_mean DensSD_mean anycig2 ///
				(first) OBJECTID SETR_CLSE_ SECR_SETR_ SECU_SETU_ SECU_SECU_ ///
				(count) id_hogar , by(MANZ_CAG year) 

	
	
	export delimited year id_hogar MANZ_CAG OBJECTID SETR_CLSE_ SECR_SETR_ SECU_SETU_ ///
					SECU_SECU_ anycig2 DistSD_mean DensSD_mean using "$maps\InputData\Finales\BaseCompleta1_0.csv", nolabel replace
}
