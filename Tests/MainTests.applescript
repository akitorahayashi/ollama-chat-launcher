-- Get the path to the parent directory of -- Run test cases
set test_results to {}

-- Run test cases
set test_results to test_results & {my test_validation_case("Valid parameters", "127.0.0.1", "11434", "tinyllama", false)}
set test_results to test_results & {my test_validation_case("Invalid IP address", "localhost", "11434", "tinyllama", true)}
set test_results to test_results & {my test_validation_case("Invalid port (non-numeric)", "127.0.0.1", "abc", "tinyllama", true)}
set test_results to test_results & {my test_validation_case("Invalid port (too low)", "127.0.0.1", "0", "tinyllama", true)}
set test_results to test_results & {my test_validation_case("Invalid port (too high)", "127.0.0.1", "65536", "tinyllama", true)}
set test_results to test_results & {my test_validation_case("Invalid model name (empty)", "127.0.0.1", "11434", "", true)}t script's directory (i.e., the project root)

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
	set Main to load script file (project_root & "build:Main.scpt")
on error err_msg
	log "SETUP ERROR: " & err_msg
	error "Test setup failed: " & err_msg
end try

-- Helper handler to test for expected errors
on test_validation_case(test_name, test_ip, test_port, test_model, should_fail)
	try
		log "Testing validation: " & test_name & "..."
		Main's validateParameters(test_ip, test_port, test_model)
		if should_fail then
			log "Test " & test_name & ": FAILED - Expected an error, but none occurred."
			return false
		else
			log "Test " & test_name & ": PASSED"
			return true
		end if
	on error e
		if should_fail then
			log "Test " & test_name & ": PASSED - Correctly failed with error: " & e
			return true
		else
			log "Test " & test_name & ": FAILED - Unexpected error: " & e
			return false
		end if
	end try
end test_validation_case

-- Track test results
set test_results to {}

-- Run test cases
set test_results to test_results & {my test_validation_case("Valid parameters", "127.0.0.1", "11434", "llama3", false)}
set test_results to test_results & {my test_validation_case("Invalid IP address", "localhost", "11434", "llama3", true)}
set test_results to test_results & {my test_validation_case("Invalid port (non-numeric)", "127.0.0.1", "abc", "llama3", true)}
set test_results to test_results & {my test_validation_case("Invalid port (too low)", "127.0.0.1", "0", "llama3", true)}
set test_results to test_results & {my test_validation_case("Invalid port (too high)", "127.0.0.1", "65536", "llama3", true)}
set test_results to test_results & {my test_validation_case("Invalid model name (empty)", "127.0.0.1", "11434", "", true)}

-- Check if any tests failed
repeat with result in test_results
	if result is false then
		log "Some tests failed."
		error "Test suite failed"
	end if
end repeat

log "Main script validation tests complete."
