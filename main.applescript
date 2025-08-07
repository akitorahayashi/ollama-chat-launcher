-- ==========================================
-- Main Properties
-- ==========================================
property MODEL_NAME : "gemma3:latest"
property OLLAMA_PORT : 55764

-- ==========================================
-- Module Loading
-- ==========================================
set script_path to path to me
set script_folder to (script_path as text) & "::"

set compiled_folder to (script_folder & "build:modules:")
set Network to load script file (compiled_folder & "Network.scpt")
set WindowManager to load script file (compiled_folder & "WindowManager.scpt")
set ServerManager to load script file (compiled_folder & "ServerManager.scpt")

-- ==========================================
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
	log "実行エラー: エラーが発生しました: " & error_message
end try

-- ==========================================
-- メインフロー制御関数群
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
		delay 1 -- サーバー完全起動のための待機
		ServerManager's executeOllamaModel(server_window, wifi_ip, sequence_number, MODEL_NAME, OLLAMA_PORT, WindowManager)
	else
		log "起動失敗: サーバーの起動に失敗しました。"
	end if
end handleNewServer