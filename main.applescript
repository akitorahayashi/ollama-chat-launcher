-- ==========================================
-- Main Properties
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 55764

-- ==========================================
-- Module Loading
-- ==========================================
global Network, WindowManager, ServerManager

set script_path to path to me
set script_folder to (script_path as text) & "::"
set compiled_folder to (script_folder & "build:modules:")

set Network to load script alias (compiled_folder & "Network.scpt")
set WindowManager to load script alias (compiled_folder & "WindowManager.scpt")
set ServerManager to load script alias (compiled_folder & "ServerManager.scpt")

-- ==========================================
-- Main Execution
-- ==========================================
try
	set wifi_ip to Network's getWifiIP()
	if Network's isPortInUse(OLLAMA_PORT) then
		my handleExistingServer(wifi_ip)
	else
		my handleNewServer(wifi_ip)
	end if
on error error_message
	log "Execution Error: An error occurred: " & error_message
end try

-- ==========================================
-- Main Flow Control Functions
-- ==========================================
on handleExistingServer(wifi_ip)
	set server_info to WindowManager's findLatestServerWindow(wifi_ip, OLLAMA_PORT)
	set server_window to server_info's window
	set sequence_number to server_info's sequence
	if server_window is not missing value then
		ServerManager's executeOllamaModel(server_window, wifi_ip, sequence_number, MODEL_NAME, OLLAMA_PORT, WindowManager)
	else
		my handleNewServer(wifi_ip)
	end if
end handleExistingServer

on handleNewServer(wifi_ip)
	set server_info to ServerManager's startOllamaServer(wifi_ip, OLLAMA_PORT, MODEL_NAME, WindowManager)
	set server_window to server_info's window
	set sequence_number to server_info's sequence
	if ServerManager's waitForServer(OLLAMA_PORT, Network) then
		delay 1 -- Wait for the server to fully start
		ServerManager's executeOllamaModel(server_window, wifi_ip, sequence_number, MODEL_NAME, OLLAMA_PORT, WindowManager)
	else
		log "Startup Failed: Failed to start the server."
	end if
end handleNewServer