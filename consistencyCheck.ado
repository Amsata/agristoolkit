
cap program drop consistencyCheck
program define consistencyCheck
		
	syntax [varlist(default=none)] , PARAMeter(string) VARiable(string asis) ///
	[hiergeovars(string asis) MARGINLABels(string asis) conditionals(string asis) svySE(string) ///
	subpop(string asis) UNITs(string asis) INDICATORname(string asis) SETCluster(int 0) equal_lenth(int 0)]
	
	* TO DO
		* take into account subpo
		* take into account vctype is svy
		*take into account conditionals
		*order the different check 
		
		
	local n_geovar: list sizeof hiergeovars
	local n_varlist: list sizeof varlist
	local n_geovarmarginlab: list sizeof geovarmarginlab

	if(`n_geovarmarginlab'!=0 & `n_geovarmarginlab'>1) {
		display as error "The options geovarmarginlab should have on element!"
		exit 498
	}
	
	if (`n_geovar'==1) {
		display as error "geovar should contain at least 2 hierarchical geographic variable!"
		exit 498
	}

	foreach v of local hiergeovars {
		local pos: list posof "`v'" in varlist
		if (`n_geovar'!=0 & `pos'>0) {
			display as error "The variable `v' should be excluded from varlist"
			exit 498
		}
	}
	
	*Control existence of duplicated variable
	local dup_var: list dups variable
	local size_dup_var: list sizeof dup_var
	if (`size_dup_var'>0) {
		display as error "The variable {cmd: `dup_var'} are duplicated in {cmd: `variable'}"
		exit 498 // or any error code you want to return
	}

	* control if a variable exist
	if "`parameter'"!="ratio" {
		foreach v of local variable {
			cap confirm variable `v', exact
				if _rc {
					display as error "variable `v' not found in the data"
					exit 498
					}
		}
	}
	*control if dimension variables are labelled
	if "`varlist'"!="" {
		foreach v of local varlist {
			local lbl: value label `v'
			if "`lbl'" == "" {
				display as error "The dimension variable `v' should be labbelled."
				exit 498
			} 
		}
	}

	if "`hiergeovars'"!="" {
		foreach v of local hiergeovars {
			local lbl: value label `v'
			if "`lbl'" == "" {
				display as error "The dimension variable `v' should be labbelled."
				exit 498
			} 
		}
	}

	****************************************************************************
	********************* Checking dependancies*********************************
	****************************************************************************
	cap which elabel
	if _rc {
		di as error "Error: The elabel package is required. Please install it by running: ssc install elabel"
		exit 1
	}

	cap which tuples
	if _rc {
		di as error "Error: The tuples package is required. Please install it by running: ssc install elabel"
		exit 1
	}
	
	cap which parallel
	if _rc {
		di as error "Error:The parallel package is required. Please install it by running: ssc install elabel"
		exit 1
	}
		
	********************************************************
	*** Control that there is no duplication of variable ***
	********************************************************
	local dup_var: list dups variable
	local size_dup_var: list sizeof dup_var
	if (`size_dup_var'>0) {
		display as error "Error: There are duplicated variables in the option variable(`variable')"
		exit 498 // or any error code you want to return
	}
	***************************************************
	*** Check consistency in the number of elements ***
	***************************************************
	local n_varlist: list sizeof varlist
	local n_marginlabels: list sizeof marginlabels
	local n_variable: list sizeof variable
	local n_geovar: list sizeof hiergeovars

/*	
	if(`n_varlist'==0 & `n_geovar'==0) {
		
		display as error "The options {cmd:varlist} and {cmd:hiergeovars} cannot be both empty!"
		exit 498
	}
*/	
	if (`n_marginlabels'!=`n_varlist') {
		di as error "Error: The options varlist (`n_varlist' elements) and marginlabels (`n_marginlabels' element) should have the same number of elements"
		exit 498 // or any error code you want to return
	}

	**********************************************************			
	*** Checking if there are missing values in dimensions ***
	**********************************************************
	foreach v of local varlist {
		count if missing(`v')
		return list
		if (`r(N)'>0) {
			display as error "Error: The dimension `v' should not contain missing values"
			exit 498 // or any error code you want to return
		}
	}
	
	local n_par: list sizeof parameter
	local par "total mean ratio"
	local input_in_par: list posof `"`parameter'"' in par
	
	if (`n_par'!=1 | `input_in_par'==0) {
		display as error "Error: argument 'parameter(`parameter')' must be either 'parameter(total)', 'parameter(mean)' or 'parameter(ratio)'"
		exit 498 // or any error code you want to return
	}

	*******************************************************
	*** if ratio, check if the specification if correct ***
	*******************************************************
	if ("`parameter'"=="ratio") {
		foreach v of local variable {
		
		
		local pos_par = strpos("`v'", "(")
		if (`pos_par'==0) {
			display as error "Error: Please enclose the ratio formula between parenthesis like (V1/V2) or (nyname:V1/V2) in `v'" 
			exit 498
			}
			
		local pos_par = strpos("`v'", ")")
		if (`pos_par'==0) {
			display as error "Error: Closing parenthesis missing in `v'"
			exit 498
			}
			
		*Removing parenthesis
		local var_2 = subinstr("`v'", "(", "", .)
		local var_2 = subinstr("`var_2'", ")", "", .)
		
		****
		local var_2=substr("`var_2'", strpos("`var_2'", ":") + 1, .)

		local pos = strpos("`var_2'", "/")
		*control if pos==0: invalid specification
		if (`pos'==0) {
			display as error "Error: Invalid specification in `v' for ratio estimation. '/' missing"
			exit 498
			}
			
		*check if numerator or denominator are in the variable lsit
		local denominator = substr("`var_2'", `pos'+1, .)
		local numerator = substr("`var_2'", 1, `pos'-1)
		cap confirm variable `numerator', exact
		if _rc {
			display as error "Error: variable `numerator' (in `v') not found"
			exit 498
			}
		cap confirm variable `denominator', exact
		if _rc {
			display as error "Error: variable `denominator' (in `v') not found"
			exit 498
			}
		}
		
	}

if `equal_lenth'==0 {	
	***************************************************************************************
	*** Adding indicator label if specified************************************************
	***************************************************************************************
	local n_indicatorname: list sizeof indicatorname
	if (`n_indicatorname'!=0) {
		if (`n_indicatorname'!=`n_variable') {
			display as error "Error: The options indicatorname and variable should have the same number of elements"
			exit 498 // or any error code you want to return
		} 				
	}
		
***************************************************************************************
*** Adding indicator label if specified************************************************
***************************************************************************************
	
	local n_units: list sizeof units
	local n_variable: list sizeof variable

	if (`n_units'!=0) {
		if (`n_units'!=`n_variable') {
			display as error "Error: The options units and variable should have the same number of elements"
			exit 498 // or any error code you want to return
		}
	}	
}
		*set cluster if specified
		if(`setcluster'>0) {
		quietly parallel initialize `setcluster'
	} 
	else if (`setcluster'<0) {
		di as error "The number of cluser should not be negative"
		exit 498
	}
		

end

*include controle in case of hierarchical geographic variable, indication=> to many zero/missing value in sample frequencies