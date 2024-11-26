// the 'make.do' file is automatically created by 'github' package.
// execute the code below to generate the package installation files.
// DO NOT FORGET to update the version of the package, if changed!
// for more information visit http://github.com/haghish/github

make agriSUrveyTools, replace toc pkg readme version(0)                            ///
     license("MIT")                                                          ///
     author("Amsata Niang")                                                  ///
     affiliation("FAO")                                                      ///
     email("amsata_niang@yahoo.fr")                                          ///
     url("")                                                                 ///
     title("processing, analysing, disseminating survey data")               ///
     description("processing, analysing, disseminating survey data")         ///
     install("generateODT.ado;generateODT.sthlp;generateODTbyGeo.ado;generateODTbyGeo.sthlp;mat_to_ds.ado;setup_anonymization.ado;setup_anonymization.sthlp;generateODTpar.ado;generateODTpar.sthlp;svyEstimate.ado;svyParallel.ado;svyParallelGeo.ado;consistencyCheck.ado") ///
     ancillary("testdst.dta")                                              
