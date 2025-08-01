/* START HELP FILE
title[a command to setup working directory and necessary files and folder for anonymization]

desc[
 {cmd:genMDTbyParam} generate multi-dimentional statisticial tables destined to open Data Africa plateform
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

cap program drop genMDTbyParam
program define genMDTbyParam
		
	syntax [varlist(default=none)] , PARAMeter(string asis) VARiable(string asis) [MARGINlabels(string asis) HIERGEOvars(string asis) ///
	GEOMARGINlabel(string) CONDitionals(string asis) svySE(string) subpop(string asis) setcluster(integer 0)]
	
	local n_geovar: list sizeof hiergeovars
	local n_varlist: list sizeof varlist
	local n_geomarginlabel: list sizeof geomarginlabel
	  
	tempfile tmp_data_odt
	qui save `tmp_data_odt', replace
	global temp_file "`tmp_data_odt'"

	preserve

	if(`n_geovar'==0) {
		qui findfile svyParallel.ado
		qui return list
		local mypath "`r(fn)'"
		run "`mypath'"
		local parameter: list clean parameter
		
		if(`setcluster'==0) {
			svyParallel "`varlist'" "`variable'" "`parameter'" `setcluster'
			tempfile dataset_dims
			qui save `dataset_dims',  replace
		} 
		else {
			parallel, prog(svyParallel)  setparallelid(`parallelid') keep nodata: svyParallel "`varlist'" "`variable'" "`parameter'" `setcluster'
			
			******************* Appending all files ****************************
			local files: dir . files "__pll_*.dta" 		//   Step 1: list all datasets to be appended
			use `: word 1 of `files'', clear         	//   Step 2: Load the first dataset
			* Step 3: Loop through the remaining datasets and append them
			foreach file of local files {
				* Skip the first file since it's already loaded
				if ("`file'" != "`: word 1 of `files''") qui append using `file'
			}
			
			tempfile dataset_dims
			qui save `dataset_dims',  replace
			qui parallel clean, e($LAST_PLL_ID) force
			mata: parallel_sandbox(2, "`parallelid'")
			parallel clean, all force 
		}
	}
	else {
		qui findfile svyParallelGeo.ado
		qui return list
		local mypath "`r(fn)'"
		qui run "`mypath'"	
		local parameter: list clean parameter	
		if (`setcluster'==0) {
			svyParallelGeo "`varlist'" "`hiergeovars'" "`variable'" "`parameter'" `setcluster'
			tempfile dataset_dims
			qui save `dataset_dims',  replace
		}
		else{
			parallel, prog(svyParallelGeo)  setparallelid(`parallelid') keep nodata: svyParallelGeo "`varlist'" "`hiergeovars'" "`variable'" "`parameter'" `setcluster'
			
			******************** appending all files ***************************
			local files: dir . files "__pll_*.dta" // Step 1: List all files
			use `: word 1 of `files'', clear       // Step 2: Load the first dataset
			* Step 3: Loop through the remaining datasets and qui append them
			foreach file of local files {
				* Skip the first file since it's already loaded
				if ("`file'" != "`: word 1 of `files''") qui append using `file'
			}

			tempfile dataset_dims
			qui save `dataset_dims',  replace
			* CLean all temporary files generated by the parallelization
			qui parallel clean, e($LAST_PLL_ID) force
			mata: parallel_sandbox(2, "`parallelid'")
			parallel clean, all force 
		}
	}

	restore
	preserve 
	qui findfile svyParallel.ado
	qui return list
	local mypath "`r(fn)'"
	run "`mypath'"

	if(`setcluster'==0) {
		svyParallel "" "`variable'" "`parameter'" `setcluster'
		tempfile dataset_alldims
		qui save `dataset_alldims',  replace
		qui append using `dataset_dims'
	}
	else {
		parallel, prog(svyParallel)  setparallelid(`parallelid') keep nodata: svyParallel "" "`variable'" "`parameter'" `setcluster'
		
		********************** appending all files *****************************
		local files: dir . files "__pll_*.dta"  // Step 1: List all files
		use `: word 1 of `files'', clear        // Step 2: Load the first dataset
		* Step 3: Loop through the remaining datasets and qui append them
		foreach file of local files {
			* Skip the first file since it's already loaded
			if ("`file'" != "`: word 1 of `files''") qui append using `file'		
		}
		
		tempfile dataset_alldims
		qui save `dataset_alldims',  replace
		qui append using `dataset_dims'
		* CLean all temporary files generated by the parallelization
		qui parallel clean, e($LAST_PLL_ID) force
		mata: parallel_sandbox(2, "`parallelid'")
		parallel clean, all force 
	}

	quietly {	
		if(`n_geovar'==0) local final_varlist "`varlist'"
		else local final_varlist "geoType geoVar `varlist'"
		
		order `final_varlist' Indicator b n_Obs N_subPop CV_pct
		
		tempfile final_dataset
		qui save `final_dataset', replace

		restore
		* Extracting variable labels
		foreach v of local varlist {	
			*Exploring labelsof command would reduce this number of line
			local old_vl: value label `v'
			elabel copy `old_vl' ld_`v' 
		}
		* Adding the value label for the magins of dimensions
		local n_marginlabels: list sizeof marginlabels
		*local c: word count `varlist'
		local i = 1  // Initialize the iteration counter
		*local i = `i' + 1  // Increment the counter
		if (`n_marginlabels'>0) {
			foreach name of local marginlabels {
				local pos=strpos("`name'", "@")
				local varname=substr("`name'", 1, strpos("`name'", "@") - 1)
				local new_val_lab=substr("`name'", strpos("`name'", "@") + 1, .)
				cap label list ld_`varname'
				return list
				local n_lev=`r(max)'+1
				cap elabel list ld_`varname'
				return list 
				local lev `r(values)'
				local ap: list posof `"`n_lev'"' in lev
				if (`ap'==0) label define ld_`varname' `n_lev' "`new_val_lab'", add	
			}	
		}
		
		tempfile  dolabs
		label save using `dolabs' // store them in a temporary do-file
		use `final_dataset', clear
		run `dolabs' // get the value labels
		* see https://www.statalist.org/forums/forum/general-stata-discussion/general/251350-how-can-i-apply-value-labels-stored-in-different-dataset-into-my-primary-data
		local c: word count `varlist'
		
		if (`n_marginlabels'>0) {
			foreach name of local marginlabels {
				local pos=strpos("`name'", "@")
				local varname=substr("`name'", 1, strpos("`name'", "@") - 1)
				cap label list ld_`varname'
				return list
				local n_lev=`r(max)'
				qui replace `varname'= `n_lev' if `varname'==.
			}	
		}
		
		foreach v of local varlist {
			drop if `v'==.
			label values `v' ld_`v'	
		}

		if(`n_geovar'!=0) {

		local size_geomarginlabel: list sizeof geomarginlabel
			if(`size_geomarginlabel'==0){
				drop if geoVar==.
			} 
			else{
			
				cap label list labels_geovars
				return list
				local n_lev=`r(max)'+1
				label define labels_geovars `n_lev' `"`geomarginlabel'"', add	
				qui label list labels_geovars
				la li labels_geovars
				qui replace geoVar= `r(max)' if missing(geoVar) & geoType==""
				qui replace geoVar= `r(max)' if missing(geoVar) & geoType=="`:word 1 of `hiergeovars''"
				label val geoVar labels_geovars
				qui replace geoType=`"`geomarginlabel'"' if geoVar== `r(max)'
				drop if missing(geoVar)
			} 
			
		}
	
		gen Parameter="`parameter'"
		rename Indicator Variable
		rename se standError
		rename ll LL_confInt
		rename ul UL_confInt
		rename b Value
		format Value %15.2f
		order `final_varlist' Variable Parameter  Value 

	} // quietly

end

