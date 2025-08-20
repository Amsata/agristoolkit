cap program drop odp_tab
program define odp_tab, rclass
		
	syntax [varlist(default=none)] [if], [  tabtitle(string asis) truncate header(string asis) outfile(string) indicator(string asis) indicatorname(varlist) indvar(varlist) value(varlist) rowtotal (string) DECimal(string) replace]

	local indicatorbis=subinstr(`"`indicator'"', ",", " ", .)
	local s:list sizeof indicatorbis
	local size_varlist:list sizeof varlist
	local size_tabtitle:list sizeof tabtitle
	local size_rowtotal:list sizeof rowtotal

	local size_header: list sizeof header
	local indicator2
	foreach v of local indicatorbis {
	local indicator2= "`indicator2' `v'"
	}

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
	local alphabet "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"  // TO DO: expand AA AB AC etc to increase the capability of the fuction
	local col_num_start_cell:list posof "`cell_start'" in alphabet

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
	keep if inlist(`indvar', `indicator')
	keep `varlist' `indvar' tablabel
	cap isid `varlist' `indvar'
	if _rc {
		di as error "Error: `varlist' and `indvar' do not uniquely identify row in the dataset of the given subset specify in '`if'' !"
		exit 1
	}

	************create order****************
	gen indvar2=.
	local n_ind:list sizeof indicator2
	forvalues i=1/`n_ind' {
	replace indvar2=`i' if `indvar'== "`:word `i' of `indicator2''"
	}
	cap label drop ind_label
	label define ind_label 1 "`:word 1 of `indicator2''"
		forvalues i=2/`n_ind' {
			label define ind_label `i' `"`:word `i' of `indicator2''"', add
		}
	label val indvar2 ind_label
	drop `indvar'
	ren indvar2 `indvar'
	*************end order creation ***********
	
	reshape wide tablabel, i(`varlist') j(`indvar')

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
	restore

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
	preserve
	if "`if'"!="" keep `if'
	keep if inlist(`indvar',`indicator')
	keep  `varlist' `indvar' `value'

	
	************create order****************
	gen indvar2=.
	local n_ind:list sizeof indicator2
	forvalues i=1/`n_ind' {
	replace indvar2=`i' if `indvar'== "`:word `i' of `indicator2''"
	}
	cap label drop ind_label
	label define ind_label 1 "`:word 1 of `indicator2''"
		forvalues i=2/`n_ind' {
			label define ind_label `i' `"`:word `i' of `indicator2''"', add
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
		local indvar2:list all_vars-varlist
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
	
	putexcel (`TitleCell'),  left font("Arial",10,"blue") italic

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
	
