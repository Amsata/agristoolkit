/* START HELP FILE
title[a command to setup working directory and necessary files and folder for anonymization]

desc[
 {cmd:mat_to_ds} generate folders, excel files for variables classification and dataset
 description, pre-populated scripts and sample reports for anonymization and information loss analysis.
] 

opt[T() a matrix from survey estimation.]

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
	cap program drop mat_to_ds
	program mat_to_ds
	args T col
	matrix input = `T' 
	local rownames : rowfullnames T
	local c : word count `rownames'
	// get original column names of matrix and substitute out _cons
	local names : colfullnames `T'
	local newnames : subinstr local names "_cons" "cons", word
	// rename columns of matrix
	matrix colnames `T' = `newnames'
	// convert to dataset
	*clear
	*preserve
	drop _all
	
	if ("`col'"=="yes") {
	svmat `T',names(col)
	}
	else {
	svmat `T'
	}
	*xsvmat T, names(col) norestore stata 16 for name storage		   
	// add matrix row names to dataset
	*tempfile dst
	*xsvmat `T', rowname(rownames) names(col) list(, abbr(32)) saving(`dst', replace)
	*use `dst', clear

	gen rownames = ""
	forvalues i = 1/`c' {
		quietly replace rownames = "`:word `i' of `rownames''" in `i'
	}
end
