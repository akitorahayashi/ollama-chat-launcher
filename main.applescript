-- ==========================================
-- Main Properties
-- ==========================================
property MODEL_NAME : "gemma3:latest"
property OLLAMA_PORT : 55764
property SERVER_STARTUP_TIMEOUT : 30
property SERVER_CHECK_INTERVAL : 0.1

-- ==========================================
-- Module Loading
-- ==========================================
-- Get the path to the folder containing this script to build relative paths.
-- This makes the script portable.
set script_path to path to me
set script_folder to (script_path as text) & "::"

-- Load the modules using the robust `load script` command.
set Net to load script file (script_folder & "Modules:Network.applescript")
set Win to load script file (script_folder & "Modules:WindowManager.applescript")
set Server to load script file (script_folder & "Modules:ServerManager.applescript")

-- ==========================================
-- Dependency Injection
-- ==========================================
-- Inject constants into the WindowManager module.
set Win's OLLAMA_PORT to OLLAMA_PORT
set Win's MODEL_NAME to MODEL_NAME

-- Inject constants and other modules into the ServerManager module.
set Server's OLLAMA_PORT to OLLAMA_PORT
set Server's MODEL_NAME to MODEL_NAME
set Server's SERVER_STARTUP_TIMEOUT to SERVER_STARTUP_TIMEOUT
set Server's SERVER_CHECK_INTERVAL to SERVER_CHECK_INTERVAL
set Server's Net to Net
set Server's Win to Win

-- ==========================================
-- Main Execution
-- ==========================================
try
	set wifi_ip to Net's getWifiIP()
	if Net's isPortInUse(OLLAMA_PORT) then
		my handleExistingServer(wifi_ip)
	else
		my handleNewServer(wifi_ip)
	end if
on error error_message
	log "実行エラー: エラーが発生しました: " & error_message
end try

-- ==========================================
-- メインフロー制御関数群
-- ==========================================
on handleExistingServer(wifi_ip)
	set server_info to Win's findLatestServerWindow(wifi_ip)
	set server_window to server_info's window
	set sequence_number to server_info's sequence
	if server_window is not missing value then
		Server's executeOllamaModel(server_window, wifi_ip, sequence_number)
	else
		my handleNewServer(wifi_ip)
	end if
end handleExistingServer

on handleNewServer(wifi_ip)
	set server_info to Server's startOllamaServer(wifi_ip)
	set server_window to server_info's window
	set sequence_number to server_info's sequence
	if Server's waitForServer() then
		delay 1 -- サーバー完全起動のための待機
		Server's executeOllamaModel(server_window, wifi_ip, sequence_number)
	else
		log "起動失敗: サーバーの起動に失敗しました。"
	end if
end handleNewServer