


cap program drop tab_from_mdt
program define tab_from_mdt, rclass

	syntax [varlist(default=none)] [if], [  tabtitle(string asis) outfile(string) indicator(string asis) indicatorname(varlist) indvar(varlist) value(varlist) rowtotal(string) by(varlist) DECimal(string)]
	
local number_ind: list sizeof indicator

	***extract path, sheet name and start cell num from outfile
    // Strip leading/trailing whitespace
    local outfile = trim("`outfile'")
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
	
if ("`by'"=="") {
	*syntax [varlist(default=none)] [if], [  tabtitle(string asis) outfile(string) indicator(string asis) indicatorname(varlist) indvar(varlist) value(varlist) rowtotal (string) DECimal(string)]
		odp_tab `varlist' `if' , tabtitle(`tabtitle') outfile(`outfile') indicator(`indicator') indicatorname(`indicatorname') indvar(`indvar') value(`value') rowtotal(`rowtotal') decimal(`decimal') 	
}

else if ("`by'"!="" & `number_ind'==1) {
		odp_tab2 `varlist' `if' , tabtitle(`tabtitle') outfile(`outfile') indicator(`indicator') indvar(`indvar') value(`value') by(`by') rowtotal(`rowtotal') decimal(`decimal') indicatorname(`indicatorname')
}
else {
odp_tab3 `varlist' `if' ,  outfile("`path'", "`sheet_name'", `cell_start_num') indicator(`indicator') indvar(`indvar') value(`value') by(`by') rowtotal(`rowtotal') decimal(`decimal') indicatorname(`indicatorname')
}

	return local cellEnd `r(cellEnd)'


end