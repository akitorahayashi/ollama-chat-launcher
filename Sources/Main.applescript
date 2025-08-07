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
	set compiled_modules_folder to (script_container & "modules:")

	set Network to load script alias (compiled_modules_folder & "Network.scpt")
	set WindowManager to load script alias (compiled_modules_folder & "WindowManager.scpt")
	set ServerManager to load script alias (compiled_modules_folder & "ServerManager.scpt")
end loadModules

-- ==========================================
-- Public API
-- ==========================================
on runWithConfiguration(modelName, ollamaPort)
	my loadModules()
	try
		set wifi_ip to Network's getWifiIP()
		if Network's isPortInUse(ollamaPort) then
			my handleExistingServer(wifi_ip, modelName, ollamaPort)
		else
			my handleNewServer(wifi_ip, modelName, ollamaPort)
		end if
	on error error_message
		log "Execution Error: An error occurred: " & error_message
	end try
end runWithConfiguration

-- ==========================================
-- Internal Flow Control Functions
-- ==========================================
on handleExistingServer(wifi_ip, modelName, ollamaPort)
	set server_info to WindowManager's findLatestServerWindow(wifi_ip, ollamaPort)
	set server_window to server_info's window
	set sequence_number to server_info's sequence
	if server_window is not missing value then
		ServerManager's executeOllamaModel(server_window, wifi_ip, sequence_number, modelName, ollamaPort, WindowManager)
	else
		my handleNewServer(wifi_ip, modelName, ollamaPort)
	end if
end handleExistingServer

on handleNewServer(wifi_ip, modelName, ollamaPort)
	set server_info to ServerManager's startOllamaServer(wifi_ip, ollamaPort, modelName, WindowManager)
	set server_window to server_info's window
	set sequence_number to server_info's sequence
	if ServerManager's waitForServer(ollamaPort, Network) then
		delay 1 -- Wait for the server to fully start
		ServerManager's executeOllamaModel(server_window, wifi_ip, sequence_number, modelName, ollamaPort, WindowManager)
	else
		log "Startup Failed: Failed to start the server."
	end if
end handleNewServer