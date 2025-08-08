-- ==========================================
-- ==========================================
-- Module Loading
-- ==========================================
global Network, WindowManager, ServerManager

on loadModules()
	set script_path to path to me
	tell application "Finder"
		set script_container to container of script_path as text
	end tell
	set compiled_modules_folder to (script_container & "build:modules:")

	set Network to load script alias (compiled_modules_folder & "Network.scpt")
	set WindowManager to load script alias (compiled_modules_folder & "WindowManager.scpt")
	set ServerManager to load script alias (compiled_modules_folder & "ServerManager.scpt")
end loadModules

-- ==========================================
-- Public API
-- ==========================================
on runWithConfiguration(modelName, ollamaPort, overrideIP)
	my loadModules()
	try
		set ip_to_use to Network's getIPAddress(overrideIP)

		if Network's isPortInUse(ollamaPort, ip_to_use) then
			my handleExistingServer(ip_to_use, modelName, ollamaPort)
		else
			my handleNewServer(ip_to_use, modelName, ollamaPort)
		end if
	on error error_message
		log "Execution Error: An error occurred: " & error_message
	end try
end runWithConfiguration

-- ==========================================
-- Internal Flow Control Functions
-- ==========================================
on handleExistingServer(ip_address, modelName, ollamaPort)
	set server_info to WindowManager's findLatestServerWindow(ip_address, ollamaPort)
	set server_window to server_info's window
	set sequence_number to server_info's sequence
	if server_window is not missing value then
		ServerManager's executeOllamaModel(server_window, ip_address, sequence_number, modelName, ollamaPort, WindowManager)
	else
		my handleNewServer(ip_address, modelName, ollamaPort)
	end if
end handleExistingServer

on handleNewServer(ip_address, modelName, ollamaPort)
	set server_info to ServerManager's startOllamaServer(ip_address, ollamaPort, modelName, WindowManager)
	set server_window to server_info's window
	set sequence_number to server_info's sequence
	if ServerManager's waitForServer(ip_address, ollamaPort, Network) then
		delay 1 -- Wait for the server to fully start
		ServerManager's executeOllamaModel(server_window, ip_address, sequence_number, modelName, ollamaPort, WindowManager)
	else
		log "Startup Failed: Failed to start the server."
	end if
end handleNewServer