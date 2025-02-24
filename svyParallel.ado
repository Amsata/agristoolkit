program svyParallel
	args varlist variable parameter setcluster
	*tuples `varlist' // for looping over all dimensions
	local si: list sizeof variable
	local s_varlist: list sizeof varlist
	local s_cond: list sizeof conditionals

	if (`s_varlist'==0) {
		local alldim "yes"
		local ntuples 1
	}
	else {
		local alldim "no"
		if (`s_cond'==0) tuples `varlist' 
		else tuples `varlist', conditionals(`conditionals') 
	} 

	if (`setcluster'==0) {
		tempfile odp_tab
		scalar def init=0
		forvalues i=1/`si' {
			forvalues j=1/`ntuples' {
				if("`alldim'"=="no") local tuple "`tuple`j''" 
				else local tuple "`varlist'"
				local var "`:word `i' of `variable''"				
				if("`alldim'"=="no") di"Generating {cmd: `parameter'} of {cmd:`var'}  over {cmd:`tuple'}..."
				else di"Generating {cmd:`parameter'} of {cmd:`var'} in the population/sub-population..."
				quietly{
					preserve
					************************************************************************
					*****check if there are hierarchical structure between 2 variables******
					************************************************************************	
					quietly svyEstimate `tuple' , param(`parameter') var(`var') alldim(`alldim')				
					cap append using `odp_tab'
					save `odp_tab', replace
					restore
				}		
			}
		}	
		use  `odp_tab', clear
	}
	else{
		forvalues i=1/`si' {
			forvalues j=1/`ntuples' {
				if("`alldim'"=="no") local tuple "`tuple`j''" 
				else local tuple "`varlist'"
				local var "`:word `i' of `variable''"
				if(`ntuples'>=`si') local core = mod(`j' - 1, $PLL_CLUSTERS) + 1
				else local core = mod(`i' - 1, $PLL_CLUSTERS) + 1
				if($pll_instance == `core') {
					m: parallel_sandbox(5)  
					use "$temp_file", clear			
					***************************************************************
					*check if there are hierarchical structure between 2 variables*
					***************************************************************
					quietly svyEstimate `tuple' , param(`parameter') var(`var') alldim(`alldim')
					
					if (c(os)=="Windows") local saving = `"`c(tmpdir)'__pll_`parallelid'_$pll_instance.dta"'
					else local saving = `"`c(tmpdir)'/__pll_`parallelid'_$pll_instance.dta"'
		
					save  `saving', replace
				}
			}
		}	
	}
end
