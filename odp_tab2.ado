program define odp_tab2, rclass
		
		 **  tablabelvar(varlist) indvar(varlist)
		*syntax [varlist(default=none)] [if], [  tabtitle(string asis) outfile(string) indicator(string asis) indicatorname(varlist) indvar(varlist) value(varlist)]
	syntax [varlist(default=none)] [if] , [tabtitle(string asis) outfile(string) indicator(string) indvar(varlist) value(varlist) by(varlist) rowtotal(string) decimal(string asis) indicatorname(varlist)]

	



	if ("`indvar'"=="") local indvar "Variable"
	if ("`indicatorname'"=="") local indicatorname "IndicatorName"
	if ("`value'"=="") local value "Value_str"
	
	**start message 
	preserve
	qui if "`if'"!="" keep `if'
	qui keep if `indvar'=="`indicator'"
	qui levelsof(`indicatorname'),local(ind_name)
	if ("`tabtitle'"=="") di as result `"Generating table: {cmd:`ind_name'}..."'
	else di as result `"Generating table: {cmd:`tabtitle'}..."'
	restore

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
		
quietly {

	******
local alphabet "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
putexcel set "`path'", modify sheet("`sheet_name'")  

preserve
local TitleCell_num=`cell_start_num'
local TabTitleCell_num=`TitleCell_num'+1
local TitleCell="A`TitleCell_num'"
local TabTitleCell="A`TabTitleCell_num'"

if "`if'"!="" keep `if'
keep if `indvar'=="`indicator'"
keep `varlist' `by'

cap isid `varlist' `by'

if _rc {
		di as error "Error: `varlist' and `by' do not uniquely identify row in the dataset of the given subset specify in '`if'' !"
		exit 1
	}

gen sp=`by'

reshape wide `by', i(`varlist') j(sp) 


foreach v of local varlist {
tostring  `v',gen(`v'_bis)
drop `v' 
 ren `v'_bis `v'
replace `v'="`v'"
}

keep if _n==1

if ("`rowtotal'"!="") gen Total= "`rowtotal'"

local end_num=`TabTitleCell_num'+1
local cell_end "A`end_num'"
if (`cell_start_num'==1) export excel using "`path'",  sheet("`sheet_name'", replace)  cell(`TabTitleCell')
else export excel using "`path'",  sheet("`sheet_name'", modify)  cell(`TabTitleCell')

qui describe
local EndTabTitleCell="`:word `r(k)' of `alphabet''`TabTitleCell_num'"
putexcel (`TabTitleCell':`EndTabTitleCell'), border(all, thin) bold font("Arial",10)  vcenter txtwrap

restore

preserve
if "`if'"!="" keep `if'
keep if `indvar'=="`indicator'"
levelsof(`indicatorname'),local(ind_name)

keep `varlist' `by' `value'

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


reshape wide `value', i(`varlist') j(`by') 


if ("`rowtotal'"!="") {
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
	*return list
	egen Total=rowtotal(`r(varlist)')
	ds addd_*
	drop `r(varlist)'
}

unab all_vars: *
local indvar2:list all_vars-varlist
if ("`decimal'"!="") {

	foreach v of local indvar2 {
	replace `v' = subinstr(`v', ".", "`decimal'", .)
	}
}

export excel using  "`path'", sheet("`sheet_name'", modify) cell(`cell_end')

if ("`tabtitle'"=="") putexcel `TitleCell' = `ind_name'
else putexcel `TitleCell' = `tabtitle'


qui count 
local TabCellEnd_num=`r(N)'+`end_num'-1
local TabCellEnd= "A`TabCellEnd_num'"

qui describe
local EndTabCell="`:word `r(k)' of `alphabet''`TabCellEnd_num'"

putexcel (`TabCellEnd':`EndTabCell'), border(top, thin) bold font("Arial",10)
putexcel (`TabCellEnd':`EndTabCell'), border(bottom, thin) 
putexcel (`TabTitleCell':`TabCellEnd'), border(right, thin) bold font("Arial",10)
putexcel (`EndTabTitleCell':`EndTabCell'), border(right, thin) font("Arial",10)
putexcel (`TabTitleCell':`EndTabCell'),  hcenter vcenter
putexcel (`cell_end':`EndTabCell'),  nformat(number_d2) font("Arial",9) right
putexcel (`TabTitleCell':`TabCellEnd'),  left
putexcel (`TitleCell'),  left font("Arial",10,"blue") italic

************ Masked cells footnote
	local maskedCellNote_cell_num=`TabCellEnd_num'+1
	local empy_cell_meta="A`maskedCellNote_cell_num'"
	local maskedCellNote="Percentage of masked cells: `per_masked_cells'%"
	putexcel `empy_cell_meta' = "`maskedCellNote'"
	putexcel (`empy_cell_meta'),  left font("Arial",9,"red") italic

	**************** Zero cells footnote
	local zeroCellNote_cell_num=`TabCellEnd_num'+2
	local zero_cell_meta="A`zeroCellNote_cell_num'"
	local zeroCellNote="Percentage of cells with value zero(0): `per_zero_cells'%"
	putexcel `zero_cell_meta' = "`zeroCellNote'"
	putexcel (`zero_cell_meta'),  left font("Arial",9,"red") italic
	
restore
}
return local cellEnd `TabCellEnd_num'+4
end
	