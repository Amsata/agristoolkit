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

*cap program drop opendata
program define genmdt
		
	syntax [varlist(default=none)] , [ mean(string asis) total(string asis) ratio(string asis) MARGINlabels(string asis) HIERGEOvars(string asis) ///
	GEOMARGINlabel(string) CONDitionals(string asis) svySE(string) subpop(string asis) UNITs(string asis) INDICATORname(string asis) setcluster(integer 0)]
		
		
	* For ratio specified ad ( (rat1:VI/VE)  (rat2:VI/V2)  (rat3:VI/V3) (rat4:VI/V4)), allow unit specification like 'rat1-rat4@unit' instead of "(rat1:VI/VE)-(rat4:VI/V4)@unit"
	*utiliser la specification "Var@marginlabel" pour l'option marginlabel.
	*Ajouter du versioning dans la package github

	local n_mean: list sizeof mean
	local n_total: list sizeof total
	local n_ratio: list sizeof ratio
	local n_indicatorname: list sizeof indicatorname
	local n_unit: list sizeof units
	local n_geovars: list sizeof hiergeovars

	*******creating unique variable label for geovars
	
if(`n_geovars'>0) {

	quietly{
		local old_vl: value label `:word 1 of `hiergeovars''
		elabel copy `old_vl' labels_geovars
		qui elabel list labels_geovars
		local max_val=`r(max)'

		foreach v of local hiergeovars {
			if("`v'" != "`:word 1 of `hiergeovars''") {
				local old_vl: value label `v'
				elabel copy `old_vl' `v'_labels
				qui elabel list `v'_labels
				local valeur="`r(values)'"
				local text=`"`r(labels)'"'
				local len_label=`r(k)'
				local max_final=cond(`max_val'>`r(max)',`max_val',`r(max)')

				di "`len_label'"
				forvalues i=1/`len_label' {
					local j=`max_final'+`:word `i' of `valeur''
					di "max=`max_val' :i=`:word `i' of `valeur'' :j=`j'"
					qui recode `v' `:word `i' of `valeur''=`j'
					label define labels_geovars `j' `"`:word `i' of `text''"',add
					}
				
				label val `v' labels_geovars
			}
		}
	}
}

	
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
					local pos_var: list posof "`varname'" in all_variable
					if `pos'==1 {
						display as error "error in '{cmd:`ind'}': Please put the variable name before {cmd:@}" _newline 
						display as error "The indicator name should be specified as followed: {cmd: 'variableName@title of the indicator'} "
						exit 480
					}
					else if `pos_var'==0 {
						extract_before_colon "`all_variable'"
						local res_before_colon "`r(extracted)'"
					    local pos_var: list posof "`varname'" in res_before_colon

						if `pos_var'==0 {
						display as error "Eerror in '{cmd:`ind'}': {cmd: `varname'} is not a valid variable name" _newline 
						display as error "The indicator name should be specified as followed: {cmd: 'variableName@title of the indicator'} "
						exit 480
						}
					}
				}
				else {		
					display as error "Eerror in '{cmd:`ind'}': '{cmd: @}' is missing in the indicator name specification" _newline 
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
				local pos_var: list posof "`varname'" in all_variable
				
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
						local pos_var_b:list posof "`var_before'" in all_variable
						local pos_var_a:list posof "`var_after'" in all_variable
						if `pos_var_b'==0 {
							extract_before_colon "`all_variable'"
							local res_before_colon "`r(extracted)'"
							local pos_var_b2: list posof "`var_before'" in res_before_colon
							if `pos_var_b2'==0 {
							display as error "error in '{cmd: `ind'}': {cmd: `var_before'} is not a valid variable name" _newline 
							display as error "The unit should be specified as followed: {cmd: 'var1-var2@unit'} "
							exit 480
							}
						}
					
					    if `pos_var_a'==0 {
							extract_before_colon "`all_variable'"
							local res_before_colon "`r(extracted)'"
							local pos_var_a2: list posof "`var_after'" in res_before_colon
							if `pos_var_a2'==0 {
								display as error "error in '{cmd: `ind'}': {cmd: `var_after'} is not a valid variable name" _newline 
								display as error "The unit should be specified as followed: {cmd: 'var1-var2@unit'} "
								exit 480
							}
						}

					}
					else {
						extract_before_colon "`all_variable'"
						local res_before_colon "`r(extracted)'"
					    local pos_var: list posof "`varname'" in res_before_colon

						if `pos_var'==0 {
							display as error "Eerror in '{cmd:`ind'}': {cmd: `varname'} is not a valid variable name" _newline 
							display as error "The indicator name should be specified as followed: {cmd: 'variableName@title of the indicator'} "
							exit 480
						}
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
	

local mean_bis

	foreach v of local mean {
		quietly summarize `v'
		* if the number of nonmissing obs > 0, keep it
		if r(N) > 0 {
			local mean_bis `mean_bis' `v'
		}
	}
	
	
	if `n_mean'>0 {	
		quietly consistencyCheck `varlist' , marginlabels(`marginlabels') param("mean") hiergeovars(`hiergeovars') ///
		var(`mean_bis') conditionals(`conditionals') setcluster(`setcluster') 
	}

	
local total_bis

	foreach v of local total {
		quietly summarize `v'
		* if the number of nonmissing obs > 0, keep it
		if r(N) > 0 {
			local total_bis `total_bis' `v'
		}
	}
	
	if `n_total'>0 {
		quietly consistencyCheck `varlist' , marginlabels(`marginlabels') param("total") hiergeovars(`hiergeovars') ///
		var(`total_bis') conditionals(`conditionals') setcluster(`setcluster') 
	}

	if `n_ratio'>0 {
		quietly consistencyCheck `varlist' , marginlabels(`marginlabels') param("ratio") hiergeovars(`hiergeovars') ///
		var(`ratio') conditionals(`conditionals') setcluster(`setcluster') 
	}
	
tempfile opendata_dst

	if `n_mean'>0 {
		preserve
		genMDTbyParam `varlist', parameter("mean") variable(`mean_bis') marginlabels(`marginlabels') hiergeovars(`hiergeovars') ///
		geomarginlabel(`geomarginlabel') conditionals(`conditionals') svySE(`svySE') subpop(`subpop') setcluster(`setcluster')
		save `opendata_dst', replace
		restore
	}
	
	if `n_total'>0 {
		preserve
		genMDTbyParam `varlist', parameter("total") variable(`total_bis') marginlabels(`marginlabels') hiergeovars(`hiergeovars') ///
		geomarginlabel(`geomarginlabel') conditionals(`conditionals') svySE(`svySE') subpop(`subpop') setcluster(`setcluster')
		capture append using `opendata_dst'
		save `opendata_dst', replace
		restore
	}	
		
	if `n_ratio'>0 {
		preserve
		genMDTbyParam `varlist', parameter("ratio") variable(`ratio') marginlabels(`marginlabels') hiergeovars(`hiergeovars') ///
		geomarginlabel(`geomarginlabel') conditionals(`conditionals') svySE(`svySE') subpop(`subpop') setcluster(`setcluster')
		capture append using `opendata_dst'
		save `opendata_dst', replace
		restore
	}
	
	use `opendata_dst', clear
	
	
		***some adjustment for ratio
		
		qui gen position=strpos(Variable, ":")
		qui replace Variable = substr(Variable, 1,strpos(Variable, ":")- 1) if position>0
		qui replace Variable = substr(Variable, strpos(Variable, "(") + 1, .) if position>0
		drop position
		
		
		if (`n_indicatorname'!=0) {
			gen IndicatorName=""
			foreach ind of local indicatorname {
				local pos=strpos("`ind'", "@")
				local varname=substr("`ind'", 1, strpos("`ind'", "@") - 1)
				qui replace IndicatorName="`ind'" if Variable=="`varname'"
				qui replace IndicatorName = substr(IndicatorName, strpos(IndicatorName, "@") + 1, .)
				qui replace IndicatorName = subinstr(IndicatorName, "***", " ", .)
				qui replace IndicatorName = subinstr(IndicatorName, "&&&", "'", .)
			}
			
			unab all_vars: *
			// Step 2: Create a new order, moving "res" before "ger"
			local neworder ""
			foreach var in `all_vars' {
				if "`var'" == "Value" {
					local neworder "`neworder' IndicatorName"  // Insert "res" before "ger"
				}
				if "`var'" != "IndicatorName" {
					local neworder "`neworder' `var'"  // Keep other variables in order
				}
			}
		 order `neworder'

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
					***CASE where ratio is specified as (myrat:var1/varN) and unit is specied as "rat1-ratN@%"
					local posof_var_before: list posof "`var_before'" in all_variable
					if `posof_var_before'>0 { // not a case where ratio is specified (rat:var1/var2)
					extract_macro_elements "`all_variable'" "`var_before'" "`var_after'"
					local vars_in "`r(subset)'"
						foreach v of local vars_in {
							qui replace Unit="`ind'" if Variable=="`v'"
							qui replace Unit="`ind'" if Variable=="`v'"
						}
					}
					else {
						extract_before_colon "`all_variable'"
						local res_before_colon "`r(extracted)'"
						extract_macro_elements "`res_before_colon'" "`var_before'" "`var_after'"
						local vars_in "`r(subset)'"
						foreach v of local vars_in {
							qui replace Unit="`ind'" if Variable=="`v'"
							qui replace Unit="`ind'" if Variable=="`v'"
						}
					}
				}
			}
			qui replace Unit = substr(Unit, strpos(Unit, "@") + 1, .)
			unab all_vars: *
			// Step 2: Create a new order, moving "res" before "ger"
			local neworder ""
			foreach var in `all_vars' {
				if "`var'" == "n_Obs" {
					local neworder "`neworder' Unit"  // Insert "res" before "ger"
				}
				if "`var'" != "Unit" {
					local neworder "`neworder' `var'"  // Keep other variables in order
				}
			}
		 order `neworder'
		}
		

	****************************************************************************
	******************LABEL INDICATOR AND UNITS IF PROVIDED*********************
	****************************************************************************
	
end

