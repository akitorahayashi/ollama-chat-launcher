-- Network.applescript
-- Handles network-related tasks like IP address retrieval and port checking.

-- ==========================================
-- Public API
-- ==========================================

on getIPAddress()
	-- This is the main public handler for retrieving the most relevant IP address.
	-- It tries to find an IP in a specific order of priority:
	-- 1. Internet Sharing (Bridge)
	-- 2. Wi-Fi
	-- 3. Fallback (localhost)

	set ip to _getBridgeIP()

	if ip is missing value then
		set ip to _getWifiIP()
	end if

	if ip is missing value then
		set ip to _getLocalhostIP()
	end if

	return ip
end getIPAddress

on isPortInUse(port_number)
	-- Checks if a given TCP port is currently in use.
	return ((do shell script "lsof -i tcp:" & port_number & " || true") is not "")
end isPortInUse

-- ==========================================
-- Private Handlers (for internal use only)
-- ==========================================

on _getBridgeIP()
	-- Tries to get the IP address from the 'bridge100' interface,
	-- which is commonly used for Internet Sharing on macOS.
	-- Returns the IP address as a string or 'missing value' if not found.
	try
		set ip_address to do shell script "ifconfig bridge100 2>/dev/null | grep 'inet ' | awk '{print $2}'"
		if ip_address is "" then
			return missing value
		else
			return ip_address
		end if
	on error
		return missing value
	end try
end _getBridgeIP

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
	on error
		return missing value
	end try
end _getWifiIP

on _getLocalhostIP()
	-- Returns the localhost IP address as a fallback.
	return "127.0.0.1"
end _getLocalhostIP
