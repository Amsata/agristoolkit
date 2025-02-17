program define extract_before_colon, rclass
    args input_macro
    
    local result ""  // Initialize an empty local to store the extracted elements

    foreach elem of local input_macro {
	local pos=strpos("`elem'", ":")
        if `pos'> 0 {  // Check if ":" exists in the element
            local before_colon = substr("`elem'", 1, strpos("`elem'", ":") - 1)
			 local before_colon=subinstr("`before_colon'", "(", "", .)
            local result "`result' `before_colon'"
        }
		else {
		   local result "`result' `elem'"
		}
    }

    return local extracted "`result'"  // Store the result in r() for retrieval
end
