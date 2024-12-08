
cap program drop consistencyCheck
program define consistencyCheck
		
	syntax [varlist(default=none)] , PARAMeter(string) VARiable(string asis) ///
	[hiergeovars(string asis) MARGINLABels(string asis) conditionals(string asis) svySE(string) subpop(string asis) UNITs(string asis) INDICATORname(string asis) SETCluster(int 0)]
	
	* TO DO
		* take into account subpo
		* take into account vctype is svy
		*take into account conditionals
		*control existence of variable in case ratio is specify like rat:var1/var2	


**detecting ' in indicator names		

foreach ind of local indicatorname {
	
local pos = strpos("`ind'", "'")
if (`pos'!=0) {	
	local userInput = subinstr("`ind'", "'", "&", .)
	display as error "Error: Aspostrophe ({cmd:'}) in indicator name ({cmd:`ind'}) can cause computation issues" 
	di as error "We suggest replacing them by {cmd:&} and the final result we will replace {cmd:&} by {cmd:'}" _newline
	di as error "your imput should be '{result:`userInput'}' and the output without your intervention will be {result:'`ind''} " _newline
	exit 498
	* https://www.stata.com/statalist/archive/2012-08/msg00924.html
	*explore answers here to solve the apostrophe issue
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

	
	if(`n_varlist'==0 & `n_geovar'==0) {
		
		display as error "The options {cmd:varlist} and {cmd:hiergeovars} cannot be both empty!"
		exit 498
	}
	
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
			display as error "Error: Please enclose the ratio formula between parenthesis like (V1/V2) in `v'" 
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
	

end

*include controle in case of hierarchical geographic variable, indication=> to many zero/missing value in sample frequencies