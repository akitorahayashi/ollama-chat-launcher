-- ServerManager.applescript
-- This module is responsible for server management, command execution, and server lifecycle.

property SERVER_STARTUP_TIMEOUT : 30
property SERVER_CHECK_INTERVAL : 0.5

on startServer(ip_address, port, model_name, CommandBuilder, WindowManager)
	-- 1. コマンドを生成
	set server_command to CommandBuilder's buildServerCommand(ip_address, port, model_name)
	
	-- 2. ウィンドウタイトルとシーケンス番号を生成
	set next_seq to (WindowManager's getMaxSequenceNumber(ip_address, port) + 1)
	set server_title to WindowManager's generateWindowTitle(ip_address, next_seq, port, model_name)

	-- 3. ウィンドウを作成
	set new_server_window to WindowManager's createNewWindow(server_title)
	
	-- 4. コマンドを実行
	tell application "Terminal"
		do script server_command in new_server_window
	end tell

	return new_server_window
end startServer

on executeModelInWindow(target_window, ip_address, port, model_name, CommandBuilder, WindowManager)
	-- 1. コマンドを生成
	set model_command to CommandBuilder's buildModelCommand(ip_address, port, model_name)
	
	-- 2. 新しいタブを作成
	set new_tab to WindowManager's openNewTabInWindow(target_window)
	
	-- 3. コマンドを実行
	tell application "Terminal"
		do script model_command in new_tab
	end tell
	
	return new_tab
end executeModelInWindow

on isOllamaServerRunning(ip_address, port)
	-- Ollama APIエンドポイントにリクエストを送って、実際にOllamaサーバーが動いているかチェック
	try
		set api_url to "http://" & ip_address & ":" & port & "/api/tags"
		set curl_command to "curl -s --connect-timeout 3 --max-time 5 " & api_url & " 2>/dev/null"
		set api_response to do shell script curl_command
		-- レスポンスが空でなく、JSONのような形式であればOllamaサーバーが動いている
		return (api_response is not "" and api_response contains "{")
	on error
		return false
	end try
end isOllamaServerRunning

on waitForServer(ip_address, ollama_port, Network)
	set elapsed to 0
	set last_log_time to -10 -- Initialize to ensure the first log appears immediately
	log "Waiting for server to start... (Timeout: " & (SERVER_STARTUP_TIMEOUT as string) & "s)"

	repeat until Network's isPortInUse(ollama_port, ip_address)
		delay SERVER_CHECK_INTERVAL
		set elapsed to elapsed + SERVER_CHECK_INTERVAL

		if elapsed > SERVER_STARTUP_TIMEOUT then
			log "Timeout: Server startup timed out. Please check manually."
			return false
		end if

		if (elapsed - last_log_time) > 5 then
			log "Waiting... " & (round(elapsed) as string) & "s / " & (SERVER_STARTUP_TIMEOUT as string) & "s"
			set last_log_time to elapsed
		end if
	end repeat

	log "Server started successfully."
	return true
end waitForServer

-- Helper function for rounding numbers
on round(n)
	return n div 1
end round
