
/* START HELP FILE
title[a command to setup working directory and necessary files and folder for anonymization]

desc[
 {cmd:setup_anonymization} generate folders, excel files for variables classification and dataset
 description, pre-populated scripts and sample reports for anonymization and information loss analysis.
] 

opt[svyname() name of the survey to be anonymization for dissemination.]
opt[author() institution in charge of the anonymization or microdata dissemination.]
opt[language() langage of the folders and reports 'en' for english 'fr' for franch and 'es' for spanish.]
opt[workingdir() path of the working directory where files will be created the path should be specifies as in R sorftware (with '/') .]
opt[datadir() folder where the microdata to be anonymized is located It accept nested folders.]
opt[type() data type.]
opt[overwrite() replace.]

opt2[overwrite() specifies the probability used in the standard error formula.
and I wanted more than one line for the longer  descriptions of the
option overwrite() later in the help file]


example[
 {stata setup_anonymization, svyname("Enquete sur le maraichage") author("FAO") language("fr") workingdir("dir") datadir("Dir") type(".dta") overwrite("TRUE")}
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


program define setup_anonymization
syntax  [,svyname(string asis) author(string asis) language(string asis) workingdir(string asis) datadir(string asis) type(string asis) overwrite(string asis)]

rcall vanilla: library(agrisvyr); ///
mar2023=createAgrisvy(svyName =`svyName' , ///
                      author =`author' , ///
                      language = `language' , ///
                      workingDir = `workingDir' , ///
                      dataDir = `dataDir' , ///
                      type = `type' ); ///
options(usethis.allow_nested_project = TRUE); ///
setup_anonymization(mar2023,overwrite = `overwrite')

end