on getWifiIP()
    set ip_address to do shell script "ifconfig en0 | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' || true"
    if ip_address is "" then
        log "ネットワークエラー: Wi-Fi IPアドレスが取得できませんでした。Wi-Fiに接続しているか確認してください。"
        error "Wi-Fi IPアドレスが取得できませんでした"
    end if
    return ip_address
end getWifiIP

on isPortInUse(port_number)
    return ((do shell script "lsof -i tcp:" & port_number & " || true") is not "")
end isPortInUse
