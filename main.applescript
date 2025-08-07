-- ==========================================
-- 設定部分
-- ==========================================
set model_name to "gemma3:latest" -- 使用するモデル名を指定
set ollama_port to 55764
set local_ip to getLocalIP() -- 自動取得 or "192.168.1.100" のように固定値を直接入力
set server_startup_timeout to 30 -- サーバー起動待機のタイムアウトまでの秒数
set server_check_interval to 0.1 -- サーバーが起動しているチェックする間隔（秒）

-- ==========================================
-- 関数定義
-- ==========================================

-- 簡単なID生成関数
on generateSimpleID()
    set current_time to current date
    set hours_str to (hours of current_time as string)
    set minutes_str to (minutes of current_time as string)
    set seconds_str to (seconds of current_time as string)
    
    -- 0埋めして2桁にする
    if length of hours_str < 2 then set hours_str to "0" & hours_str
    if length of minutes_str < 2 then set minutes_str to "0" & minutes_str
    if length of seconds_str < 2 then set seconds_str to "0" & seconds_str
    
    return hours_str & minutes_str & seconds_str
end generateSimpleID

-- Wi-Fi IPアドレス取得関数
on getWifiIP()
    try
        set ip_address to do shell script "ifconfig en0 | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}'"
        if ip_address is "" then
            display dialog "Wi-Fi IPアドレスが取得できませんでした。Wi-Fiに接続しているか確認してください。" buttons {"OK"} default button "OK" with icon caution
            error "Wi-Fi IPアドレスが取得できませんでした"
        end if
        return ip_address
    on error
        display dialog "Wi-Fi IPアドレスの取得に失敗しました。ネットワーク設定を確認してください。" buttons {"OK"} default button "OK" with icon stop
        error "Wi-Fi IPアドレスが取得できませんでした"
    end try
end getWifiIP

-- ローカルIPアドレス取得関数
on getLocalIP()
    try
        set ip_address to do shell script "ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1"
        if ip_address is "" then
            display dialog "IPアドレスが取得できませんでした。ネットワークに接続しているか確認してください。" buttons {"OK"} default button "OK" with icon caution
            error "IPアドレスが取得できませんでした"
        end if
        return ip_address
    on error
        display dialog "IPアドレスの取得に失敗しました。ネットワーク設定を確認してください。" buttons {"OK"} default button "OK" with icon stop
        error "IPアドレスが取得できませんでした"
    end try
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
    -- 簡単なIDを生成
    set server_id to generateSimpleID()
    
    tell application "Terminal"
        activate
        do script "OLLAMA_HOST=" & ip_address & ":" & port_number & " ollama serve"
        set custom title of front window to "Ollama Server [" & server_id & "] (" & ip_address & ":" & port_number & ")"
        set new_window to front window
        return {new_window, server_id}
    end tell
end startOllamaServer

-- Terminalウィンドウでモデル実行関数
on runOllamaModelInWindow(target_window, ip_address, port_number, model, server_id)
	try
		-- サーバーウィンドウが見つからない場合はエラー
		if target_window is missing value then
			display dialog "Ollamaサーバーのウィンドウが見つかりませんでした。スクリプトを終了します。" buttons {"OK"} default button "OK" with icon stop
			error "Ollamaサーバーのウィンドウが見つかりません。"
		end if
		
		tell application "Terminal"
			activate
			-- ターゲットウィンドウを最前面に持ってくる
			set index of target_window to 1
		end tell
		
		-- System Eventsを使って新しいタブを作成
		tell application "System Events"
			tell process "Terminal"
				set frontmost to true
				keystroke "t" using command down
				delay 0.5 -- 新しいタブが作成されるのを待つ
			end tell
		end tell
		
		-- 新しく作成されたタブ（最前面ウィンドウのアクティブなタブ）でコマンドを実行
		tell application "Terminal"
			-- `do script`を特定のタブで実行すると、そのタブの現在のプロセスが置き換えられる
			do script "OLLAMA_HOST=http://" & ip_address & ":" & port_number & " ollama run " & model in selected tab of front window
			
			if server_id is missing value then
				display dialog "エラー: サーバーIDが取得できませんでした。開発者に報告してください。" buttons {"OK"} default button "OK" with icon stop
				error "server_id is missing value"
			end if
			
			-- 新しいタブのタイトルを設定
			set custom title of selected tab of front window to "Ollama Chat [" & server_id & "] (" & model & ")"
		end tell
		
	on error error_message
		display dialog "Terminalでモデルの実行に失敗しました: " & error_message buttons {"OK"} default button "OK" with icon stop
		error "runOllamaModelInWindow failed: " & error_message
	end try
end runOllamaModelInWindow

-- サーバー起動まで待機する関数
on waitForServer(port_number, timeout_seconds)
    set elapsed to 0
    repeat until isPortInUse(port_number)
        delay server_check_interval
        set elapsed to elapsed + server_check_interval
        if elapsed > timeout_seconds then
            display dialog "サーバーの起動がタイムアウトしました。手動で確認してください。" buttons {"OK"} default button "OK" with icon caution
            return false
        end if
    end repeat
    return true
end waitForServer

-- サーバーウィンドウを安全に検索する関数
on findServerWindow()
    try
        tell application "Terminal"
            repeat with w in windows
                try
                    set window_title to custom title of w
                    if window_title contains "Ollama Server" then
                        -- サーバーIDを抽出
                        set server_id to missing value
                        if window_title contains "[" and window_title contains "]" then
                            set start_pos to offset of "[" in window_title
                            set end_pos to offset of "]" in window_title
                            if start_pos > 0 and end_pos > start_pos then
                                set server_id to text (start_pos + 1) thru (end_pos - 1) of window_title
                            end if
                        end if
                        return {w, server_id}
                    end if
                on error
                    -- このウィンドウはスキップ
                end try
            end repeat
        end tell
    on error
        -- ウィンドウ検索でエラーが発生した場合
    end try
    return {missing value, missing value}
end findServerWindow

-- ==========================================
-- 実行部分
-- ==========================================

try
    -- ポートが使用中か確認
    if isPortInUse(ollama_port) then
        -- 既にサーバーが起動している場合
        say "サーバーは既に起動中です。新しいタブでチャットを開始します。"
        
        -- 既存のサーバーウィンドウを探す
        set server_info to findServerWindow()
        set server_window to item 1 of server_info
        set server_id to item 2 of server_info
        
        -- モデルを実行
        runOllamaModelInWindow(server_window, local_ip, ollama_port, model_name, server_id)
    else
        -- Ollamaサーバーを起動
        say "サーバーを起動しています..."
        set server_info to startOllamaServer(local_ip, ollama_port)
        set server_window to item 1 of server_info
        set server_id to item 2 of server_info
        
        -- サーバーの起動を待機
        say "サーバーの起動を待機中..."
        if waitForServer(ollama_port, server_startup_timeout) then
            say "サーバーが起動しました。チャットを開始します。"
            delay 1 -- サーバー完全起動のための少し長めの待機
            -- 同じTerminalウィンドウの新しいタブでモデルを実行
            runOllamaModelInWindow(server_window, local_ip, ollama_port, model_name, server_id)
        else
            display dialog "サーバーの起動に失敗しました。" buttons {"OK"} default button "OK" with icon stop
        end if
    end if
    
on error error_message
    display dialog "エラーが発生しました: " & error_message buttons {"OK"} default button "OK" with icon stop
end try