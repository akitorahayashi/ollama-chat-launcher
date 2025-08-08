-- ==========================================
-- Configuration
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 55765  
-- Optional: Manually specify the server's IP address. If not set, the Wi-Fi IP is used, falling back to localhost if Wi-Fi is off.
property OVERRIDE_IP_ADDRESS : missing value


-- ==========================================
-- Module Loading
-- ==========================================
global Network, ServerManager, CommandBuilder, WindowManager

on loadModule(moduleName)
	try
		-- If running as an app, load from the bundle's Resources
		set modulePath to (path to resource (moduleName & ".scpt")) as text
		return load script file modulePath
	on error errMsg number errNum
		-- If running from Script Editor, load .scpt file from the build/modules folder
		try
			tell application "Finder"
				set scriptFolder to container of (path to me) as text
				-- Go up one level from Sources to project root, then to build/modules
				set projectRoot to container of (scriptFolder as alias) as text
			end tell
			set modulePath to projectRoot & "build:modules:" & moduleName & ".scpt"
			return load script file modulePath
		on error innerErrMsg number innerErrNum
			error "Failed to load module " & moduleName & ": " & innerErrMsg number innerErrNum
		end try
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
-- Main Execution Block
-- ==========================================
try
	-- Load all modules
	set Network to my loadModule("Network")
	set ServerManager to my loadModule("ServerManager")
	set CommandBuilder to my loadModule("CommandBuilder")
	set WindowManager to my loadModule("WindowManager")

	set ip_to_use to Network's getIPAddress(OVERRIDE_IP_ADDRESS)
	my validateParameters(ip_to_use, OLLAMA_PORT, MODEL_NAME)

	-- 指定されたIP・ポートでOllamaサーバーが実際に起動しているかチェック
	if ServerManager's isOllamaServerRunning(ip_to_use, OLLAMA_PORT) then
		log "Ollama server is already running on " & ip_to_use & ":" & OLLAMA_PORT & ". Looking for existing window."
		-- サーバーが動いている場合のみ、対応するウィンドウを探す
		set server_info to WindowManager's findLatestServerWindow(ip_to_use, OLLAMA_PORT)
		if server_info's window is not missing value then
			log "Found existing server window. Creating new chat tab."
			ServerManager's executeModelInWindow(server_info's window, ip_to_use, OLLAMA_PORT, MODEL_NAME, CommandBuilder, WindowManager)
		else
			log "Server is running but no corresponding window found. Creating new window and chat tab."
			-- サーバーは動いているがウィンドウがない場合、新しいウィンドウでチャットのみ開始
			set server_window to ServerManager's startServer(ip_to_use, OLLAMA_PORT, MODEL_NAME, CommandBuilder, WindowManager)
			delay 1
			ServerManager's executeModelInWindow(server_window, ip_to_use, OLLAMA_PORT, MODEL_NAME, CommandBuilder, WindowManager)
		end if
	else
		log "No Ollama server running on " & ip_to_use & ":" & OLLAMA_PORT & ". Checking if port is available."
		-- サーバーが動いていない場合、ポートが使用中かチェック
		if Network's isPortInUse(OLLAMA_PORT, ip_to_use) then
			error "Port " & OLLAMA_PORT & " is already in use by another process. Cannot start new server."
		else
			log "Port is available. Starting new server."
			-- ポートが使用されていない場合、新しいウィンドウでサーバーを起動
			set server_window to ServerManager's startServer(ip_to_use, OLLAMA_PORT, MODEL_NAME, CommandBuilder, WindowManager)
			if ServerManager's waitForServer(ip_to_use, OLLAMA_PORT, Network) then
				delay 1
				log "Server started successfully."
				-- サーバー起動後、同じウィンドウに新しいタブでモデルチャットを開始
				ServerManager's executeModelInWindow(server_window, ip_to_use, OLLAMA_PORT, MODEL_NAME, CommandBuilder, WindowManager)
			else
				log "Startup Failed: Failed to start the server."
			end if
		end if
	end if
on error error_message
	log "Execution Error: " & error_message
	error error_message
end try