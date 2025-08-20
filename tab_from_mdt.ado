


cap program drop tab_from_mdt
program define tab_from_mdt, rclass

	syntax [varlist(default=none)] [if], [  tabtitle(string asis) outfile(string) indicator(string asis) indicatorname(varlist) indvar(varlist) over(string asis) value(varlist) rowtotal(string) by(varlist) DECimal(string) replace]
	
local number_ind: list sizeof indicator
local size_by: list sizeof by
local size_over: list sizeof over

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
	
if (`size_by'==0) {
	if(`size_over'==0) {
		odp_tab `varlist' `if' , tabtitle(`tabtitle') outfile(`outfile') indicator(`indicator') indicatorname(`indicatorname')  ///
		indvar(`indvar') value(`value') rowtotal(`rowtotal') decimal(`decimal') `replace'
	}
	else {
	
		levelsof `over', local(my_macro)
		local init=0
		foreach v of local my_macro {
			if (`init'==0){
				local lbl : label (`over') `v'
				*preserve 
				*keep if `over'==`v'
				odp_tab `varlist' `if' 	 & `over'==`v', tabtitle(`tabtitle') outfile(`outfile') indicator(`indicator') indicatorname(`indicatorname') indvar(`indvar') ///
				value(`value') rowtotal(`rowtotal') decimal(`decimal')  header("`lbl'") `replace'
				local init=1
				local tab_start_cell_letter_in="`r(tab_start_cell_letter)'"
				*restore
			}
			else {
				local lbl : label (`over') `v'
				*preserve 
				*keep if `over'==`v'
				odp_tab `varlist' `if' & `over'==`v' , outfile("`path'", "`sheet_name'", `r(tab_start_line)',`r(tab_end_cell_letter)') indicator(`indicator') indicatorname(`indicatorname')  indvar(`indvar') ///
				value(`value') rowtotal(`rowtotal') decimal(`decimal')  header("`lbl'")  truncate
				*restore
			}
		}
	}
}

else if (`size_by'!=0 & `number_ind'==1) {
		odp_tab2 `varlist' `if' , tabtitle(`tabtitle') outfile(`outfile') indicator(`indicator') indvar(`indvar') value(`value') by(`by') rowtotal(`rowtotal') decimal(`decimal') indicatorname(`indicatorname') `replace'
}
else {
odp_tab3 `varlist' `if' ,  outfile(`outfile') indicator(`indicator') indvar(`indvar') value(`value') by(`by') rowtotal(`rowtotal') decimal(`decimal') indicatorname(`indicatorname') `replace'
}

return scalar tab_start_line=`r(tab_start_line)'
if(`size_over'>0) return local tab_start_cell_letter= "`tab_start_cell_letter_in'"
else return local tab_start_cell_letter= "`r(tab_start_cell_letter)'"
return local tab_end_cell_letter="`r(tab_end_cell_letter)'"
return scalar tab_end_line=`r(tab_end_line)'


end
