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

cap program drop extract_macro_elements
program define extract_macro_elements, rclass
    args mymac start_elem end_elem

    // Convert macro to a list
    tokenize `"`mymac'"'

    local collect ""
    local inside = 0  // Flag to start collecting elements

    forvalues i = 1/`=_N' {
        if "``i''" == "`start_elem'" {
            local inside = 1  // Start collecting
        }
        if `inside' {
            local collect "`collect' ``i''"
        }
        if "``i''" == "`end_elem'" {
            continue, break  // Stop exactly at the end element
        }
    }

    return local subset `"`collect'"'
end

cap program drop expand_varlist
program define expand_varlist, rclass
    args varlist

    local expanded_list ""

    foreach word in `varlist' {
        // Check if the word contains a range (indicated by "-")
        if regexm("`word'", "^-|-$") == 0 & strpos("`word'", "-") {
            local start_var = substr("`word'", 1, strpos("`word'", "-") - 1)
            local end_var = substr("`word'", strpos("`word'", "-") + 1, .)
            
            local temp_list ""
            local found = 0
            foreach var of varlist * {
                if "`var'" == "`start_var'" {
                    local found = 1
                }
                if `found' {
                    local temp_list "`temp_list' `var'"
                }
                if "`var'" == "`end_var'" {
                    continue, break
                }
            }
            local expanded_list "`expanded_list' `temp_list'"
        }
        else {
            local expanded_list "`expanded_list' `word'"
        }
    }

    return local expanded "`expanded_list'"
end

cap program drop opendata
program define opendata
		
	syntax [varlist(default=none)] , [ mean(string asis) total(string asis) ratio(string asis) marginlabels(string asis) hiergeovars(string asis) ///
	geovarmarginlab(string asis) conditionals(string asis) svySE(string) subpop(string asis) UNITs(string asis) INDICATORname(string asis) setcluster(integer 0)]
		
	local n_mean: list sizeof mean
	local n_total: list sizeof total
	local n_ratio: list sizeof ratio
	local n_indicatorname: list sizeof indicatorname
	local n_unit: list sizeof units
	
	qui expand_varlist "`mean'"
	local mean `r(expanded)'
	
	qui expand_varlist "`total'"
	local total `r(expanded)'
	

	if (`n_mean'==0 & `n_total'==0 & `n_ratio'==0) {
		display as error "The options {cmd: mean}, {cmd:total} and {cmd: ratio} cannot be all empty."
		exit 480
	}
	
	local all_variable "`mean' `total' `ratio'"
	
		if (`n_indicatorname'!=0) {
			foreach ind of local indicatorname {
				local pos=strpos("`ind'", "@")
				if `pos'>0 {
					local varname=substr("`ind'", 1, strpos("`ind'", "@") - 1)
					*verifier si la variable est dans la list des variable a estimer
					local pos_var=strpos("`all_variable'","`varname'")
					if `pos'==1 {
						display as error "error in '{cmd:`ind'}': Please put the variable name before {cmd:@}" _newline 
						display as error "The indicator name should be specified as followed: {cmd: 'variableName@title of the indicator'} "
						exit 480
					}
					else if `pos_var'==0 {
						display as error "Eerror in '{cmd:`ind'}': {cmd: `varname'} is not a valid variable name" _newline 
						display as error "The indicator name should be specified as followed: {cmd: 'variableName@title of the indicator'} "
						exit 480
					}
				}
				else {		
					display as error " '{cmd: @}' is missing in the indicator name specification" _newline 
					display as error "The indicator name should be specified as followed: {cmd: 'variableName@title of the indicator'} "
					exit 480
				}
			}			
		}


		if (`n_unit'!=0) {
		foreach ind of local units {
			local pos=strpos("`ind'", "@")
			if `pos'>0 {
				local varname=substr("`ind'", 1, strpos("`ind'", "@") - 1)
				*verifier si la variable est dans la list des variable a estimer
				local pos_var=strpos("`all_variable'","`varname'")
				
				if `pos'==1 {
					display as error "error in '{cmd: `ind'}' : Please put a variable name before {cmd:@}" _newline 
					display as error "The unit should be specified as followed: {cmd: 'variableName@unit'} "
					exit 480
				}
				else if `pos_var'==0 {				
					local detect_minus=strpos("`varname'", "-")
					if `detect_minus'>0 {
						local var_before=substr("`varname'", 1, `detect_minus' - 1)
						local var_after=substr("`varname'", `detect_minus' + 1,.)
						local pos_var_b=strpos("`all_variable'","`var_before'")
						local pos_var_a=strpos("`all_variable'","`var_after'")
						if `pos_var_b'==0 {
							display as error "error in '{cmd: `ind'}': {cmd: `var_before'} is not a valid variable name" _newline 
							display as error "The unit should be specified as followed: {cmd: 'var1-var2@unit'} "
							exit 480
						}
					
					    if `pos_var_a'==0 {
							display as error "error in '{cmd: `ind'}': {cmd: `var_after'} is not a valid variable name" _newline 
							display as error "The unit should be specified as followed: {cmd: 'var1-var2@unit'} "
							exit 480
						}

					}
					else {
						display as error "error in '{cmd: `ind'}': {cmd: `varname'} is not a valid variable name" _newline 
						display as error "The unit should be specified as followed: {cmd: 'variableName@unit'} "
						exit 480
					}
				}
			}
			else {		
				display as error " error in '{cmd: `ind'}': {cmd: @} is missing in the unit name specification" _newline 
					display as error "The unit should be specified as followed: {cmd: 'variableName@unit'} "
				exit 480
			}
		}			
	}
	
	
	
	if `n_mean'>0 {	
		quietly consistencyCheck `varlist' , marginlabels(`marginlabels') param("mean") hiergeovars(`hiergeovars') ///
		var(`mean') conditionals(`conditionals') indicator(`indicatorname') units(`units') setcluster(`setcluster') equal_lenth(1)
	}

	if `n_total'>0 {
		quietly consistencyCheck `varlist' , marginlabels(`marginlabels') param("total") hiergeovars(`hiergeovars') ///
		var(`total') conditionals(`conditionals') indicator(`indicatorname') units(`units') setcluster(`setcluster') equal_lenth(1)
	}

	if `n_ratio'>0 {
		quietly consistencyCheck `varlist' , marginlabels(`marginlabels') param("ratio") hiergeovars(`hiergeovars') ///
		var(`ratio') conditionals(`conditionals') indicator(`indicatorname') units(`units') setcluster(`setcluster') equal_lenth(1)
	}
	
tempfile opendata_dst

	if `n_mean'>0 {
		preserve
		generateOpenDataTable `varlist', parameter("mean") variable(`mean') marginlabels(`marginlabels') hiergeovars(`hiergeovars') ///
		geovarmarginlab(`geovarmarginlab') conditionals(`conditionals') svySE(`svySE') subpop(`subpop') setcluster(`setcluster')
		save `opendata_dst', replace
		restore
	}
	
	if `n_total'>0 {
		preserve
		generateOpenDataTable `varlist', parameter("total") variable(`total') marginlabels(`marginlabels') hiergeovars(`hiergeovars') ///
		geovarmarginlab(`geovarmarginlab') conditionals(`conditionals') svySE(`svySE') subpop(`subpop') setcluster(`setcluster')
		capture append using `opendata_dst'
		save `opendata_dst', replace
		restore
	}	
		
	if `n_ratio'>0 {
		preserve
		generateOpenDataTable `varlist', parameter("ratio") variable(`ratio') marginlabels(`marginlabels') hiergeovars(`hiergeovars') ///
		geovarmarginlab(`geovarmarginlab') conditionals(`conditionals') svySE(`svySE') subpop(`subpop') setcluster(`setcluster')
		capture append using `opendata_dst'
		save `opendata_dst', replace
		restore
	}
	
	use `opendata_dst', clear
	
	
		if (`n_indicatorname'!=0) {
			gen IndicatorName=""
			foreach ind of local indicatorname {
				local pos=strpos("`ind'", "@")
				local varname=substr("`ind'", 1, strpos("`ind'", "@") - 1)
				qui replace IndicatorName="`ind'" if Variable=="`varname'"
				qui replace IndicatorName = substr(IndicatorName, strpos(IndicatorName, "@") + 1, .)
				qui replace IndicatorName = ustrregexra( IndicatorName ,"&","'")
			}			
		}

		if (`n_unit'!=0) {
			gen Unit=""
			foreach ind of local units {
				local pos=strpos("`ind'", "@")
				local varname=substr("`ind'", 1, strpos("`ind'", "@") - 1)
				local detect_minus=strpos("`varname'", "-")
				if `detect_minus'==0 {
					qui replace Unit="`ind'" if Variable=="`varname'"
					qui replace Unit="`ind'" if Variable=="`varname'"
				}
				else {
					local var_before=substr("`varname'", 1, `detect_minus' - 1)
					local var_after=substr("`varname'", `detect_minus' + 1,.)			
					extract_macro_elements "`all_variable'" "`var_before'" "`var_after'"
					local vars_in "`r(subset)'"
					foreach v of local vars_in {
						qui replace Unit="`ind'" if Variable=="`v'"
						qui replace Unit="`ind'" if Variable=="`v'"
					}
				}
			}
			qui replace Unit = substr(Unit, strpos(Unit, "@") + 1, .)
		}
		
		
		***some adjustment for ratio
		
		qui gen position=strpos(Variable, ":")
		qui replace Variable = substr(Variable, 1,strpos(Variable, ":")- 1) if position>0
		qui replace Variable = substr(Variable, strpos(Variable, "(") + 1, .) if position>0
		drop position

	****************************************************************************
	******************LABEL INDICATOR AND UNITS IF PROVIDED*********************
	****************************************************************************
	
end

