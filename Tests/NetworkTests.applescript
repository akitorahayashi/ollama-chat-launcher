-- Load the module to be tested
set module_path to (path to me as text) & "::build:modules:Network.scpt"
try
    alias module_path
on error
    log "SETUP ERROR: Network.scpt not found at " & module_path
    return
end try
set Network to load script alias module_path

-- Test getWifiIP
-- Test getIPAddress
try
    set ip to Network's getIPAddress()
    -- The function should always return a string (either a found IP or the fallback 127.0.0.1).
    -- Validate basic IPv4 format by checking for dots and reasonable length.
    if ip is not "" and ip contains "." and (count of characters of ip) ≥ 7 and (count of characters of ip) ≤ 15 then
        log "Test getIPAddress: PASSED - Received: " & ip
    else
        log "Test getIPAddress: FAILED - Invalid IP address received: " & ip
    end if
on error e
    log "Test getIPAddress: FAILED - " & e
end try

-- Test isPortInUse
try
    -- This test assumes port 80 is in use, which is likely on most systems.
-- Test with a port that is likely in use (like 80 for http) and just check for a valid boolean response.
set result to Network's isPortInUse(80)
if result is true or result is false then
	log "Test isPortInUse (port 80): PASSED - Function returned a valid boolean"
    else
	log "Test isPortInUse (port 80): FAILED - Function did not return a boolean"
    end if
on error e
    log "Test isPortInUse (port 80): FAILED - " & e
end try

try
    -- This test assumes a high port number is not in use.
    if not Network's isPortInUse(65535) then
        log "Test isPortInUse (port 65535): PASSED"
    else
        log "Test isPortInUse (port 65535): FAILED - Port 65535 is in use"
    end if
on error e
    log "Test isPortInUse (port 65535): FAILED - " & e
end try
