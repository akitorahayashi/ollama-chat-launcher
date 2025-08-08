-- ==========================================
-- Configuration
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 55764

-- ==========================================
-- Main Logic
-- ==========================================
try
  tell application "Finder"
    set project_folder to (container of (path to me)) as text
  end tell
  set main_lib_path to (project_folder & "build:Main.scpt")

  set MainLib to load script alias main_lib_path
  MainLib's runWithConfiguration(MODEL_NAME, OLLAMA_PORT)

on error err
  log "Error in Tinyllama entry point: " & err
end try
