* Author: Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2019.02.11
* Goal: Use anycig instead of anycig2 for the matching and the main results

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
* EMPIRICAL STRATEGY
********************************************************************************

**# /* MATCHING TECHNIQUE: Propensity Score -- Sample_balance_wavesB  */
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
if 1==0 {
	** Matching by grouping on Borough
	
	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\Base_completa_20210726.dta", clear
	drop if Post==.

	glo b_controls "Age Gender KidsAdults TotIndiv Primary Secondary Tertiary com_time com_dist q_inc1 q_inc2 q_inc3 q_inc4 q_inc5"
		
	forval j=1(1)5{
	forval x=0(1)1{
	forval y=0(1)1{	
		disp "`j' `x' `y'"
		qui psmatch2 Post $b_controls Dist Dens if (zonas==`j' & DistSD_mean==`x' & DensSD_mean==`y'), com kernel  bw(0.01) 
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

	
	save "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matched_allExp.dta", replace

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matched_allExp.dta", clear
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
	la var anycig "Prevalence"

	pstest $b_controls Dist Dens anycig , treated(Post) mweight(_peso1) rubin dist label
	pstest $b_controls Dist Dens anycig , treated(Post) mweight(_peso1)  both hist label


	replace Dist = (1/Dist)*1000

	svyset id_hogar [pw=_peso1] 



	cap texdoc close
		texdoc init Sample_balance_wavesB_allExp, replace force
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
	foreach varDep in $b_controls Dist Dens anycig{
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
		
	
**# /* DIFFERENCE IN DIFFERENCES */
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*** DISCRETE VERSION
if 1==0{

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matched_allExp.dta", clear 
	keep if _matchscore1!=.
	cap drop loc_* 
	glo X "Age Gender KidsAdults TotIndiv Primary Secondary incomeHH com_time com_dist"
	rename DistSD_mean DistM
	rename DensSD_mean DensM
	
	 tab anycig2 anycig if year==2011, cell
	
	gen DistXPost = DistM*Post
	foreach x of global X{
		gen `x'XPost = `x'*Post
	}
	gen DistXDensXPost = DistXPost*DensM
	gen DensXPost = DensM*Post
	gen DensXDist = DensM*DistM
	
	rename anycig Prevalence
	
	glo XPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"
	
	
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
		
		eststo a6_p: reg Prevalence DistM Post DensM DistXDensXPost DistXPost $X $XPost i.upz1 [iw=_peso1], vce(cluster upz1)

		
		*eststo a6_p: reg Prevalence DistM Post DensM DistXDensXPost DensXDist DistXPost DensXPost $X $XPost i.upz1, vce(cluster upz1)

		
		esttab a1a_p a3_p a4_p a5_p, se r2 keep(DistXDensXPost DistM Post DensM DensXDist DistXPost DensXPost) ///
				stats(Prev_mean Prev_sd N ag N_clust) ///
				star(* .1 ** .05 *** .01) title(Difference in Differences Results - Density)  tex nogaps										
}


	
********************************************************************************
* HETEROGENEOUS EFFECTS
********************************************************************************
if 1==1 { // socio-demographic characteristics -  het_results.tex  --
/* Difference in differences - Age of HH head  */

	use "$mainE\superBaseECVSusanaOtalvaro\EMB2011\derived\EMB2011_2_Matched_allExp.dta", clear 
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
	
	rename anycig Prevalence
	recode Age (16/49 = 1 "16 to 49")(50/105 = 0 "50+"), g(Young)
	gen Old = 1-Young
	
	glo XPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"

		
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
	
	rename anycig Prevalence
	gen Kids = (numnin>0)
	gen Kids2 = (numnin>1)
	
	
	glo XPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"

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
	
	rename anycig Prevalence
	gen white_collar = ((educacion>2 & (ocupacion!=3 | ocupacion!=6 | ocupacion!=7)) | (educacion>1 & (ocupacion!=1 | ocupacion!=3 | ocupacion!=6 | ocupacion!=7)))	
	rename white_collar  White
	

	glo XPost "AgeXPost GenderXPost KidsAdultsXPost TotIndivXPost PrimaryXPost SecondaryXPost"


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