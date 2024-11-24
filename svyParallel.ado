

program svyParallel

args varlist variable parameter

	*tuples `varlist' // for looping over all dimensions
    local si: list sizeof variable
	local s_varlist: list sizeof varlist
	
	if(`s_varlist'==0) {
		local alldim "yes"
		local ntuples 1
	}
	else {
		local alldim "no"
		*if ("`conditionals'"=="") {
		tuples `varlist' 
	*}
	*else{
	*	tuples `varlist', conditionals(`conditionals') 
	*}
	
	} 

	forvalues i=1/`si' {
		forvalues j=1/`ntuples' {
			*tuples `varlist'
			if("`alldim'"=="no") local tuple "`tuple`j''" 
			else local tuple "`varlist'"
			local var "`:word `i' of `variable''"

			*local core = mod(`j' - 1, $PLL_CLUSTERS) + 1
			if(`ntuples'>=`si') local core = mod(`j' - 1, $PLL_CLUSTERS) + 1
			else local core = mod(`i' - 1, $PLL_CLUSTERS) + 1
			
		if($pll_instance == `core') {
		m: parallel_sandbox(5)  

		use "$temp_file", clear

		
		************************************************************************
		*****check if there are hierarchical structure between 2 variables******
		************************************************************************	
			quietly svyEstimate `tuple' , param(`parameter') var(`var') alldim(`alldim')

		save __pll_`parallelid'_$pll_instance.dta, replace
		*append using `odp_tab', force
		*save `odp_tab', replace
		*restore // restore the iniial dataset for the continuation of the loop on tuples
		}
	}
	}	
end