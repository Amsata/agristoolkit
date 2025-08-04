program define to_string
		
	syntax [varlist(default=none max=1)] 
	unab all_vars:*
	decode `varlist',gen(new_var)
	drop `varlist'
	ren new_var `varlist'
	order `all_vars'
end
	