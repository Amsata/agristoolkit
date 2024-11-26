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


*cap program drop generateODTParByGeo
program define generateODTparByGeo
		

 syntax varlist ,marginlabels(string asis)  PARAMeter(string asis) ///
 VARiable(string asis) [hiergeovars(string asis) geovarmarginlab(string asis) ///
 conditionals(string asis) svySE(string) subpop(string asis) UNITs(string asis) INDICATORname(string asis) ]
 
 local n_geovar: list sizeof hiergeovars
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
 
*if (`n_geovar'==0 ) {
	quietly consistencyCheck `varlist' ,marginlabels(`marginlabels') param(`parameter') var(`variable') conditionals(`conditionals') indicator(`indicatorname') units(`units')
*}
*else {	
/*	
	local c : word count `hiergeovars'
	forvalues i=1/`c' {		
		scalar cont=0
		foreach item of local marginlabels {
			// If not excluded, add to the new local macro
			if (cont==0) {
				local new_marginlabels  `item'
				scalar cont=1
			}
			else {
				local new_marginlabels  "`new_marginlabels'"  "`item'" 
			}
		}

		local new_marginlabels  "`geovarmarginlab''" "`new_marginlabels'"  
		local new_marginlabels  `" "`new_marginlabels'" "' 
		local new_varlist "`:word `i' of `hiergeovars'' `varlist'"
		***generateODT for the new_varlist and n_w dim comb
		quietly consistencyCheck `new_varlist' ,marginlab(`new_marginlabels') param(`parameter') var(`variable') conditionals(`conditionals') indicator(`indicatorname') units(`units')
	}
	*/
*}
		
tempfile tmp_data_odt
save `tmp_data_odt', replace
global temp_file "`tmp_data_odt'"


preserve

if(`n_geovar'==0) {
	findfile svyParallel.ado
	return list
	local mypath "`r(fn)'"
	run `mypath'
	local parameter: list clean parameter
	parallel, prog(svyParallel)  setparallelid(`parallelid') keep nodata: svyParallel "`varlist'" "`variable'" "`parameter'"
}
else {
	findfile svyParallelGeo.ado
	return list
	local mypath "`r(fn)'"
	run `mypath'	
	local parameter: list clean parameter
	parallel, prog(svyParallelGeo)  setparallelid(`parallelid') keep nodata: svyParallelGeo "`varlist'" "`hiergeovars'" "`variable'" "`parameter'"
}

*ls __pll*.dta	

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

tempfile dataset_dims
save `dataset_dims',  replace


 qui parallel clean, e($LAST_PLL_ID) force
mata: parallel_sandbox(2, "`parallelid'")
 parallel clean, all force 
 
restore

preserve 

findfile svyParallel.ado
return list
local mypath "`r(fn)'"
run `mypath'
parallel, prog(svyParallel)  setparallelid(`parallelid') keep nodata: svyParallel "" "`variable'" "`parameter'"
*ls __pll*.dta	

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

tempfile dataset_alldims
save `dataset_alldims',  replace
append using `dataset_dims'



 qui parallel clean, e($LAST_PLL_ID) force
mata: parallel_sandbox(2, "`parallelid'")
 parallel clean, all force 
	

quietly {	
	if(`n_geovar'==0) local final_varlist "`varlist'"
	else local final_varlist "geoType geoVar `varlist'"

	order `final_varlist' Indicator b n_Obs N_subPop CV 
	
	
	tempfile final_dataset
	
	save `final_dataset', replace

	restore
		
	*quietly {
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
	use `final_dataset', clear

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

	
	if(`n_geovar'!=0) {
forvalues i=1/`n_geovar' {		
	if("`:word `i' of `geovarmarginlab''"=="") drop if geoVar=="" & geoType=="`:word `i' of `hiergeovars''"
	else replace geoVar="`:word `i' of `geovarmarginlab''" if geoVar=="" & geoType=="`:word `i' of `hiergeovars''"
}

replace geoType="`:word 1 of `geovarmarginlab''" if geoType==""
replace geoVar="`:word 1 of `geovarmarginlab''" if geoVar==""

	}
	
	***********************************************
	*** Create IndicatorName and Unit variables ***
	***********************************************
	*correction for ration

	
	gen Parameter="`parameter'"
	rename Indicator Variable
	rename se standError
	rename ll LL_confInt
	rename ul UL_confInt
	rename b Value

	
	order `final_varlist' Variable Parameter  Value 
	
		*correction for ration
		local c: word count `final_varlist'
	/*	
		forvalues i=1/`c' {
			di "`:word `i' of `variable''"
		replace Variable= "`:word `i' of `variable''" if Variable=="_ratio_`i'"
		}
*/		
	******************************************************************************
	****** ADDING units if specicied**********************************************
	******************************************************************************
	local n_units: list sizeof units
	local n_variable: list sizeof variable 

	if (`n_units'!=0) {
		gen Unit=""
		local c: word count `variable'
		forvalues i=1/`c' {
			replace Unit = "`:word `i' of `units''" if Variable=="`:word `i' of `variable''"
		}
			order `final_varlist' Variable Parameter  Value  Unit 
			quietly replace Value=Value*100 if Unit=="%"
	 quietly replace LL_confInt=LL_confInt*100 if Unit=="%"
	 quietly replace UL_confInt=UL_confInt*100 if Unit=="%"

	}	
	
	***************************************************************************************
	*** Adding indicator label if specified************************************************
	***************************************************************************************
	local n_indicatorname: list sizeof indicatorname
	if (`n_indicatorname'!=0) {	
	gen IndicatorName=""
	local c: word count `variable'
	forvalues i=1/`c' {
		replace IndicatorName = `"`:word `i' of `indicatorname''"' if Variable=="`:word `i' of `variable''"
	}
			order `final_varlist' Variable Parameter IndicatorName Value Unit 
			cap replace IndicatorName = ustrregexra( IndicatorName ,"&","'")


	}
	
	sort Variable 
	
	*} // quietly
	
	********************************************************
	*************** formating indicator for ratio **********
	********************************************************
	if("`parameter'"=="ratio") {
		
		foreach v of local variable {
		local pos = strpos("`v'", "/")
		local denominator = substr("`v'", `pos'+1, .)
		local numerator = substr("`v'", 1, `pos'-1)
		local numerator = subinstr("`numerator'", "_n", "", .)
		local numerator = subinstr("`numerator'", "(", "", .)
		local denominator = subinstr("`denominator'", "_d)", "", .)
		*local denominator = subinstr("`denominator'", ")", "", .)
*regexr(rownames, "^[^@]+", "variable")
		
		if ("`numerator'"=="`denominator'") { // if the ratio formula is in the form (ind2_n/ind2_d)
			replace Variable="`numerator'" if Variable== "`v'"
		}
	}

	}
	} // quietly

end

*include controle in case of hierarchical geographic variable, indication=> to many zero/missing value in sample frequencies