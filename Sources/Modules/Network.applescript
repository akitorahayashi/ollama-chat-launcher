on getWifiIP()
    set ip_address to do shell script "ifconfig en0 | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' || true"
    if ip_address is "" then
        log "Network Error: Could not get Wi-Fi IP address. Please check if you are connected to Wi-Fi."
        error "Could not get Wi-Fi IP address"
    end if
    return ip_address
end getWifiIP

on isPortInUse(port_number)
    return ((do shell script "lsof -i tcp:" & port_number & " || true") is not "")
end isPortInUse
