
program define add_name, rclass

syntax anything, [start]

if ("`start'"!="") {
    local combined `anything'
	cap macro drop _global myresult
}
else {
local combined = `"`"$indicatornames"' `anything'"'
}
    global indicatornames `"`combined'"'
end