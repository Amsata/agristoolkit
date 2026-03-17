
cap program drop svyEstimate
program define svyEstimate
		
	syntax [varlist] ,PARAMeter(string) VARiable(string asis) ///
	[conditionals(string asis) svySE(string) subpop(string asis) alldim(string asis) ]

		quietly {
		************************************************************************
		*** Generate estimate over dimension the given dimension combination ***
		************************************************************************

		if ("`parameter'"=="median") {
		
		local other_vars CV_pct se t pvalue ll ul df crit eform

		qui svyset
		local weight `r(weight1)'
		local pweight `r(wvar)'
		if ("`weight'"!="") local weight `r(weight1)'
		if ("`pweight'"!="") local weight `r(wvar)'
		
		if("`alldim'"=="yes"){
		
			preserve
			collapse (median) b=`variable' (count) N_subPop=`variable'  [pweight=`weight']
			gen key=1
			tempfile median_est
			save `median_est', replace
			restore
					
			collapse (count) n_Obs=`variable' 
			gen key=1
			merge 1:1 key using `median_est', nogen	
			drop key
			gen Indicator="`variable'"
			
			foreach v of local other_vars {
			gen `v'=.
			}
			
			order CV_pct b se t pvalue ll ul df crit  eform n_Obs N_subPop Indicator 

			
		}
		else {
			preserve
			collapse (median) b=`variable' (count) N_subPop=`variable'  [pweight=`weight'], by(`varlist')
			tempfile median_est
			save `median_est', replace
			restore
					
			collapse (count) n_Obs=`variable' , by(`varlist')
			merge 1:1 `varlist' using `median_est', nogen	
			*remove label in dimension like in mean, ratio, or total
			foreach var of local varlist {
				label val `var'
			}
			
			foreach v of local other_vars {
				gen `v'=.
			}
			
			gen Indicator="`variable'"
			order CV_pct b se t pvalue ll ul df crit eform n_Obs N_subPop Indicator

		}
		
		}
		
		else {
			if("`alldim'"=="yes") svy: `parameter' `variable'
			else svy, over(`varlist'): `parameter' `variable'
			qui return list
			matrix define T= r(table)'	
			qui ereturn list
			matrix define n_subpop= e(_N)'	
			matrix define N_subpop= e(_N_subp)'	

			mat_to_ds T "yes"		   
			tempfile res_estimation
			save `res_estimation', replace
			
			mat_to_ds n_subpop "no"	   
			tempfile dataset_n_obs
			order rownames
			unab all_vars: *
			rename `:word 2 of `all_vars'' n_Obs // or word(`all_vars', 1)
			save `dataset_n_obs', replace
			
			mat_to_ds N_subpop	"no"   
			tempfile dataset_N_subpop
			order rownames
			unab all_vars: *
			rename `:word 2 of `all_vars'' N_subPop // or word(`all_vars', 1)
			save `dataset_N_subpop', replace
			
			* Estimating coefficient of variation
			estat cv
			matrix define CV = r(cv)'
			mat_to_ds CV "yes"
			*renaming the variable to CV
			unab all_vars: *
			rename `:word 1 of `all_vars'' CV_pct // or word(`all_vars', 1)
			merge 1:1 rownames using `res_estimation', nogen
			merge 1:1 rownames using `dataset_n_obs', nogen
			merge 1:1 rownames using `dataset_N_subpop', nogen
			if("`parameter'"=="ratio") replace rownames = regexr(rownames, "^[^@]+", "`variable'")
			
			if ("`alldim'"!="yes") {
			   split rownames, p(@)
				capture drop Indicator
				rename rownames1 Indicator
				replace Indicator= regexr(Indicator, "^co.", "")
				replace Indicator= regexr(Indicator, "^c.", "")
				rename rownames2 dimension
				split dimension, p(#)
				local c : word count `varlist'
				forvalues i=1/`c' {
				local v "`:word `i' of `varlist''"
				rename dimension`i' `v'
				replace `v' = regexs(1) if regexm(`v', "([0-9]+)")
				cap destring `v', replace
				}
				drop dimension 
				drop rownames
			}
			else {
				gen Indicator=rownames
				drop rownames
			}
		}
		
	

		*break 498
		**************************************************************************
		*** Extract correct dimension name and merging with sample frequencies (possible from Stata 17 ***
		*************************************************************************
		
		
		} //quietly
	
end

*include controle in case of hierarchical geographic variable, indication=> to many zero/missing value in sample frequencies
