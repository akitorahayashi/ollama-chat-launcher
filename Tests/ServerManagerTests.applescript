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

-- Load the modules to be tested
try
	set ServerManager to load script file (modules_path & "ServerManager.scpt")
	set Network to load script file (modules_path & "Network.scpt")
on error err_msg
	log "SETUP ERROR: " & err_msg
	error "Test setup failed: " & err_msg
end try


-- Test waitForServer
-- This test checks the timeout functionality of the waitForServer handler.
try
	log "Testing waitForServer timeout. This will take 30 seconds."
	-- Temporarily override the timeout property for faster testing if possible,
	-- otherwise, we must wait for the full duration.
	-- For this test, we assume the property is not easily mutable from the outside
	-- and we test the actual timeout value.
	set start_time to current date
	set result to ServerManager's waitForServer("127.0.0.1", 54321, Network)
	set end_time to current date
	set duration to end_time - start_time

	if not result then
		log "Test waitForServer (timeout): PASSED - Function returned false as expected."
		if duration > 29 and duration < 32 then
			log "Test waitForServer (timeout duration): PASSED - Test took approximately 30 seconds."
		else
			log "Test waitForServer (timeout duration): FAILED - Test duration was " & duration & " seconds, expected ~30."
		end if
	else
		log "Test waitForServer (timeout): FAILED - Server did not time out."
	end if
on error e
	log "Test waitForServer (timeout): FAILED with error: " & e
end try

-- We can't easily test the success case without starting a real server,
-- which is beyond the scope of this unit test. The timeout case is the
-- most critical to test automatically.
log "ServerManager tests complete."
