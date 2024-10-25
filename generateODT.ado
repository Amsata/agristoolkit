/* START HELP FILE
title[a command to setup working directory and necessary files and folder for anonymization]

desc[
 {cmd:setup_anonymization} generate folders, excel files for variables classification and dataset
 description, pre-populated scripts and sample reports for anonymization and information loss analysis.
] 

opt[varlist() list of of variables (domains) over which estimates will be creatd.]
opt[dimcomb() specify the labels of margins of variables in varlist.]
opt[parameter() parameter to be estimated in the domains (total, mean or ratio).]
opt[variable() variable the value of which will be used to generate the specified parameter in 'parameter'.]
opt[labind() a comprehensive and informative label of the indicator generated with variables specified in 'variable'.]
opt[units() units of the parameter generated with variable in 'variable'.]


opt[varlist() list of of variables (domains) over which estimates will be creatd.]
opt[dimcomb() specify the labels of margins of variables in varlist.]
opt[parameter() parameter to be estimated in the domains (total, mean or ratio).]
opt[variable() variable the value of which will be used to generate the specified parameter in 'parameter'.]
opt[labind() a comprehensive and informative label of the indicator generated with variables specified in 'variable'.]
opt[units() units of the parameter generated with variable in 'variable'.]


example[
 {stata sgenODT Element Area ,dimcomb("All households" "Uganda") param("ratio") var((I3_n/I3_d)) ///
	labind("Pourcentage of households") ///
	units("%")}
 ]
 
 
author[Amsata Niang]
institute[Food and Agriculture Organization of the United Nations FAO]
email[amsata_niang@yahoo.fr]


freetext[
This function is a wrap up of the function 'CreateAgrisvy' and 'setup_anonymization' (combined in one in Stata) from the R package 'agrisvyr'.
]

references[

]

seealso[

]

END HELP FILE */

capture program drop generateODT
program define generateODT
		
	syntax varlist ,dimcomb(string asis) PARAMeter(string) VARiable(string asis) LABind(string asis) UNITs(string asis)
		
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
	local n_dimcomb: list sizeof dimcomb
	local n_variable: list sizeof variable
	local n_labind: list sizeof labind
	local n_units: list sizeof units
	
	if (`n_dimcomb'!=`n_varlist') {
		display as error "The options varlist and dimcomb should have the same number of elements"
		exit 498 // or any error code you want to return
	}

	if (`n_labind'!=`n_variable') {
		display as error "The options labind and variable should have the same number of elements"
		exit 498 // or any error code you want to return
	}

	if (`n_units'!=`n_variable') {
		display as error "The options units and variable should have the same number of elements"
		exit 498 // or any error code you want to return
	}

	**********************************************************			
	*** Checking if there are missing values in dimensions ***
	**********************************************************
	foreach v of local varlist {
		count if missing(`v')
		quietly return list
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
	tempfile odp_tab
	tempfile sample_n

	*******************************************************************************
	**** Generate estimate for all the combination ********************************
	*******************************************************************************
	quietly svy: `parameter' `variable'
	qui return list
	matrix define T= r(table)'	
	preserve
	mat_to_ds T		   
	tempfile res_estimation
	save `res_estimation', replace
	* Estimating coefficient of variation
	quietly estat cv
	matrix define CV = r(cv)'
	mat_to_ds CV
	*renaming the variable to CV
	unab all_vars: *
	rename `:word 1 of `all_vars'' CV // or word(`all_vars', 1)
	merge 1:1 rownames using `res_estimation', nogen
	split rownames, p(@)
	rename rownames1 Indicator
	drop rownames
	save `odp_tab', replace
	restore
	****************En generate estimates for all combination *********************
		   
	tuples `varlist'  // for looping over all dimensions
	scalar init_2=0   //to manage fist saving and append
	gen freq=1 		  // used to count sample frequency where a given variable is non-missing temporary variable may be better
	*Sample frequency for all observation
	foreach v of local variable {
	preserve
	if ("`parameter'"=="ratio") {
		local var_2 = subinstr("`v'", "(", "", .)
		local var_2 = subinstr("`var_2'", ")", "", .)
		local pos = strpos("`var_2'", "/")
		local denominator = substr("`var_2'", `pos'+1, .)
		local numerator = substr("`var_2'", 1, `pos'-1)
		gen sample_n= cond(freq==1 & !missing(`numerator') & !missing(`denominator'),1,0)
	}
	else {
		gen sample_n= cond(freq==1 & !missing(`v'),1,0)
	}
	collapse (sum) sample_n
	gen Indicator="`v'"	
	* First saving or appending the main results dataset: sample_n
	if (init_2==0) {
		save `sample_n', replace
		scalar init_2=1
	} 
	else {
		append using `sample_n',force
		save `sample_n', replace
		}
	restore
	}
	
						
	tuples `varlist'  // for looping over all dimensions
	forvalues i=1/`ntuples' {
		di "Generating estimation for dimension combination : `tuple`i''"
		local tuple "`tuple`i''" // the content of `tuple`i'' is lost in the process, this is a backup
		
		************************************************************************
		*****check if there are hierarchical structure between 2 variables******
		************************************************************************
		local tuple_size: list sizeof tuple
		
		if(`tuple_size'==2) {
			quietly asdoc table `tuple', replace
			quietly matlist st_mat_main
           
		   // Get dimensions of the matrix
			local rows = rowsof(st_mat_main)
			local cols = colsof(st_mat_main)
			// Loop through each element of the matrix
			forvalues i = 1/`rows' {
				forvalues j = 1/`cols' {
					// Check if the element is missing
					if missing(st_mat_main[`i', `j']) {
						// Replace with zero
						matrix st_mat_main[`i', `j'] = 0
					}
				}
			}
			
			// Initialize a vector to store counts
			matrix counts = J(1, `cols', 0)

			// Loop through each column to count non-zero entries
			forvalues j = 1/`cols' {
				local count = 0
				forvalues i = 1/`rows' {
					if st_mat_main[`i', `j']!= 0 {
						local count = `count' + 1
					}
				}
			
				matrix counts[1, `j'] = `count'
			}
			
			
			local total_sum = 0
			forvalues i = 1/`=rowsof(counts)' {
				forvalues j = 1/`=colsof(counts)' {
					local total_sum = `total_sum' + counts[`i', `j']
				}
			}
			
			
			if(`total_sum'==`cols') {
				display as error " DImension `tuple' seem to be hierarchic. please use generateODTbyGeo"
				exit 498
			}
			
		** faire pour rowwise
		matrix st_mat_main_t=st_mat_main'
		local rows = rowsof(st_mat_main_t)
			local cols = colsof(st_mat_main_t)
			// Initialize a vector to store counts
			matrix counts = J(1, `cols', 0)

			// Loop through each column to count non-zero entries
			forvalues j = 1/`cols' {
				local count = 0
				forvalues i = 1/`rows' {
					if st_mat_main_t[`i', `j']!= 0 {
						local count = `count' + 1
					}
				}
			
				matrix counts[1, `j'] = `count'
			}
			
				local total_sum = 0
			forvalues i = 1/`=rowsof(counts)' {
				forvalues j = 1/`=colsof(counts)' {
					local total_sum = `total_sum' + A[`i', `j']
				}
			}
			
			if(`total_sum'==`cols') {
				display as error " DImension `tuple' seem to be hierarchic. please use generateODTbyGeo"
				exit 498
			}
			
			
		}
		
		
		***********************************************************************
		*** Generate sample frequency where a given variable is non-missing ***
		***********************************************************************
		foreach v of local variable {
			preserve
		if ("`parameter'"=="ratio") {
			local var_2 = subinstr("`v'", "(", "", .)
			local var_2 = subinstr("`var_2'", ")", "", .)
			local pos = strpos("`var_2'", "/")
			local denominator = substr("`var_2'", `pos'+1, .)
			local numerator = substr("`var_2'", 1, `pos'-1)
			quietly gen sample_n= cond(freq==1 & !missing(`numerator',`denominator'),1,0)
		}
		else {
			quietly gen sample_n= cond(freq==1 & !missing(`v'),1,0)
		}
			collapse (sum) sample_n , by(`tuple`i'')
			gen Indicator="`v'"
			
			* First saving or appending the main results dataset: sample_n
			if (init_2==0) {
				quietly save `sample_n', replace
				quietly scalar init_2=1
			} 
			else {
				quietly append using `sample_n',force
				quietly save `sample_n', replace
			}
			restore
		}
		
		
		************************************************************************
		*** Generate estimate over dimension the given dimension combination ***
		************************************************************************
		quietly svy, over(`tuple`i''): `parameter' `variable'
		qui return list
		matrix define T= r(table)'	
		preserve
		mat_to_ds T		   
		di as error "TESTTTTERRRRRRRRRRRR"
		tempfile res_estimation
		quietly save `res_estimation', replace
		*Estimating coefficient of variation
		quietly estat cv
		matrix define CV = r(cv)'
		mat_to_ds CV	   
		unab all_vars: *
		rename `:word 1 of `all_vars'' CV // or word(`all_vars', 1)	
		merge 1:1 rownames using `res_estimation', nogen
		
		*break 498
		**************************************************************************
		*** Extract correct dimension name and merging with sample frequencies (possible from Stata 17 ***
		**************************************************************************
		quietly split rownames, p(@)
		rename rownames1 Indicator
		quietly replace Indicator= regexr(Indicator, "^c.", "")
		rename rownames2 dimension
		quietly split dimension, p(#)
		local c : word count `tuple'
		forvalues i=1/`c' {
			local v "`:word `i' of `tuple''"
			rename dimension`i' `v'
			quietly replace `v'= ustrregexra(`v',".`v'","")
			quietly replace `v'= ustrregexra(`v',"bn","")
			destring `v', replace
		}
		drop rownames dimension
		append using `odp_tab', force
		save `odp_tab', replace
		restore // restore the iniial dataset for the continuation of the loop on tuples
	}	
		
	
	
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
		if ("`:word `i' of `dimcomb''"!="") {
			quietly cap label list ld_`:word `i' of `varlist''
			quietly return list
			local n_lev=`r(max)'+1
			cap elabel list ld_`:word `i' of `varlist''
			return list 
			local lev `r(values)'
			local ap: list posof `"`n_lev'"' in lev
			
			if (`ap'==0) {
				
			label define ld_`:word `i' of `varlist'' `n_lev' "`:word `i' of `dimcomb''", add
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
			quietly cap label list ld_`:word `i' of `varlist''
			quietly return list
			local n_lev=`r(max)'
		if ("`:word `i' of `dimcomb''"!="") {
			di "TEST ONE `n_lev'"
			quietly gen `:word `i' of `varlist''_bis=int(`:word `i' of `varlist'')
			drop `:word `i' of `varlist''
			
			rename `:word `i' of `varlist''_bis `:word `i' of `varlist''
			quietly replace `:word `i' of `varlist''=`n_lev' if `:word `i' of `varlist''==.
		} 
		else {	
			di "TEST TWO"
			drop if `:word `i' of `varlist''==.
		}
		
		label values `:word `i' of `varlist'' ld_`:word `i' of `varlist''
	}
	save `sample_n', replace
	
	use `odp_tab',clear	
	// get the value labels
	run `dolabs'
	*see https://www.statalist.org/forums/forum/general-stata-discussion/general/251350-how-can-i-apply-value-labels-stored-in-different-dataset-into-my-primary-data
	local c: word count `varlist'
	forvalues i=1/`c' {
		if ("`:word `i' of `dimcomb''"!="") {
			quietly cap label list ld_`:word `i' of `varlist''
			quietly return list
			local n_lev=`r(max)'
			quietly replace `:word `i' of `varlist''= `n_lev' if `:word `i' of `varlist''==.
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
		quietly replace Indicator= "`:word `i' of `variable''" if Indicator=="_ratio_`i'"
		}
		
	gen IndicatorName=""
	gen Unit=""
	local c : word count `variable'
	forvalues i=1/`c' {
		quietly replace IndicatorName = "`:word `i' of `labind''" if Indicator=="`:word `i' of `variable''"
	}
	forvalues i=1/`c' {
		quietly replace Unit = "`:word `i' of `units''" if Indicator=="`:word `i' of `variable''"
	}
	

	merge m:1 `varlist' Indicator using `sample_n'
	order `varlist' Indicator IndicatorName b Unit sample_n
	sort Indicator `varlist'
	
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
			quietly replace Indicator="`numerator'" if Indicator== "`v'"
		}
	}

	}
	
*/	

end

*include controle in case of hierarchical geographic variable, indication=> to many zero/missing value in sample frequencies