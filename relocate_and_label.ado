cap program drop relocate_and_label
program define relocate_and_label

syntax , pattern(string) [label(string) replace]

local size_label: list sizeof label
local size_pattern:list sizeof pattern

if(`size_pattern'>1) {
di as error "the argument pattern should contain only one string"
}
unab all_variables:*
local var_with_pattern
local initial_vars
local length_parttern=length("`pattern'")

foreach var of local all_variables {
	if regexm("`var'","`pattern'$") {
		local var_with_pattern `var_with_pattern' `var'
	}
}
local size_vwp:list sizeof var_with_pattern
if (`size_vwp'>0) {
	foreach v of local var_with_pattern {
	local base=substr("`v'",1,length("`v'")-`length_parttern')
	local initial_vars `initial_vars' `base'
	}	
	foreach v of local initial_vars{
		*relocation
		order `v'`pattern', after(`v')
		*labelisation
		local init_var_label : variable label `v'
		local patt_var_label : variable label `v'`pattern'

		if ("`patt_var_label'"==""){
			if (`size_label'==0) label variable `v'`pattern' "`init_var_label'"
			else label variable `v'`pattern' `"`init_var_label' - `label'"'
		}
		else {
		
			if ("`replace'"!="") {
				if (`size_label'==0) label variable `v'`pattern' "`init_var_label'"
				else label variable `v'`pattern' `"`init_var_label' - `label'"'
			}
		}	
	}	
	di as res "variables detected {cmd: `var_with_pattern'}"	
}
else {
	di as res "No variables detected!"
}

end

*relocate_and_label , pattern("_imp") label("corrigée") replace