program define odp_tab3, rclass
		
		 **  tablabelvar(varlist) indvar(varlist)
		*syntax [varlist(default=none)] [if], [  tabtitle(string asis) outfile(string) indicator(string asis) indicatorname(varlist) indvar(varlist) value(varlist)]
	syntax [varlist(default=none)] [if] , [ outfile(string) indicator(string) indvar(varlist) value(varlist) by(varlist) rowtotal(string) decimal(string asis) indicatorname(varlist)]
	
	***extract path, sheet name and start cell num from outfile
    // Strip leading/trailing whitespace
    local outfile = trim("`outfile'")

    // Remove parentheses if present
   * local outfile = subinstr("`outfile'", "(", "", .)
   * local outfile = subinstr("`outfile'", ")", "", .)

    // Split by comma
    tokenize "`outfile'", parse(",")

    // Assign values
    local path = trim("`1'")
    local sheet_name = trim("`3'")
    local cell_start_num   = trim("`5'")
	
	if ("`sheet_name'"=="") {
	local sheet_name "TABLES"
	local cell_start_num=1
	}
	
	local counter=0
	foreach ind of local indicator {
	if (`counter'==0) {
		odp_tab2 `varlist' `if' ,  outfile("`path'", "`sheet_name'", `cell_start_num') indicator(`ind') indvar(`indvar') value(`value') by(`by') rowtotal(`rowtotal') decimal(`decimal') indicatorname(`indicatorname')
		
		local counter=1
	}
	else {
			odp_tab2 `varlist' `if' ,  outfile("`path'", "`sheet_name'",`r(cellEnd)') indicator(`ind') indvar(`indvar') value(`value') by(`by') rowtotal(`rowtotal') decimal(`decimal') indicatorname(`indicatorname')
	}  
	
	}
	return local cellEnd `r(cellEnd)'

end
