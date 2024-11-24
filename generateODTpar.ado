/* START HELP FILE
title[a command to setup working directory and necessary files and folder for anonymization]

desc[
 {cmd:generateODT} generate multi-dimentional statisticial tables destined to open Data Africa plateform
 or for other potential use.
] 

opt[varlist() list of of variables (domains) over which estimates will be creatd.]
opt[marginlabels() specify the labels of margins of variables in varlist.]
opt[parameter() parameter to be estimated in the domains (total, mean or ratio).]
opt[variable() variable the value of which will be used to generate the specified parameter in 'parameter'.]
opt[conditionals() eliminate tuples (of dimensions in varlist) according to specified conditions.]
opt[indicatorname() a comprehensive and informative label of the indicator generated with variables specified in 'variable'.]
opt[units() units of the parameter generated with variable in 'variable'.]
opt[svySE() units of the parameter generated with variable in 'variable'.]
opt[subpop() {cmd:(}[{varname}] [{it:{help if}}]{cmd:)}}identify a subpopulation]



opt2[varlist() list of of variables (domains) over which estimates will be creatd.]
opt2[marginlabels() specify the labels of margins of variables in varlist.]
opt2[parameter() parameter to be estimated in the domains (total, mean or ratio).]
opt2[variable() variable the value of which will be used to generate the specified parameter in 'parameter'.]
opt2[conditionals() eliminate tuples (of dimensions in varlist) according to specified conditions.]
opt2[indicatorname() a comprehensive and informative label of the indicator generated with variables specified in 'variable'.]
opt2[units() units of the parameter generated with variable in 'variable'.]
opt2[svySE() units of the parameter generated with variable in 'variable'.]
opt2[subpop() {cmd:(}[{varname}] [{it:{help if}}]{cmd:)}}identify a subpopulation	]


example[
 {stata generateODT Region sex ,marginlabels("All households" "Wakanda") param("ratio") var((I3_n/I3_d)) ///
	indicatorname("Women entrepreneurship index") ///
	units("")}
	
	 {stata generateODT Region sex ,marginlabels("All households" "Wakanda") param("mean") var(hh_member) ///
	indicatorname("Average households size") ///
	units("people")}
	
		 {stata generateODT Region sex ,marginlabels("All households" "Wakanda") param("total") var(production) ///
	indicatorname("Crop production") ///
	units("MT")}
 ]
 
 
author[Amsata Niang]
institute[Food and Agriculture Organization of the United Nations FAO]
email[amsata_niang@yahoo.fr]


freetext[

]

references[

]

seealso[

]

END HELP FILE */

*capture program drop generateODTPar
program define generateODTPar
		
	syntax varlist ,MARGINLABels(string asis) PARAMeter(string) VARiable(string asis) ///
	[conditionals(string asis) svySE(string) subpop(string asis) UNITs(string asis) INDICATORname(string asis) ]
	
	
	****************************************************************************
	********************* Checking dependancies*********************************
	****************************************************************************
	cap which elabel
	if _rc {
		display "The elabel package is required. Please install it by running: ssc install elabel"
		exit 1
	}

	cap which tuples
	if _rc {
		display "The tuples package is required. Please install it by running: ssc install elabel"
		exit 1
	}
		
	********************************************************
	*** Control that there is no duplication of variable ***
	********************************************************
	local dup_var: list dups variable
	local size_dup_var: list sizeof dup_var
	if (`size_dup_var'>0) {
		display as error "There are duplicated variables in the option variable(`variable')"
		exit 498 // or any error code you want to return
	}
	***************************************************
	*** Check consistency in the number of elements ***
	***************************************************
	local n_varlist: list sizeof varlist
	local n_marginlabels: list sizeof marginlabels
	local n_variable: list sizeof variable
	
	if (`n_marginlabels'!=`n_varlist') {
		display as error "The options varlist (`n_varlist' elements) and marginlabels (`n_marginlabels' element) should have the same number of elements"
		exit 498 // or any error code you want to return
	}

	**********************************************************			
	*** Checking if there are missing values in dimensions ***
	**********************************************************
	foreach v of local varlist {
		count if missing(`v')
		return list
		if (`r(N)'>0) {
			display as error "The dimension `v' should not contain missing values"
			exit 498 // or any error code you want to return
		}
	}
	
	local n_par: list sizeof parameter
	local par "total mean ratio"
	local input_in_par: list posof `"`parameter'"' in par
	
	if (`n_par'!=1 | `input_in_par'==0) {
		display as error "argument 'parameter(`parameter')' must be either 'parameter(total)', 'parameter(mean)' or 'parameter(ratio)'"
		exit 498 // or any error code you want to return
	}

	*******************************************************
	*** if ratio, check if the specification if correct ***
	*******************************************************
	if ("`parameter'"=="ratio") {
		foreach v of local variable {
			
		local pos_par = strpos("`v'", "(")
		if (`pos_par'==0) {
			display as error "Please enclose the ratio formula between parenthesis like (V1/V2) in `v'" 
			exit 498
			}
			
		local pos_par = strpos("`v'", ")")
		if (`pos_par'==0) {
			display as error "Closing parenthesis missing in `v'"
			exit 498
			}
		*Removing parenthesis
		local var_2 = subinstr("`v'", "(", "", .)
		local var_2 = subinstr("`var_2'", ")", "", .)

		local pos = strpos("`var_2'", "/")
		*control if pos==0: invalid specification
		if (`pos'==0) {
			display as error "Invalid specification in `v' for ratio estimation. '/' missing"
			exit 498
			}
			
		*check if numerator or denominator are in the variable lsit
		local denominator = substr("`var_2'", `pos'+1, .)
		local numerator = substr("`var_2'", 1, `pos'-1)
		cap confirm variable `numerator', exact
		if _rc {
			display as error "variable `numerator' (in `v') not found"
			exit 498
			}
		cap confirm variable `denominator', exact
		if _rc {
			display as error "variable `denominator' (in `v') not found"
			exit 498
			}
		}
		
	}
	
	
tempfile tmp_data_odt
save `tmp_data_odt', replace
global temp_file "`tmp_data_odt'"


parallel, prog(svyParallel)  setparallelid(`parallelid') keep nodata: svyParallel `varlist' `variable' `parameter'
ls __pll*.dta	

*Appending all files

local files: dir . files "__pll_*.dta"
* Step 2: Load the first dataset
use `: word 1 of `files'', clear
* Step 3: Loop through the remaining datasets and append them
foreach file of local files {
    * Skip the first file since it's already loaded
    if "`file'" != "`: word 1 of `files''" {
        append using `file'
    }
}

/*		
	quietly {
	*After the loop on tuples, odp_tab contain the results of all dimention combination
	*Extracting variable labels
	foreach v of local varlist {	
	*Exploring labelsof command would reduce this number of line
	local old_vl: value label `v'
	elabel copy `old_vl' ld_`v' 
	}
	*Adding the value label for the magins of dimensions
	local c: word count `varlist'
	forvalues i=1/`c' {
		if ("`:word `i' of `marginlabels''"!="") {
			cap label list ld_`:word `i' of `varlist''
			return list
			local n_lev=`r(max)'+1
			cap elabel list ld_`:word `i' of `varlist''
			return list 
			local lev `r(values)'
			local ap: list posof `"`n_lev'"' in lev
			
			if (`ap'==0) {
				
			label define ld_`:word `i' of `varlist'' `n_lev' "`:word `i' of `marginlabels''", add
			}
		}
	}	
	tempfile  dolabs
	// store them in a temporary do-file
	label save using `dolabs'
	*Adding dimension combination labels in the sample frequency dataset
	use `sample_n', clear
	run `dolabs'
	local c: word count `varlist'
	forvalues i=1/`c' {
			cap label list ld_`:word `i' of `varlist''
			return list
			local n_lev=`r(max)'
		if (`"`:word `i' of `marginlabels''"'!="") {
			di "TEST ONE `n_lev'"
			gen `:word `i' of `varlist''_bis=int(`:word `i' of `varlist'')
			drop `:word `i' of `varlist''
			
			rename `:word `i' of `varlist''_bis `:word `i' of `varlist''
			replace `:word `i' of `varlist''=`n_lev' if `:word `i' of `varlist''==.
		} 
		else {	
			di "TEST TWO"
			drop if `:word `i' of `varlist''==.
		}
		
		label values `:word `i' of `varlist'' ld_`:word `i' of `varlist''
	}
	save `sample_n', replace
	
	use `odp_tab', clear	
	// get the value labels
	run `dolabs'
	*see https://www.statalist.org/forums/forum/general-stata-discussion/general/251350-how-can-i-apply-value-labels-stored-in-different-dataset-into-my-primary-data
	local c: word count `varlist'
	forvalues i=1/`c' {
		if ("`:word `i' of `marginlabels''"!="") {
			cap label list ld_`:word `i' of `varlist''
			return list
			local n_lev=`r(max)'
			replace `:word `i' of `varlist''= `n_lev' if `:word `i' of `varlist''==.
		} 
		else {
			drop if `:word `i' of `varlist''==.
		}
	}
	
	foreach v of local varlist {
		label values `v' ld_`v'		
	}
	***********************************************
	*** Create IndicatorName and Unit variables ***
	***********************************************
	*correction for ration
		local c: word count `variable'
		
		forvalues i=1/`c' {
			di "`:word `i' of `variable''"
		replace Indicator= "`:word `i' of `variable''" if Indicator=="_ratio_`i'"
		}
		
		
	merge m:1 `varlist' Indicator using `sample_n'
	
	gen Parameter="`parameter'"
	sort Indicator `varlist'
	rename Indicator Variable
	rename sample_n sample_freq
	rename CV coef_variation
	rename se standard_err
	rename ll conf_int_ll
	rename ul conf_int_ul
	rename b Value
	
	* keep only dimensions where frequency exists
	drop if sample_freq==.
	
	order `varlist' Variable Parameter  Value  sample_freq

	******************************************************************************
	****** ADDING units if specicied**********************************************
	******************************************************************************
		local n_units: list sizeof units

	if (`n_units'!=0) {
		if (`n_units'!=`n_variable') {
			display as error "The options units and variable should have the same number of elements"
			exit 498 // or any error code you want to return
		}
				
		gen Unit=""
		forvalues i=1/`c' {
			replace Unit = "`:word `i' of `units''" if Variable=="`:word `i' of `variable''"
		}
			order `varlist' Variable Parameter  Value  Unit sample_freq

	}
	
	*************************Unit***********************************************************
	
	
	***************************************************************************************
	*** Adding indicator label if specified************************************************
	***************************************************************************************
	local n_indicatorname: list sizeof indicatorname
	if (`n_indicatorname'!=0) {
	local c: word count `variable'
	if (`n_indicatorname'!=`n_variable') {
		display as error "The options indicatorname and variable should have the same number of elements"
		exit 498 // or any error code you want to return
	}
				
	gen IndicatorName=""
	local c: word count `variable'
	forvalues i=1/`c' {
		replace IndicatorName = `"`:word `i' of `indicatorname''"' if Variable=="`:word `i' of `variable''"
		*cap replace IndicatorName = ustrregexra( IndicatorName ,`""   '"',"")  //issue de la gestion des apostrophes comme d'une... NB: ne pas mettre " das les labels
		*cap replace IndicatorName = ustrregexra( IndicatorName ,"  '","") //issue de la gestion des apostrophes comme d'une...
	}
			order `varlist' Variable Parameter IndicatorName Value Unit sample_freq
			cap replace IndicatorName = ustrregexra( IndicatorName ,"&","'")


	}
	
	
	} // quietly
	
	********************************************************
	*************** formating indicator for ratio **********
	********************************************************
/*
	if("`parameter'"=="ratio") {
		
		foreach v of local variable {
		local var_2 = subinstr("`v'", "(", "", .)
		local var_2 = subinstr("`var_2'", "_d)", "", .)
		local pos = strpos("`var_2'", "/")
		local denominator = substr("`var_2'", `pos'+1, .)
		local numerator = substr("`var_2'", 1, `pos'-1)
		local numerator = subinstr("`numerator'", "_n", "", .)
		
		if ("`numerator'"=="`denominator'") { // if the ratio formula is in the form (ind2_n/ind2_d)
			replace Indicator="`numerator'" if Indicator== "`v'"
		}
	}

	}
*/

*/
end

*include controle in case of hierarchical geographic variable, indication=> to many zero/missing value in sample frequencies