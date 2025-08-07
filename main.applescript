property MODEL_NAME : "gemma3:latest"
property OLLAMA_PORT : 55764
property SERVER_STARTUP_TIMEOUT : 30
property SERVER_CHECK_INTERVAL : 0.1


try
	set wifi_ip to getWifiIP()
	if isPortInUse(OLLAMA_PORT) then
		handleExistingServer(wifi_ip)
	else
		handleNewServer(wifi_ip)
	end if
on error error_message
	log "実行エラー: エラーが発生しました: " & error_message
end try

-- ==========================================
-- ウィンドウタイトル生成
-- ==========================================
on generateWindowTitle(wifi_ip, sequence_number, title_type)
	if title_type is "server" then
		return "Ollama Server #" & sequence_number & " [" & wifi_ip & ":" & OLLAMA_PORT & "]"
	else if title_type is "chat" then
		return "Ollama Chat #" & sequence_number & " [" & wifi_ip & ":" & OLLAMA_PORT & "] (" & MODEL_NAME & ")"
	end if
end generateWindowTitle

-- ==========================================
-- ユーティリティ関数群
-- ==========================================
on extractFieldsFromString(text_to_split, delimiter)
	set old_delimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set string_list to text items of text_to_split
	set AppleScript's text item delimiters to old_delimiters
	return string_list
end extractFieldsFromString

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

-- ==========================================
-- ネットワーク関連関数群
-- ==========================================
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

on waitForServer()
	set elapsed to 0
	repeat until isPortInUse(OLLAMA_PORT)
		delay SERVER_CHECK_INTERVAL
		set elapsed to elapsed + SERVER_CHECK_INTERVAL
		if elapsed > SERVER_STARTUP_TIMEOUT then
			log "タイムアウト: サーバーの起動がタイムアウトしました。手動で確認してください。"
			return false
		end if
	end repeat
	return true
end waitForServer

-- ==========================================
-- Terminal操作抽象化レイヤー
-- ==========================================
on openNewTerminalTab(parent_window, command)
	tell application "Terminal"
		activate
		set current_window to parent_window
		-- ウィンドウを選択してからCmd+Tで新しいタブを作成
		set selected of current_window to true
		tell application "System Events"
			keystroke "t" using command down
		end tell
		delay 0.5
		-- 新しいタブでコマンドを実行
		do script command in front window
		return selected tab of front window
	end tell
end openNewTerminalTab

on setTerminalTitle(window_or_tab, title)
	tell application "Terminal"
		set custom title of window_or_tab to title
	end tell
end setTerminalTitle

on createNewTerminalWindow(command)
	tell application "Terminal"
		activate
		do script command
		return front window
	end tell
end createNewTerminalWindow

-- ==========================================
-- ウィンドウ管理関数群
-- ==========================================
on getMaxSequenceNumber(wifi_ip)
	set max_seq to 0
	set expected_server_pattern to "[" & wifi_ip & ":" & OLLAMA_PORT & "]"
	try
		tell application "Terminal"
			repeat with w in windows
				try
					set window_title to custom title of w
					-- 現在の設定と完全一致するOllamaサーバーウィンドウから連番を抽出
					if window_title starts with "Ollama Server #" and window_title contains expected_server_pattern then
						set title_parts to my extractFieldsFromString(window_title, "#")
						if (count of title_parts) ≥ 2 then
							set seq_part to item 2 of title_parts
							set space_pos to offset of " " in seq_part
							if space_pos > 0 then
								set seq_str to text 1 thru (space_pos - 1) of seq_part
								try
									set seq_num to seq_str as integer
									if seq_num > max_seq then set max_seq to seq_num
								end try
							end if
						end if
					end if
				on error
					-- このウィンドウはスキップ
				end try
			end repeat
		end tell
	on error error_message
		log "ウィンドウ管理エラー: Terminalウィンドウの連番取得中にエラーが発生しました: " & error_message
		error "getMaxSequenceNumber failed"
	end try
	return max_seq
end getMaxSequenceNumber

on findLatestServerWindow(wifi_ip)
	set max_seq to 0
	set latest_window to missing value
	set latest_sequence to missing value
	set expected_server_pattern to "[" & wifi_ip & ":" & OLLAMA_PORT & "]"
	
	try
		tell application "Terminal"
			repeat with w in windows
				try
					set window_title to custom title of w
					-- 現在の設定と完全一致するOllamaサーバーウィンドウを探す
					if window_title starts with "Ollama Server #" and window_title contains expected_server_pattern then
						if window_title contains "#" then
							set title_parts to my extractFieldsFromString(window_title, "#")
							if (count of title_parts) ≥ 2 then
								set seq_part to item 2 of title_parts
								set space_pos to offset of " " in seq_part
								if space_pos > 0 then
									set seq_str to text 1 thru (space_pos - 1) of seq_part
									try
										set seq_num to seq_str as integer
										if seq_num > max_seq then
											set max_seq to seq_num
											set latest_window to w
											set latest_sequence to seq_num
										end if
									end try
								end if
							end if
						end if
					end if
				on error
					-- このウィンドウはスキップ
				end try
			end repeat
		end tell
	on error
		-- ウィンドウ検索でエラーが発生した場合
	end try
	
	return {window:latest_window, sequence:latest_sequence}
end findLatestServerWindow

-- ==========================================
-- サーバー操作関数群
-- ==========================================
on startOllamaServer(wifi_ip)
	set next_seq to (getMaxSequenceNumber(wifi_ip) + 1)
	set window_title to generateWindowTitle(wifi_ip, next_seq, "server")
	set command to "OLLAMA_HOST=" & wifi_ip & ":" & OLLAMA_PORT & " ollama serve"
	
	set new_window to createNewTerminalWindow(command)
	setTerminalTitle(new_window, window_title)
	
	return {window:new_window, sequence:next_seq}
end startOllamaServer

on validateServerWindow(target_window, wifi_ip, sequence_number)
	if target_window is missing value then
		set msg to "Ollamaサーバーのウィンドウが見つかりませんでした。"
		set details to "検索条件: IP=" & wifi_ip & ", PORT=" & OLLAMA_PORT & return & "期待ウィンドウ名: " & generateWindowTitle(wifi_ip, sequence_number, "server")
		
		tell application "Terminal"
			set details to details & return & "現在のTerminalウィンドウ一覧:"
			repeat with w in windows
				set details to details & return & "- " & custom title of w
			end repeat
		end tell
		
		log "ウィンドウエラー: " & msg & return & details
		error "Server window not found"
	end if
end validateServerWindow

on executeOllamaModel(target_window, wifi_ip, sequence_number)
	validateServerWindow(target_window, wifi_ip, sequence_number)
	
	set command to "OLLAMA_HOST=http://" & wifi_ip & ":" & OLLAMA_PORT & " ollama run " & MODEL_NAME
	set new_tab to openNewTerminalTab(target_window, command)
	set tab_title to generateWindowTitle(wifi_ip, sequence_number, "chat")
	setTerminalTitle(new_tab, tab_title)
end executeOllamaModel

-- ==========================================
-- メインフロー制御関数群
-- ==========================================
on handleExistingServer(wifi_ip)
	set server_info to findLatestServerWindow(wifi_ip)
	set server_window to server_info's window
	set sequence_number to server_info's sequence
	if server_window is not missing value then
		executeOllamaModel(server_window, wifi_ip, sequence_number)
	else
		handleNewServer(wifi_ip)
	end if
end handleExistingServer

on handleNewServer(wifi_ip)
	set server_info to startOllamaServer(wifi_ip)
	set server_window to server_info's window
	set sequence_number to server_info's sequence
	if waitForServer() then
		delay 1 -- サーバー完全起動のための待機
		executeOllamaModel(server_window, wifi_ip, sequence_number)
	else
		log "起動失敗: サーバーの起動に失敗しました。"
	end if
end handleNewServer