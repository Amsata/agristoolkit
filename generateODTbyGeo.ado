
program  define generateODTbyGeo

 syntax varlist ,dimcomb(string asis) hierGEOVARS(varlist) PARAMeter(string) VARiable(string asis) LABind(string asis) UNITs(string asis) 

 local geovar `hiergeovars'
 
if ("`hiergeovars'"!="") {
	generateODT `varlist' ,dimcomb(`dimcomb') PARAMeter(`parameter') VARiable(`variable') LABind(`labind') UNITs(`units')
}

end


