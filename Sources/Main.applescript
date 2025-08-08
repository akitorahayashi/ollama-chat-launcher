-- ==========================================
-- Configuration
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 55764
-- Optional: Manually specify the server's IP address. If not set, the Wi-Fi IP is used, falling back to localhost if Wi-Fi is off.
property OVERRIDE_IP_ADDRESS : missing value


-- ==========================================
-- Module Loading
-- ==========================================
global Network, ServerManager, CommandRunner, WindowManager

on loadModule(moduleName)
	try
		-- If running as an app, load from the bundle's Resources
		set modulePath to (path to resource (moduleName & ".scpt")) as text
	on error errMsg number errNum
		-- If running from Script Editor, load .applescript file from the development folder
		try
			tell application "Finder"
				set scriptFolder to container of (path to me) as text
			end tell
			set modulePath to scriptFolder & "Modules:" & moduleName & ".applescript"
		on error innerErrMsg number innerErrNum
			error "Failed to determine module path: " & innerErrMsg number innerErrNum
		end try
	end try

	-- Load the module
	try
		return load script file modulePath
	on error loadErrMsg loadErrNum
		error "Failed to load script file at " & modulePath & ": " & loadErrMsg number loadErrNum
	end try
end loadModule

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
-- Internal Flow Control
-- ==========================================
on startServer(ip_address, modelName, ollamaPort)
	-- 1. 各モジュールに問い合わせ、必要な情報を収集・生成
	set next_seq to (WindowManager's getMaxSequenceNumber(ip_address, ollamaPort) + 1)
	set server_command to CommandRunner's buildServerCommand(ip_address, ollamaPort, modelName)
	set server_title to WindowManager's generateWindowTitle(ip_address, next_seq, ollamaPort, modelName)

	-- 2. WindowManagerでウィンドウを作成し、タイトルを設定
	set new_server_window to WindowManager's createNewWindow(server_title)
	
	-- 3. CommandRunnerでコマンドを実行
	CommandRunner's executeCommand(new_server_window, server_command)

	-- 4. ServerManagerに指示を出し、サーバーの起動を待つ
	if ServerManager's waitForServer(ip_address, ollamaPort, Network) then
		delay 1
		log "Server started successfully."
		return new_server_window
	else
		log "Startup Failed: Failed to start the server."
		return missing value
	end if
end startServer

on executeModelInWindow(target_window, ip_address, sequence_number, model_name, ollama_port)
	-- 1. コマンドを生成
	set model_command to CommandRunner's buildModelCommand(ip_address, ollama_port, model_name)
	
	-- 2. タブ番号を取得してタイトルを生成
	tell application "Terminal"
		set tab_count to count of tabs of target_window
	end tell
	set tab_title to WindowManager's generateTabTitle(tab_count + 1, model_name)
	
	-- 3. WindowManagerで新しいタブを作成
	set new_tab to WindowManager's openNewTabInWindow(target_window, tab_title)
	
	-- 4. CommandRunnerでコマンドを実行
	CommandRunner's executeCommand(new_tab, model_command)
end executeModelInWindow

-- ==========================================
-- Main Execution Block
-- ==========================================
try
	-- Load all modules
	set Network to my loadModule("Network")
	set ServerManager to my loadModule("ServerManager")
	set CommandRunner to my loadModule("CommandRunner")
	set WindowManager to my loadModule("WindowManager")

	set ip_to_use to Network's getIPAddress(OVERRIDE_IP_ADDRESS)
	my validateParameters(ip_to_use, OLLAMA_PORT, MODEL_NAME)

	-- まずサーバーが起動しているかチェック
	set server_info to WindowManager's findLatestServerWindow(ip_to_use, OLLAMA_PORT)
	if server_info's window is not missing value then
		log "Found existing server window. Creating new chat tab."
		my executeModelInWindow(server_info's window, ip_to_use, server_info's sequence, MODEL_NAME, OLLAMA_PORT)
	else
		log "No existing server found. Checking port availability."
		-- サーバーが見つからない場合、ポートが使われているかチェック
		if Network's isPortInUse(OLLAMA_PORT, ip_to_use) then
			log "Error: Port " & OLLAMA_PORT & " is already in use on " & ip_to_use
			error "Port " & OLLAMA_PORT & " is already in use. Please use a different port or stop the existing process."
		end if

		-- ポートが使われていない場合、新しいサーバーを起動
		log "Port is available. Starting new server."
		set server_window to my startServer(ip_to_use, MODEL_NAME, OLLAMA_PORT)
		if server_window is not missing value then
			set next_seq to (WindowManager's getMaxSequenceNumber(ip_to_use, OLLAMA_PORT))
			my executeModelInWindow(server_window, ip_to_use, next_seq, MODEL_NAME, OLLAMA_PORT)
		end if
	end if
on error error_message
	log "Execution Error: " & error_message
	error error_message
end try