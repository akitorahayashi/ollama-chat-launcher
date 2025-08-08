-- ==========================================
-- ==========================================
-- Module Loading
-- ==========================================
global Network, ServerManager, TerminalManager, CommandBuilder

on loadModules()
	try
		set script_path to path to me
		tell application "Finder"
			set script_container to container of script_path as text
		end tell
		-- buildディレクトリ内のコンパイル済みモジュールをロード
		set compiled_modules_folder to (script_container & "build:modules:")

		-- 全てのモジュールをロードする
		set Network to load script alias (compiled_modules_folder & "Network.scpt")
		set ServerManager to load script alias (compiled_modules_folder & "ServerManager.scpt")
		set TerminalManager to load script alias (compiled_modules_folder & "TerminalManager.scpt")
		set CommandBuilder to load script alias (compiled_modules_folder & "CommandBuilder.scpt")
		log "All modules loaded successfully."
	on error error_message
		log "Module loading error: " & error_message
		error "Failed to load required modules: " & error_message
	end try
end loadModules

-- ==========================================
-- Parameter Validation
-- ==========================================
on validateParameters(ip_address, port, model_name)
	-- IPアドレスの基本的な形式チェック
	if ip_address does not contain "." then
		error "Invalid IP address format: " & ip_address
	end if

	-- ポート番号の範囲チェック
	try
		set port_number to port as integer
		if port_number < 1 or port_number > 65535 then
			error "Port number out of valid range (1-65535): " & port
		end if
	on error
		error "Invalid port number: " & port
	end try

	-- モデル名の基本チェック
	if length of model_name = 0 then
		error "Model name cannot be empty"
	end if
end validateParameters

-- ==========================================
-- Public API
-- ==========================================
on runWithConfiguration(modelName, ollamaPort, overrideIP)
	my loadModules()
	try
		set ip_to_use to Network's getIPAddress(overrideIP)
		my validateParameters(ip_to_use, ollamaPort, modelName)

		if Network's isPortInUse(ollamaPort, ip_to_use) then
			log "An existing server process was found on port " & ollamaPort
			my startChatInExistingServer(ip_to_use, modelName, ollamaPort)
		else
			log "No existing server process found. Starting a new server."
			my startNewServerAndChat(ip_to_use, modelName, ollamaPort)
		end if
	on error error_message
		log "Execution Error: An error occurred: " & error_message
	end try
end runWithConfiguration

-- ==========================================
-- Internal Flow Control Functions (Orchestration)
-- ==========================================
on startChatInExistingServer(ip_address, modelName, ollamaPort)
	set server_info to TerminalManager's findLatestServerWindow(ip_address, ollamaPort)
	set server_window to server_info's window
	set sequence_number to server_info's sequence

	if server_window is not missing value then
		my executeModelInWindow(server_window, ip_address, sequence_number, modelName, ollamaPort)
	else
		log "Server process found, but no corresponding window. Starting new server flow."
		my startNewServerAndChat(ip_address, modelName, ollamaPort)
	end if
end startChatInExistingServer

on startNewServerAndChat(ip_address, modelName, ollamaPort)
	-- 1. 各モジュールに問い合わせ、必要な情報を収集・生成
	set next_seq to (TerminalManager's getMaxSequenceNumber(ip_address, ollamaPort) + 1)
	set server_command to CommandBuilder's buildServerCommand(ip_address, ollamaPort, modelName)
	set server_title to TerminalManager's generateWindowTitle(ip_address, next_seq, "server", ollamaPort, modelName)

	-- 2. TerminalManagerに指示を出し、サーバーを起動
	set new_server_window to TerminalManager's createNewWindowWithCommand(server_command)
	TerminalManager's setTitleOf(new_server_window, server_title)

	-- 3. ServerManagerに指示を出し、サーバーの起動を待つ
	if ServerManager's waitForServer(ip_address, ollamaPort, Network) then
		delay 1
		-- 4. 起動成功後、モデル実行フローへ
		my executeModelInWindow(new_server_window, ip_address, next_seq, modelName, ollamaPort)
	else
		log "Startup Failed: Failed to start the server."
	end if
end startNewServerAndChat

on executeModelInWindow(target_window, ip_address, sequence_number, model_name, ollama_port)
	-- 1. コマンドとタイトルを生成
	set model_command to CommandBuilder's buildModelCommand(ip_address, ollama_port, model_name)
	set tab_title to TerminalManager's generateWindowTitle(ip_address, sequence_number, "chat", ollama_port, model_name)

	-- 2. TerminalManagerに指示を出し、新しいタブでモデルを実行
	set new_tab to TerminalManager's openNewTabInWindow(target_window, model_command)
	TerminalManager's setTitleOf(new_tab, tab_title)
end executeModelInWindow