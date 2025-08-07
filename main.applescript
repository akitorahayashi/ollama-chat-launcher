-- 設定
set model_name to "gemma3:latest"
set ollama_port to 11600
set host_ip to "0.0.0.0"

-- ポートが使用中か確認
try
    do shell script "lsof -i tcp:" & ollama_port
    -- ポートが使用中の場合、メッセージを表示せずにモデルを実行する
    tell application "Terminal"
        activate
        do script "OLLAMA_HOST=http://" & host_ip & ":" & ollama_port & " ollama run " & model_name
        set custom title of front window to "Ollama Chat"
    end tell
on error
    -- ポートが使用中でない場合、サーバーを起動し、モデルを実行する
    tell application "Terminal"
        activate
        do script "OLLAMA_HOST=http://" & host_ip & ":" & ollama_port & " ollama serve"
        set custom title of front window to "Ollama Server"
    end tell
    delay 1 -- サーバー起動後に少し待機
    tell application "Terminal"
        activate
        do script "OLLAMA_HOST=http://" & host_ip & ":" & ollama_port & " ollama run " & model_name
        set custom title of front window to "Ollama Chat"
    end tell
end try