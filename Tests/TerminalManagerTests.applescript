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
	set TerminalManager to load script file (modules_path & "TerminalManager.scpt")
on error err_msg
	log "SETUP ERROR: " & err_msg
	error "Test setup failed: " & err_msg
end try

-- Helper to wait for a condition to become true, to avoid flaky tests with fixed delays
on wait_for_condition(condition_script, timeout_seconds)
	set end_time to (current date) + timeout_seconds
	repeat while (current date) < end_time
		try
			if (run script condition_script) then return true
		end try
		delay 0.2
	end repeat
	return false
end wait_for_condition

-- Robust cleanup handler for Terminal windows
on cleanup_window(target_window)
	try
		tell application "Terminal"
			if target_window exists then
				close target_window
			end if
		end tell
	on error e
		log "Ignoring error during window cleanup: " & e
	end try
end cleanup_window


log "MANUAL TEST: The following tests for TerminalManager require manual observation."
log "MANUAL TEST: They will open new Terminal windows and tabs, and set their titles."

-- Test createNewWindowWithCommand
set new_window to missing value
try
	log "Testing createNewWindowWithCommand..."
	tell application "Terminal"
		set window_count_before to count of windows
	end tell

	set new_window to TerminalManager's createNewWindowWithCommand("echo 'Hello from createNewWindowWithCommand test'")

	-- Wait for the new window to appear
	set condition to "tell application \"Terminal\" to return (count of windows) > " & window_count_before
	if not my wait_for_condition(condition, 5) then
		error "Window did not appear within the timeout."
	end if

	tell application "Terminal"
		log "Test createNewWindowWithCommand: PASSED"

		-- Test setTitleOf on the new window
		log "Testing setTitleOf for a window..."
		TerminalManager's setTitleOf(new_window, "Test Window Title")
		delay 0.5 -- A short delay for title to apply is acceptable
		if custom title of new_window is "Test Window Title" then
			log "Test setTitleOf (window): PASSED"
		else
			log "Test setTitleOf (window): FAILED"
		end if
	end tell
on error e
	log "Test createNewWindowWithCommand or setTitleOf (window): FAILED with error: " & e
finally
	my cleanup_window(new_window)
end try


-- Test openNewTabInWindow and setTitleOf for tabs
set parent_window to missing value
try
	log "Testing openNewTabInWindow..."
	-- Create a new window to work in
	tell application "Terminal"
		activate
		set parent_window to do script ""
		set tabs_before to count of tabs of parent_window
		set parent_id to id of parent_window
	end tell

	set new_tab to TerminalManager's openNewTabInWindow(parent_window, "echo 'Hello from openNewTabInWindow test'")

	-- Wait for the new tab to appear
	set condition to "tell application \"Terminal\" to return (count of tabs of window id " & parent_id & ") > " & tabs_before
	if not my wait_for_condition(condition, 5) then
		error "Tab did not appear within the timeout."
	end if

	tell application "Terminal"
		log "Test openNewTerminalTab: PASSED"

		-- Test setTitleOf on the new tab
		log "Testing setTitleOf for a tab..."
		TerminalManager's setTitleOf(new_tab, "Test Tab Title")
		delay 0.5 -- A short delay for title to apply is acceptable
		if custom title of new_tab is "Test Tab Title" then
			log "Test setTitleOf (tab): PASSED"
		else
			log "Test setTitleOf (tab): FAILED"
		end if
	end tell
on error e
	log "Test openNewTabInWindow or setTitleOf (tab): FAILED with error: " & e
finally
	my cleanup_window(parent_window)
end try

-- =================================================
-- Tests from former WindowManagerTests.applescript
-- =================================================

-- Test generateWindowTitle
try
	set title1 to TerminalManager's generateWindowTitle("192.168.1.1", 1, "server", 8080, "tinyllama")
	if title1 is "Ollama Server #1 [192.168.1.1:8080]" then
		log "Test generateWindowTitle (server): PASSED"
	else
		log "Test generateWindowTitle (server): FAILED - Expected 'Ollama Server #1 [192.168.1.1:8080]', got '" & title1 & "'"
	end if
on error e
	log "Test generateWindowTitle (server): FAILED - " & e
end try

try
	-- Test for chat window title
	set title2 to TerminalManager's generateWindowTitle("192.168.1.1", 2, "chat", 8080, "tinyllama")
	if title2 is "Ollama Chat #2 [192.168.1.1:8080] (tinyllama)" then
		log "Test generateWindowTitle (chat): PASSED"
	else
		log "Test generateWindowTitle (chat): FAILED - Unexpected title: " & title2
	end if
on error e
	log "Test generateWindowTitle (chat): FAILED - " & e
end try

-- The following tests require a running Terminal application and will create windows.
-- Test getMaxSequenceNumber
set test_window to missing value
try
	log "Testing getMaxSequenceNumber..."
	-- Programmatically create a dummy window for the test
	tell application "Terminal"
		activate
		set test_window to do script ""
		set custom title of test_window to "Ollama Server #3 [127.0.0.1:12345]"
	end tell
	delay 0.5 -- Give terminal time to process

	set max_seq to TerminalManager's getMaxSequenceNumber("127.0.0.1", 12345)

	if max_seq is 3 then
		log "Test getMaxSequenceNumber: PASSED"
	else
		log "Test getMaxSequenceNumber: FAILED - Expected 3, got " & max_seq
	end if
on error e
	log "Test getMaxSequenceNumber: FAILED - " & e
finally
	my cleanup_window(test_window)
end try

-- Test findLatestServerWindow
set test_window to missing value
try
	log "Testing findLatestServerWindow..."
	-- Programmatically create a dummy window for the test
	tell application "Terminal"
		activate
		set test_window to do script ""
		set custom title of test_window to "Ollama Server #5 [127.0.0.1:54321]"
	end tell
	delay 0.5 -- Give terminal time to process

	set server_info to TerminalManager's findLatestServerWindow("127.0.0.1", 54321)


	if server_info's sequence is 5 then
		log "Test findLatestServerWindow: PASSED"
	else
		log "Test findLatestServerWindow: FAILED - Expected sequence 5, got " & server_info's sequence
	end if
on error e
	log "Test findLatestServerWindow: FAILED - " & e
finally
	my cleanup_window(test_window)
end try


log "TerminalManager tests complete."
