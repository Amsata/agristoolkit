
cap program drop svyParallelGeo
program svyParallelGeo

args varlist hiergeovars variable parameter 
	*tuples `varlist' // for looping over all dimensions
    local si: list sizeof variable
	local s_varlist: list sizeof varlist
	local s_geovars: list sizeof hiergeovars


	if(`s_varlist'==0 & `s_geovars'==0) {
		local alldim "yes"
		local ntuples 1
		local s_geovars=1

	}
	else {
		local alldim "no"
	}
	
forvalues k=1/`s_geovars' {	
	*if ("`conditionals'"=="") {
		if(`s_varlist'==0) {
			local new_varlist "`:word `k' of `hiergeovars''"
		tuples `new_varlist' 
		}
		else {
			local new_varlist "`:word `k' of `hiergeovars'' `varlist'"
		tuples `new_varlist' 
		}
	*}
	*else{
	*	tuples `varlist', conditionals(`conditionals') 
	*}
	forvalues i=1/`si' {
		forvalues j=1/`ntuples' {
			*tuples `varlist'
			if("`alldim'"=="no") local tuple "`tuple`j''" 
			else local tuple "`new_varlist'"
			local var "`:word `i' of `variable''"

			*local core = mod(`j' - 1, $PLL_CLUSTERS) + 1
			if(`ntuples'>=`si') local core = mod(`j' - 1, $PLL_CLUSTERS) + 1
			else local core = mod(`i' - 1, $PLL_CLUSTERS) + 1
			
		if($pll_instance == `core') {
		m: parallel_sandbox(5)  

		use "$temp_file", clear

	
	foreach v of local tuple {	
	*Exploring labelsof command would reduce this number of line
	local old_vl: value label `v'
	elabel copy `old_vl' ld_`v' 
	}
	tempfile  dolabs
	// store them in a temporary do-file
	label save using `dolabs'
		************************************************************************
		*****check if there are hierarchical structure between 2 variables******
		************************************************************************	
			quietly svyEstimate `tuple' , param(`parameter') var(`var') alldim(`alldim')
			gen geoType="`:word `k' of `hiergeovars''"
			capture confirm variable `:word `k' of `hiergeovars''
			if _rc == 0 {
				run `dolabs'
				label values `:word `k' of `hiergeovars'' ld_`:word `k' of `hiergeovars''
				decode `:word `k' of `hiergeovars'', gen(geoVar)
				drop `:word `k' of `hiergeovars''
			}
	*drop rownames
			
		save __pll_`parallelid'_$pll_instance.dta, replace
		*append using `odp_tab', force
		*save `odp_tab', replace
		*restore // restore the iniial dataset for the continuation of the loop on tuples
		}
	}
	}	
} // forvalues geovars
end
