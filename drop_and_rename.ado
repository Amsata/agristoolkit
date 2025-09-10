cap program drop drop_and_rename
program define drop_and_rename

syntax , pattern(string)

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
	
drop `initial_vars'

forvalues i=1/`size_vwp' {
rename `:word `i' of `var_with_pattern'' `:word `i' of `initial_vars''

}

	di as res "variables detected {cmd: `var_with_pattern'}"	
}
else {
	di as res "No variables detected!"
}

end

