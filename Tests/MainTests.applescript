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

-- Load the Main script as a library
try
	set Main to load script file (project_root & "Sources:Main.applescript")
on error err_msg
	log "SETUP ERROR: " & err_msg
	return
end try

-- Helper handler to test for expected errors
on test_validation_case(test_name, ip, port, model, should_fail)
	try
		log "Testing validation: " & test_name & "..."
		Main's validateParameters(ip, port, model)
		if should_fail then
			log "Test " & test_name & ": FAILED - Expected an error, but none occurred."
		else
			log "Test " & test_name & ": PASSED"
		end if
	on error e
		if should_fail then
			log "Test " & test_name & ": PASSED - Correctly failed with error: " & e
		else
			log "Test " & test_name & ": FAILED - Unexpected error: " & e
		end if
	end try
end test_validation_case

-- Run test cases
my test_validation_case("Valid parameters", "127.0.0.1", "11434", "llama3", false)
my test_validation_case("Invalid IP address", "localhost", "11434", "llama3", true)
my test_validation_case("Invalid port (non-numeric)", "127.0.0.1", "abc", "llama3", true)
my test_validation_case("Invalid port (too low)", "127.0.0.1", "0", "llama3", true)
my test_validation_case("Invalid port (too high)", "127.0.0.1", "65536", "llama3", true)
my test_validation_case("Invalid model name (empty)", "127.0.0.1", "11434", "", true)

log "Main script validation tests complete."
