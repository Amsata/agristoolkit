cap program drop metadata
program define metadata, rclass

syntax anything, [clear]

local anything `anything'
local newtext = subinstr("`anything'", "'", "&&&", .)
local newtext = subinstr("`newtext'", " ", "***", .)

if ("`clear'"!="") {
    local combined `" `"`newtext'"' "'
	cap macro drop _global indicator_names
}
else {
local gobmac "$indicator_metadata"
local combined = `"`gobmac' `"`newtext'"'"'
}

local combined_for_unit

foreach item of local combined {
    if (regexm("`item'", "{\\$}")) {
        local cleaned = "`item'"
    }
    else {
        *local cleaned = ""
		local cleaned= regexr("`item'", "@.*", "@")

    }
	local combined_for_unit= `"`combined_for_unit' `"`cleaned'"'"'
}


local units
foreach item of local combined_for_unit {
*local cleaned = regexr("`item'", ".*{\\$}", "")
local cleaned = regexr("`item'", "@[^{]*\{[#\$]\}", "@")
local cleaned= regexr( "`cleaned'" , "{#}.*", "")
local cleaned = regexr("`cleaned'", "@[^{]*\{[#\$]\}", "@")
local units=`"`units' `"`cleaned'"'"'
}

local c_combined
foreach item of local combined {
local cleaned = regexr("`item'", "\{\\$\}[^{]*\{[#\$]\}", "{#}")
local cleaned= regexr( "`cleaned'" , "{\\$}.*", "") // if {#} is not present

	local c_combined= `"`c_combined' `"`cleaned'"'"'
}

    global indicator_units "`units'"
    global indicator_names "`c_combined'"
	global indicator_metadata "`combined'"

end

/*
"PROD@Production agricole{#}Metric tonne{#}Production" "SUP@Superficie cultivée{$}Ha{#}Superficie" "REND@Rendement agricole{$}Kg/Ha"

di `"$indicator_names"'
di `"$indicator_units"'


local myind=`"$indicator_names"'



di `"`result'"'

*/


