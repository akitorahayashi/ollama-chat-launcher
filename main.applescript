-- ==========================================
-- 設定
-- ==========================================
set model_name to "特定のモデル名"
set ollama_port to 55764
set local_ip to getLocalIP() -- 自動取得 or "192.168.1.100" のように固定値を直接入力

-- ==========================================
-- 関数定義
-- ==========================================

-- Wi-Fi IPアドレス取得関数
on getWifiIP()
    set ip_address to do shell script "ifconfig en0 | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}'"
    if ip_address is "" then
        error "Wi-Fi IPアドレスが取得できませんでした"
    end if
    return ip_address
end getWifiIP

-- ローカルIPアドレス取得関数
on getLocalIP()
    set ip_address to do shell script "ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1"
    if ip_address is "" then
        error "IPアドレスが取得できませんでした"
    end if
    return ip_address
end getLocalIP

-- ポート使用状況チェック関数
on isPortInUse(port_number)
    try
        do shell script "lsof -i tcp:" & port_number & " > /dev/null 2>&1"
        return true
    on error
        return false
    end try
end isPortInUse

-- Ollamaサーバー起動関数
on startOllamaServer(ip_address, port_number)
    tell application "Terminal"
        activate
        do script "OLLAMA_HOST=" & ip_address & ":" & port_number & " ollama serve"
        set custom title of front window to "Ollama Server (" & ip_address & ":" & port_number & ")"
    end tell
end startOllamaServer

-- モデル実行関数
on runOllamaModel(ip_address, port_number, model)
    tell application "Terminal"
        activate
        do script "OLLAMA_HOST=http://" & ip_address & ":" & port_number & " ollama run " & model
    end tell
end runOllamaModel

-- ==========================================
-- 実行部分
-- ==========================================

-- ポートが使用中か確認
if isPortInUse(ollama_port) then
    -- 既にサーバーが起動している場合はモデルのみ実行
    runOllamaModel(local_ip, ollama_port, model_name)
else
    -- Ollamaサーバーを起動
    startOllamaServer(local_ip, ollama_port)
    delay 1
    
    -- モデルを実行
    runOllamaModel(local_ip, ollama_port, model_name)
end if