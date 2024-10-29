/* START HELP FILE
title[a command to generate multi-dimentional statisticial tables destined to Open Data africa or other 
similar plateform by putting hierarchical geographic dimensions in on column]

desc[
 {cmd:generateODTbyGeo} generate multi-dimentional statisticial tables destined to open Data Africa plateform
 or for other potential use.
] 

opt[varlist() list of of variables (domains) over which estimates will be creatd.]
opt[marginlabels() specify the labels of margins of variables in varlist.]
opt[parameter() parameter to be estimated in the domains (total, mean or ratio).]
opt[hiergeovars() parameter to be estimated in the domains (total, mean or ratio).]
opt[geovarmarginlab() parameter to be estimated in the domains (total, mean or ratio).]
opt[variable() variable the value of which will be used to generate the specified parameter in 'parameter'.]
opt2[conditionals() eliminate tuples (of dimensions in varlist) according to specified conditions.]
opt2[indicatorname() a comprehensive and informative label of the indicator generated with variables specified in 'variable'.]
opt2[units() units of the parameter generated with variable in 'variable'.]
opt2[svySE() units of the parameter generated with variable in 'variable'.]
opt2[subpop() {cmd:(}[{varname}] [{it:{help if}}]{cmd:)}}identify a subpopulation	]

opt2[varlist() list of of variables (domains) over which estimates will be creatd.]
opt2[marginlabels() specify the labels of margins of variables in varlist.]
opt2[parameter() parameter to be estimated in the domains (total, mean or ratio).]
opt2[hiergeovars() parameter to be estimated in the domains (total, mean or ratio).]
opt2[geovarmarginlab() parameter to be estimated in the domains (total, mean or ratio).]
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

capture program drop generateODTbyGeo
program  define generateODTbyGeo

 syntax varlist ,marginlabels(string asis)  PARAMeter(string asis) ///
 VARiable(string asis) [hiergeovars(string asis) geovarmarginlab(string asis) ///
 conditionals(string asis) svySE(string) subpop(string asis) UNITs(string asis) INDICATORname(string asis) ]
 
scalar init=0
	tempfile odp_table
 local n_geovar: list sizeof hiergeovars
 local n_geovarmarginlab: list sizeof geovarmarginlab

 if(`n_geovar'!=`n_geovarmarginlab' & `n_geovar'!=0) {
 	
	display as error "The options hiergeovars and geovarmarginlab should have the same number of element!"
 }
 
 if (`n_geovar'==1) {
	display as error "geovar should contain at least 2 hierarchical geographic variable!"
	exit 498
 }
 
 foreach v of local hiergeovars {
	local pos: list posof "`v'" in varlist
	if (`pos'>0) {
		display as error "The variable `v' should be excluded from varlist"
		exit 498
	}
 }
 
 
if (`n_geovar'==0 ) {
	quietly generateODT `varlist' ,marginlabels(`marginlabels') param(`parameter') var(`variable') conditionals(`conditionals') indicator(`indicatorname') units(`units')
}
else {
    
	
	local c : word count `hiergeovars'
	forvalues i=1/`c' {
		preserve
		
scalar cont=0
foreach item of local marginlabels {
      // If not excluded, add to the new local macro
		if (cont==0) {
		local new_marginlabels  "`item'" 
		scalar cont=1
		}
		else {
		local new_marginlabels  "`new_marginlabels'"  "`item'" 
		}
    }
	
	local new_marginlabels  "`:word `i' of `geovarmarginlab''" "`new_marginlabels'"  

        local new_varlist "`:word `i' of `hiergeovars'' `varlist'"
 
	***generateODT for the new_varlist and n_w dim comb
	quietly generateODT `new_varlist' ,marginlab(`new_marginlabels') param(`parameter') var(`variable') conditionals(`conditionals') indicator(`indicatorname') units(`units')
	rename `:word `i' of `hiergeovars'' geo_var
	if(init==0) {
		save `odp_table', replace
		scalar init=1
	}
	else {
			append using `odp_table'
		    save `odp_table', replace
	}
	restore
	}
		use	`odp_table',clear

}


end