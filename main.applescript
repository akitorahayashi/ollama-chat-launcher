-- =================================================================
-- Ollama Launcher Main Script
-- =================================================================
-- This script is the entry point for the Ollama Launcher.
-- It loads functional modules and controls the main execution flow.
-- =================================================================

-- ------------------------------------------
-- Global Properties
-- ------------------------------------------
property MODEL_NAME : "gemma3:latest"
property OLLAMA_PORT : 55764
property SERVER_STARTUP_TIMEOUT : 30
property SERVER_CHECK_INTERVAL : 0.1

-- Module Placeholders
property Utils : missing value
property NetworkManager : missing value
property TerminalManager : missing value
property WindowManager : missing value
property OllamaManager : missing value


-- ==========================================
-- Main Execution Block
-- ==========================================
-- This top-level block loads modules and executes the main logic directly.

try
	-- ------------------------------------------
	-- Load Modules and Inject Dependencies
	-- ------------------------------------------
	-- Get the path to the folder containing this script for robust module loading
	tell application "Finder"
		set script_folder_path to (container of (path to me)) as string
	end tell

	set my Utils to load script file (script_folder_path & "Modules:Utils.applescript")
	set my NetworkManager to load script file (script_folder_path & "Modules:NetworkManager.applescript")
	set my TerminalManager to load script file (script_folder_path & "Modules:TerminalManager.applescript")
	set my WindowManager to load script file (script_folder_path & "Modules:WindowManager.applescript")
	set my OllamaManager to load script file (script_folder_path & "Modules:OllamaManager.applescript")

	-- Set the parent for each module to enable inter-module communication
	set parent of my Utils to me
	set parent of my NetworkManager to me
	set parent of my TerminalManager to me
	set parent of my WindowManager to me
	set parent of my OllamaManager to me

	-- ------------------------------------------
	-- Main Process Flow
	-- ------------------------------------------
	set wifi_ip to my NetworkManager's getWifiIP()

	if my NetworkManager's isPortInUse(OLLAMA_PORT) then
		my OllamaManager's handleExistingServer(wifi_ip)
	else
		my OllamaManager's handleNewServer(wifi_ip)
	end if

on error error_message
	-- If an error occurs, use the Utils module to display a dialog if it's loaded.
	if my Utils is not missing value then
		my Utils's showError("実行エラー", "エラーが発生しました: " & error_message, stop)
	else
		-- Fallback if modules failed to load
		display dialog "致命的なエラー: " & error_message buttons {"OK"} default button "OK" with title "実行エラー" with icon stop
	end if
end try