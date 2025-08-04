program define erase_after_hash
		
	syntax [varlist(default=none max=1)] 

	if ("`varlist'"=="") local varlist "IndicatorName"
	replace `varlist' = regexr( `varlist' , "#.*", "")

end
	