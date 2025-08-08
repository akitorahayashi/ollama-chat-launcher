-- Network.applescript
-- Handles network-related tasks like IP address retrieval and port checking.

-- ==========================================
-- Public API
-- ==========================================

on getIPAddress(overrideIP)
	-- This is the main public handler for retrieving the most relevant IP address.
	-- It tries to find an IP in a specific order of priority:
	-- 1. User-provided override IP
	-- 2. Wi-Fi
	-- 3. Localhost

	if overrideIP is not missing value and overrideIP is not "" then
        return overrideIP
    end if

    if overrideIP is not missing value and overrideIP is not "" then
        return overrideIP
    end if

    set wifiIP to _getWifiIP()
    if wifiIP is missing value then
        return _getLocalhostIP()
    else
        return wifiIP
    end if
end getIPAddress

on isPortInUse(port_number, ip_address)
	-- Checks if a given TCP port is currently in use on a specific IP address.
	-- This is more precise because OLLAMA_HOST binds the server to a specific interface.
	return ((do shell script "lsof -i @" & ip_address & ":" & port_number & " || true") is not "")
end isPortInUse

-- ==========================================
-- Private Handlers (for internal use only)
-- ==========================================

on _getWifiIP()
	-- Tries to get the IP address from the 'en0' (Wi-Fi) interface.
	-- Returns the IP address as a string or 'missing value' if not found.
	try
		set ip_address to do shell script "ifconfig en0 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}'"
		if ip_address is "" then
			return missing value
		else
			return ip_address
		end if
	on error errMsg number errNum
		return "Error: " & errMsg & " (Error Number: " & errNum & ")"
	end try
end _getWifiIP

on _getLocalhostIP()
	-- Returns the localhost IP address as a fallback.
	return "127.0.0.1"
end _getLocalhostIP
