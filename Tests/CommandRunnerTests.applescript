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
set modules_path to project_root & "build:modules:"

-- Load the module to be tested
try
	set CommandRunner to load script file (modules_path & "CommandRunner.scpt")
on error err_msg
	log "SETUP ERROR: " & err_msg
	error "Test setup failed: " & err_msg
end try


-- Test buildServerCommand
try
	log "Testing buildServerCommand..."
	set test_ip to "192.168.1.10"
	set test_port to "11434"
	set test_model to "tinyllama"
	-- Note: The display part of the command still uses unescaped params, which is correct.
	-- The executable part uses escaped params.
	set expected_command to "echo '--- Private LLM Launcher ---'; echo 'IP Address: 192.168.1.10'; echo 'Port: 11434'; echo 'Model: tinyllama'; echo '--------------------------'; echo 'Starting Ollama server...'; OLLAMA_HOST=http://'192.168.1.10':'11434' ollama serve"
	set actual_command to CommandRunner's buildServerCommand(test_ip, test_port, test_model)

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
	set test_ip to "127.0.0.1"
	set test_port to "8080"
	set test_model to "tinyllama"
	set expected_command to "OLLAMA_HOST=http://'127.0.0.1':'8080' ollama run 'tinyllama'"
	set actual_command to CommandRunner's buildModelCommand(test_ip, test_port, test_model)

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

-- Test escaping of potentially malicious input
try
	log "Testing buildModelCommand with malicious input..."
	set test_ip to "127.0.0.1"
	set test_port to "8080"
	set test_model to "nonexistent; reboot"
	set expected_command to "OLLAMA_HOST=http://'127.0.0.1':'8080' ollama run 'nonexistent; reboot'"
	set actual_command to CommandRunner's buildModelCommand(test_ip, test_port, test_model)

	if actual_command = expected_command then
		log "Test buildModelCommand (malicious input): PASSED"
	else
		log "Test buildModelCommand (malicious input): FAILED"
		log "Expected: " & expected_command
		log "Actual:   " & actual_command
	end if
on error e
	log "Test buildModelCommand (malicious input): FAILED with error: " & e
end try


log "CommandRunner tests complete."
