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
-- Internal Flow Control
-- ==========================================
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

	-- まずサーバーが起動しているかチェック
	set server_info to WindowManager's findLatestServerWindow(ip_to_use, OLLAMA_PORT)
	if server_info's window is not missing value then
		log "Found existing server window. Creating new chat tab."
		ServerManager's executeModelInWindow(server_info's window, ip_to_use, OLLAMA_PORT, MODEL_NAME, CommandBuilder, WindowManager)
	else
		log "No existing server found. Checking port availability."
		-- サーバーが見つからない場合、ポートが使われているかチェック
		if Network's isPortInUse(OLLAMA_PORT, ip_to_use) then
			log "Error: Port " & OLLAMA_PORT & " is already in use on " & ip_to_use
			error "Port " & OLLAMA_PORT & " is already in use. Please use a different port or stop the existing process."
		end if

		-- ポートが使われていない場合、新しいサーバーを起動
		log "Port is available. Starting new server."
		set server_window to ServerManager's startServer(ip_to_use, OLLAMA_PORT, MODEL_NAME, CommandBuilder, WindowManager)
		if ServerManager's waitForServer(ip_to_use, OLLAMA_PORT, Network) then
			delay 1
			log "Server started successfully."
			set next_seq to (WindowManager's getMaxSequenceNumber(ip_to_use, OLLAMA_PORT))
			ServerManager's executeModelInWindow(server_window, ip_to_use, OLLAMA_PORT, MODEL_NAME, CommandBuilder, WindowManager)
		else
			log "Startup Failed: Failed to start the server."
		end if
	end if
on error error_message
	log "Execution Error: " & error_message
	error error_message
end try