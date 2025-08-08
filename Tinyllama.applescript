-- ==========================================
-- Configuration
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 55764
-- Optional: Manually specify the IP address for the server.
-- If set to 'missing value', the script will automatically use the active
-- Wi-Fi IP address, or fall back to localhost (127.0.0.1).
-- This is useful for setups like macOS Internet Sharing (e.g., "192.168.2.1").
-- Example: property OVERRIDE_IP_ADDRESS : "192.168.2.1"
property OVERRIDE_IP_ADDRESS : missing value

-- ==========================================
-- Main Logic
-- ==========================================
try
	tell application "Finder"
		set project_folder to (container of (path to me)) as text
	end tell
	set main_lib_path to (project_folder & "build:Main.scpt")

	set MainLib to load script alias main_lib_path
	MainLib's runWithConfiguration(MODEL_NAME, OLLAMA_PORT, OVERRIDE_IP_ADDRESS)

on error err
	log "Error in Tinyllama entry point: " & err
end try
