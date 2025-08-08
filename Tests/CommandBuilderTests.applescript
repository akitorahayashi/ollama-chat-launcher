-- Get the path to the parent directory of the current script's directory (i.e., the project root)
on get_project_root()
	set script_path to path to me
	tell application "Finder"
		set script_container to container of script_path as text
		set project_root to container of (alias script_container) as text
	end tell
	return project_root
end get_project_root

set project_root to my get_project_root()
set modules_path to project_root & "Sources:Modules:"

-- Load the module to be tested
try
	set CommandBuilder to load script file (modules_path & "CommandBuilder.applescript")
on error err_msg
	log "SETUP ERROR: " & err_msg
	return
end try


-- Test buildServerCommand
try
	log "Testing buildServerCommand..."
	set ip to "192.168.1.10"
	set port to "11434"
	set model to "llama3"
	set expected_command to "echo '--- Private LLM Launcher ---'; echo 'IP Address: 192.168.1.10'; echo 'Port: 11434'; echo 'Model: llama3'; echo '--------------------------'; echo 'Starting Ollama server...'; OLLAMA_HOST=192.168.1.10:11434 ollama serve"
	set actual_command to CommandBuilder's buildServerCommand(ip, port, model)

	if actual_command = expected_command then
		log "Test buildServerCommand: PASSED"
	else
		log "Test buildServerCommand: FAILED"
		log "Expected: " & expected_command
		log "Actual:   " & actual_command
	end if
on error e
	log "Test buildServerCommand: FAILED with error: " & e
end try


-- Test buildModelCommand
try
	log "Testing buildModelCommand..."
	set ip to "127.0.0.1"
	set port to "8080"
	set model to "mistral"
	set expected_command to "OLLAMA_HOST=http://127.0.0.1:8080 ollama run mistral"
	set actual_command to CommandBuilder's buildModelCommand(ip, port, model)

	if actual_command = expected_command then
		log "Test buildModelCommand: PASSED"
	else
		log "Test buildModelCommand: FAILED"
		log "Expected: " & expected_command
		log "Actual:   " & actual_command
	end if
on error e
	log "Test buildModelCommand: FAILED with error: " & e
end try

log "CommandBuilder tests complete."
