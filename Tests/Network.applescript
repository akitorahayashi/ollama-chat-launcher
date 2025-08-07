-- Load the module to be tested
set module_path to (path to me as text) & "::build:modules:Network.scpt"
set Network to load script alias module_path

-- Test getWifiIP
try
    set ip to Network's getWifiIP()
    if ip is not "" then
        log "Test getWifiIP: PASSED"
    else
        log "Test getWifiIP: FAILED - IP address is empty"
    end if
on error e
    log "Test getWifiIP: FAILED - " & e
end try

-- Test isPortInUse
try
    -- This test assumes port 80 is in use, which is likely on most systems.
    if Network's isPortInUse(80) then
        log "Test isPortInUse (port 80): PASSED"
    else
        log "Test isPortInUse (port 80): FAILED - Port 80 is not in use"
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
