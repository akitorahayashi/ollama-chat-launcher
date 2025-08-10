-- ==========================================
-- Configuration
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 11434 -- Default Ollama port. Change only if you intentionally use a different instance.
-- Optional: Manually specify the server's IP address. If not set, the Wi-Fi IP is used, falling back to localhost if Wi-Fi is off.
property OVERRIDE_IP_ADDRESS : missing value
-- Optional: Specify a custom path for Ollama models. Use $HOME instead of ~ for reliability.
property OLLAMA_MODELS_PATH : "$HOME/.ollama/models"


-- ==========================================
-- Module Loading
-- ==========================================
global Network, ServerManager, CommandBuilder, WindowManager

on loadModule(moduleName)
	try
		-- Running as App
		set modulePath to (path to resource (moduleName & ".scpt") in directory "Scripts/Modules") as alias
		return load script file modulePath
	on error errMsg number errNum
		set scriptFolderPOSIX to do shell script "dirname " & quoted form of (POSIX path of (path to me))
		set modulePrefixes to {"/Modules/", "/../build/Modules/"}
		set triedPaths to {}
		repeat with prefix in modulePrefixes
			try
				set modulePathPOSIX to scriptFolderPOSIX & prefix & moduleName & ".scpt"
				set end of triedPaths to modulePathPOSIX
				set moduleAlias to POSIX file modulePathPOSIX as alias
				return load script file moduleAlias
			end try
		end repeat
	end
	error "Failed to load module " & moduleName & ". Tried paths: " & (triedPaths as string)
end loadModule

-- ==========================================
-- Parameter Validation
-- ==========================================
on validateParameters(ip_address, port, model_name)
	-- Basic check for IP address format
	if ip_address does not contain "." then
		error "Invalid IP address format: " & ip_address
	end if

	-- Check for port number range
	try
		set port_number to port as integer
		if port_number < 1 or port_number > 65535 then
			error "Port number out of valid range (1-65535): " & port
		end if
	on error
		error "Invalid port number: " & port
	end try

	-- Basic check for model name
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

	-- Securely expand the models path (e.g., $HOME) to a full, absolute path.
	set expanded_models_path to do shell script "/bin/zsh -c " & quoted form of ("echo " & OLLAMA_MODELS_PATH)

	-- Check if the Ollama server is actually running on the specified IP and port
	if ServerManager's isOllamaServerRunning(ip_to_use, OLLAMA_PORT) then
		log "Ollama server is already running on " & ip_to_use & ":" & OLLAMA_PORT & ". Looking for existing window."
		-- Only if the server is running, search for the corresponding window
		set server_info to WindowManager's findLatestServerWindow(ip_to_use, OLLAMA_PORT)

		if server_info's window is not missing value then
			log "Found existing server window. Creating new chat tab."
			ServerManager's executeModelInWindow(server_info's window, ip_to_use, OLLAMA_PORT, MODEL_NAME, CommandBuilder, WindowManager)
		else
			log "Server is running but no corresponding window found. Creating new window and chat tab."
			-- If the server is running but there is no window, start only the chat in a new window
			set server_window to ServerManager's startServer(ip_to_use, OLLAMA_PORT, MODEL_NAME, expanded_models_path, CommandBuilder, WindowManager)
			delay 1
			ServerManager's executeModelInWindow(server_window, ip_to_use, OLLAMA_PORT, MODEL_NAME, CommandBuilder, WindowManager)
		end if

		-- Show dialog and exit if server is already running
		-- display dialog "Ollama server is already running on " & ip_to_use & ":" & OLLAMA_PORT & ".\nPlease use the existing server window." with title "Server Already Running" buttons {"OK"} default button "OK"
		return
	else
		log "No Ollama server running on " & ip_to_use & ":" & OLLAMA_PORT & ". Checking if port is available."
		-- If the server is not running, check if the port is in use
		if Network's isPortInUse(OLLAMA_PORT, ip_to_use) then
			error "Port " & OLLAMA_PORT & " is already in use by another process. Cannot start new server."
		else
			log "Port is available. Starting new server."
			-- If the port is not in use, start the server in a new window
			set server_window to ServerManager's startServer(ip_to_use, OLLAMA_PORT, MODEL_NAME, expanded_models_path, CommandBuilder, WindowManager)
			if ServerManager's waitForServer(ip_to_use, OLLAMA_PORT, Network) then
				delay 1
				log "Server started successfully."
				-- After the server starts, start the model chat in a new tab in the same window
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