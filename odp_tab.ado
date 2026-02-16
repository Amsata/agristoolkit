cap program drop odp_tab
program define odp_tab, rclass
		
	syntax [varlist(default=none)] [if], [  tabtitle(string asis) truncate header(string asis) outfile(string) indicator(string asis) indicatorname(varlist) indvar(varlist) value(varlist) rowtotal (string) DECimal(string) valid (string) replace]
 
	local size_varlist:list sizeof varlist
	local size_tabtitle:list sizeof tabtitle
	local size_rowtotal:list sizeof rowtotal
	local size_header: list sizeof header
	local size_valid: list sizeof valid

	if(`size_tabtitle'>0) di as result `"Generating table: {cmd:`tabtitle'}..."'
	
	quietly {
****************defining default name for variables ****************************
	if ("`indvar'"=="") local indvar "Variable"
	if ("`indicatorname'"=="") local indicatorname "IndicatorName"
	if ("`value'"=="") local value "Value_str"
	
***************extract PATH, SHEET NAME and START CELL NUMBER from outfile ********
    local outfile = trim("`outfile'")  // Strip leading/trailing whitespace
    tokenize "`outfile'", parse(",")  // Split by comma
    local path = trim("`1'") // Assign values
    local sheet_name = trim("`3'") // Assign values
    local cell_start_num   = trim("`5'") // Assign values
	local cell_start   = trim("`7'") // Assign values

	if ("`sheet_name'"=="") local sheet_name "TABLES"
	if ("`cell_start_num'"=="") local cell_start_num=1
	if ("`cell_start'"=="") local cell_start "A"
	
		
	putexcel set "`path'", modify sheet("`sheet_name'")  
local alphabet "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BA BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ CA CB CC CD CE CF CG CH CI CJ CK CL CM CN CO CP CQ CR CS CT CU CV CW CX CY CZ DA DB DC DD DE DF DG DH DI DJ DK DL DM DN DO DP DQ DR DS DT DU DV DW DX DY DZ EA EB EC ED EE EF EG EH EI EJ EK EL EM EN EO EP EQ ER ES ET EU EV EW EX EY EZ"
local col_num_start_cell:list posof "`cell_start'" in alphabet


	if regexm("`indicator'", "^regex=") {
	preserve
        // Extract the pattern from the option
        local pat : subinstr local indicator "regex=" "", all
		local pat:list clean pat
        // Keep only observations matching the regex
        tempvar keep_obs
        gen byte `keep_obs' = regexm(`indvar', `"`pat'"')

        // Collect unique values
        levelsof `indvar' if `keep_obs', local(matched_values)
		local indicator: list clean matched_values
        // Display or store in local macro
        *di `"Matched values: `matched_values'"'
		restore
    }
	
	preserve

	***extract indocator labels from the variable containing the indicator name	
	gen tablabel = regexs(0) if regexm(`indicatorname', "#.*")	
	replace tablabel = subinstr(tablabel, "#", "", .)
	replace tablabel=`indicatorname' if tablabel==""

	local TitleCell_num=`cell_start_num'
	
	
/************* SETTING THE TABLE COLUMN HEADINGS ********************************/
	if (`size_header'>0) local TabTitleCell_num=`TitleCell_num'+2
	else local TabTitleCell_num=`TitleCell_num'+1
	local TitleCell="`cell_start'`TitleCell_num'"
	local TabTitleCell="`cell_start'`TabTitleCell_num'"
	


	if ("`if'"!="") keep `if'
	
	gen keepflag = 0
	foreach d of local indicator {
		replace keepflag = 1 if `indvar' == "`d'"
	}
	keep if keepflag==1
	drop keepflag
	
	tempfile filtered_dataset
	save `filtered_dataset', replace
	
	keep `varlist' `indvar' tablabel
	cap isid `varlist' `indvar'
	if _rc {
		di as error "Error: `varlist' and `indvar' do not uniquely identify row in the dataset of the given subset specify in '`if'' !"
		exit 1
	}
	order `varlist' `indvar' tablabel
	tempfile dataset_to_use
	save `dataset_to_use', replace
	
	****************************************************************************
	*********** ADDING VALID IF ALL INDICATOR HAVE THE SAME POPULATION**********
	****************************************************************************
	use  `filtered_dataset', clear
	keep `varlist' `indvar' N_subPop
	replace N_subPop=round(N_subPop)
	reshape wide N_subPop, i(`varlist') j(`indvar') string
	ds, has(type numeric)
	mkmat `r(varlist)', matrix(M)
	mat list M
	mata: allcols_equal("M", "max_diff")
	/*
	ds N_subPop*
	local N_subPop_var `r(varlist)'
	local n_variable: list sizeof N_subPop_var
	local first_variable `:word 1 of `N_subPop_var''
	egen som_Obs=rsum(`N_subPop_var')
	gen som_Obs2=`first_variable'*`n_variable'
	gen diff=som_Obs-som_Obs2
	cap su diff
	local max_diff=`r(max)'
	*/
	if (`max_diff'==0) {

	use `filtered_dataset',clear
	keep if `indvar' =="`:word 1 of `indicator''"
	keep `varlist' `indvar'
	replace `indvar'="Valid"
	local indicator Valid `indicator'
	if (`size_valid'==0) gen tablabel="Valid"
	else gen tablabel="`valid'"
	order `varlist' `indvar' tablabel
	tempfile valid_dataset
	save `valid_dataset', replace
	}

*********************************************
use `dataset_to_use',clear
if (`max_diff'==0 & `size_valid'>0) append using `valid_dataset'
	
	
	************create order****************
	gen indvar2=.
	local n_ind:list sizeof indicator
	forvalues i=1/`n_ind' {
	replace indvar2=`i' if `indvar'== "`:word `i' of `indicator''"
	}
	cap label drop ind_label
	label define ind_label 1 "`:word 1 of `indicator''"
		forvalues i=2/`n_ind' {
			label define ind_label `i' `"`:word `i' of `indicator''"', add
		}
	label val indvar2 ind_label
	drop `indvar'
	ren indvar2 `indvar'
	*************end order creation ***********
	
	reshape wide tablabel, i(`varlist') j(`indvar')
	
	*fill all the missing
	
			unab all_vars: *
			local indvar_bis:list all_vars-varlist

		foreach v of local indvar_bis {
			gsort -`v'
			replace `v' = `v'[_n-1] if missing(`v') & _n > 1
		}

	foreach v of local varlist {
	
		if "`: value label `v''" != "" {
			tostring  `v', gen(`v'_bis)
			drop `v' 
			ren `v'_bis `v'
			}
			
		replace `v'="`v'"
	}

	keep if _n==1
	
	if ("`truncate'"!="") drop `varlist'

	if (`size_rowtotal'!=0) gen Total= `"`rowtotal'"'
	local end_num=`TabTitleCell_num'+1
	local cell_end "`cell_start'`end_num'"
	if ("`replace'"!="") export excel using "`path'",  sheet("`sheet_name'", replace)  cell(`TabTitleCell')
	else export excel using "`path'",  sheet("`sheet_name'", modify)  cell(`TabTitleCell')

	qui describe
	local leng_tab=`r(k)'+`col_num_start_cell'-1
	local leng_tab_final=`r(k)'+`col_num_start_cell'
	local tab_end_cell_letter="`:word `leng_tab' of `alphabet''"
	local tab_after_end_cell_letter="`:word `leng_tab_final' of `alphabet''"

	local EndTabTitleCell="`:word `leng_tab' of `alphabet''`TabTitleCell_num'"
	putexcel (`TabTitleCell':`EndTabTitleCell'), border(all, thin) bold font("Arial",10)  vcenter txtwrap
		****specify header cell
	if(`size_header'>0){
	local line_header_cell=`TitleCell_num'+1
	if("`truncate'"=="") local pos_header_cell=`col_num_start_cell'+`size_varlist'
	else local pos_header_cell=`col_num_start_cell'
	local letter_header_cell= "`:word `pos_header_cell' of `alphabet''"
	local header_cell_start= "`letter_header_cell'`line_header_cell'"
	local header_cell_end="`tab_end_cell_letter'`line_header_cell'"
	putexcel `header_cell_start'=`header',bold font("Arial",10) border(all, medium)
	*putexcel `header_cell_start',
	
	di "header_cell_end: `header_cell_start'"
	di "header_cell_end=`header_cell_end'"

	putexcel (`header_cell_start':`header_cell_end'), merge  hcenter  vcenter
	}
	
/*****************************  FILLING TABLE CELLS ****************************/
/*
	preserve
	if "`if'"!="" keep `if'
	
	gen keepflag = 0
	foreach d of local indicator {
		replace keepflag = 1 if `indvar' == "`d'"
	}
	keep if keepflag
	drop keepflag
	*keep if inlist(`indvar',`indicator')
*/
	

	*********************ADDING VALID*********************************
	
	if (`max_diff'==0) {
	use `filtered_dataset',clear
	keep if  `indvar'=="`:word 2 of `indicator''"
	keep `varlist' `indvar' N_subPop
	replace N_subPop=round(N_subPop)
	gen `value' = string(N_subPop, "%15.2f")
	drop N_subPop
	replace `indvar'="Valid"
	order `varlist' `indvar' `value'
	tempfile valid_dataset
	save `valid_dataset', replace
	}
	
	use `filtered_dataset', clear
	keep  `varlist' `indvar' `value'
	order `varlist' `indvar' `value'
	if (`max_diff'==0 & `size_valid'>0) append using `valid_dataset'
	

	************create order****************
	gen indvar2=.
	local n_ind:list sizeof indicator
	forvalues i=1/`n_ind' {
	replace indvar2=`i' if `indvar'== "`:word `i' of `indicator''"
	}
	cap label drop ind_label
	label define ind_label 1 "`:word 1 of `indicator''"
		forvalues i=2/`n_ind' {
			label define ind_label `i' `"`:word `i' of `indicator''"', add
		}
	label val indvar2 ind_label
	drop `indvar'
	ren indvar2 `indvar'
	*************end order creation ***********
	
	
	****************number of masked cells and cells with zero ***************
	gen strrrr=`value'
	replace strrrr="0" if strrrr=="0[w]"
	destring strrrr, generate(strrrr_bis) force
	qui count 
	local number_of_cells=`r(N)'
	count if missing(strrrr_bis)
	local masked_cells_number=`r(N)'
	count if strrrr_bis==0
	local zero_cells_number=`r(N)'
	local per_masked_cells=`masked_cells_number'/`number_of_cells'*100
	local per_zero_cells=`zero_cells_number'/`number_of_cells'*100
	local per_masked_cells=round(`per_masked_cells',1)
	local per_zero_cells=round(`per_zero_cells')
	drop strrrr strrrr_bis
	
	reshape wide `value', i(`varlist') j(`indvar')

	*********adding rowtoal if sceified****************************************
	if (`size_rowtotal'!=0) {
		*because of label it connot compute sum
		unab all_vars: *
		local nom_valid="Value_str1"
		local indvar2:list all_vars-varlist 
		
		if(`max_diff'==0) local indvar2: list indvar2-nom_valid

		foreach v of local indvar2 {
			gen `v'_bis=`v'
			replace `v'_bis="0" if `v'_bis=="0[w]"
			destring `v'_bis, generate(addd_`v') force
			drop `v'_bis
		}
		ds addd_*
		egen Total=rowtotal(`r(varlist)')
		ds addd_*
		drop `r(varlist)'
		local rowtot_name="Total"
	}
	if ("`decimal'"==",") {
		foreach v of local indvar2 {
			replace `v' = subinstr(`v', ".", ",", .)
		}
	}
	
	********replacing "." with the specified decimal ex. ","
	unab all_vars: *
	local indvar2:list all_vars-varlist
	
	if (`size_rowtotal'!=0) local indvar2:list indvar2-rowtot_name
	
	foreach v of local indvar2 {
	replace `v'="[:]" if `v'==""
}
	
	if ("`decimal'"!="") {
		foreach v of local indvar2 {
			replace `v' = subinstr(`v', ".", "`decimal'", .)
		}
	}

	if ("`truncate'"!="") drop `varlist'

	export excel using  "`path'", sheet("`sheet_name'", modify) cell(`cell_end')
	
********************************************************************************
***************************TABLE FORMATING**************************************
********************************************************************************
	if (`size_tabtitle'!=0) putexcel `TitleCell' = `tabtitle'
	qui count 
	local TabCellEnd_num=`r(N)'+`end_num'-1
	local TabCellEnd= "`cell_start'`TabCellEnd_num'"

	qui describe
	local leng_tab=`r(k)'+`col_num_start_cell'-1
	local EndTabCell="`:word `leng_tab' of `alphabet''`TabCellEnd_num'"
	

	*putexcel (`TabCellEnd':`EndTabCell'), border(top, thin) bold font("Arial",10) // if margin is absent
	if (`size_header'==0) putexcel (`TabCellEnd':`EndTabCell'), border(bottom, thin) 
	else  putexcel (`TabCellEnd':`EndTabCell'), border(bottom, medium) 
	
	if ("`truncate'"=="") putexcel (`TabTitleCell':`TabCellEnd'), border(right, thin) bold font("Arial",10)
	putexcel (`TabTitleCell':`TabCellEnd'), border(left, thin)  
	
	if ("`truncate'"=="") putexcel (`EndTabTitleCell':`EndTabCell'), border(right, thin) font("Arial",10)
	else putexcel (`EndTabTitleCell':`EndTabCell'), border(right, medium) font("Arial",10)
	putexcel (`TabTitleCell':`EndTabCell'),  hcenter vcenter
	putexcel (`cell_end':`EndTabCell'),  nformat(number_d2) font("Arial",9) right
	if ("`truncate'"=="") putexcel (`TabTitleCell':`TabCellEnd'),  left
	else putexcel (`TabTitleCell':`TabCellEnd'),  right border(left, medium)
	if (`size_header'>0 & "`truncate'"=="" ) putexcel (`TabTitleCell':`TabCellEnd'), border(right, medium)
	
	putexcel (`TitleCell'),  font("Arial",10,"blue") italic

	************ Masked cells footnote
	local maskedCellNote_cell_num=`TabCellEnd_num'+1
	local empy_cell_meta="`cell_start'`maskedCellNote_cell_num'"
	local maskedCellNote="Percentage of masked cells: `per_masked_cells'%"
	putexcel `empy_cell_meta' = "`maskedCellNote'"
	putexcel (`empy_cell_meta'),  left font("Arial",9,"red") italic

	**************** Zero cells footnote
	local zeroCellNote_cell_num=`TabCellEnd_num'+2
	local zero_cell_meta="`cell_start'`zeroCellNote_cell_num'"
	local zeroCellNote="Percentage of cells with value zero(0): `per_zero_cells'%"
	putexcel `zero_cell_meta' = "`zeroCellNote'"
	putexcel (`zero_cell_meta'),  left font("Arial",9,"red") italic
	restore
}

return scalar tab_start_line=`cell_start_num'
return local tab_start_cell_letter="`cell_start'"
return local tab_end_cell_letter="`tab_after_end_cell_letter'"
return scalar tab_end_line=`TabCellEnd_num'+4

end
	

	mata:
void allcols_equal(string scalar matname, string scalar localname)
{
    real matrix M
    real scalar all_equal

    // Load Stata matrix into Mata
    M = st_matrix(matname)

    // Check if all columns equal the first one
    all_equal = all(M :== M[,1])

    // Put result into a local macro in Stata
    st_local(localname, strofreal(all_equal))
}
end