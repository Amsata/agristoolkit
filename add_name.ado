cap program drop add_name
program define add_name, rclass

syntax anything, [start]

local anything `anything'
local newtext = subinstr("`anything'", "'", "&&&", .)
local newtext = subinstr("`newtext'", " ", "***", .)

if ("`start'"!="") {
    local combined `" `"`newtext'"' "'
	cap macro drop _global indicatornames
}
else {

local gobmac "$indicatornames"

local combined = `"`gobmac' `"`newtext'"'"'
}
    global indicatornames "`combined'"
end