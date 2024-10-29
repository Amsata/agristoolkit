local varlist Region Prefecture Sect1_C4 Tranche_age
split rownames, p(@)
rename rownames1 Indicator
replace Indicator= regexr(Indicator, "^c.", "")
rename rownames2 dimension
split dimension, p(#)
		
local c : word count `varlist'
		forvalues i=1/`c' {
			local v "`:word `i' of `varlist''"
			rename dimension`i' `v'
			replace `v' = regexs(1) if regexm(`v', "([0-9]+)")
			*cap replace `v'= ustrregexra(`v',".`v'","")
			*cap replace `v'= ustrregexra(`v',"bn","")
			*replace `v'= ustrregexra(`v',"o","")

			*cap destring `v', replace
		}