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
	set TerminalManager to load script file (modules_path & "TerminalManager.applescript")
on error err_msg
	log "SETUP ERROR: " & err_msg
	return
end try


log "MANUAL TEST: The following tests for TerminalManager require manual observation."
log "MANUAL TEST: They will open new Terminal windows and tabs, and set their titles."

-- Test createNewWindowWithCommand
try
	log "Testing createNewWindowWithCommand..."
	tell application "Terminal"
		set window_count_before to count of windows
	end tell

	set new_window to TerminalManager's createNewWindowWithCommand("echo 'Hello from createNewWindowWithCommand test'")
	delay 1 -- Give time for the window to appear

	tell application "Terminal"
		set window_count_after to count of windows
		if window_count_after > window_count_before then
			log "Test createNewWindowWithCommand: PASSED"
		else
			log "Test createNewWindowWithCommand: FAILED - Window count did not increase"
		end if

		-- Test setTitleOf on the new window
		log "Testing setTitleOf for a window..."
		TerminalManager's setTitleOf(new_window, "Test Window Title")
		delay 0.5
		if custom title of new_window is "Test Window Title" then
			log "Test setTitleOf (window): PASSED"
		else
			log "Test setTitleOf (window): FAILED"
		end if

		-- Clean up the created window
		if new_window is not missing value then
			close new_window
		end if
	end tell
on error e
	log "Test createNewWindowWithCommand or setTitleOf (window): FAILED with error: " & e
end try


-- Test openNewTabInWindow and setTitleOf for tabs
try
	log "Testing openNewTabInWindow..."
	-- Create a new window to work in
	tell application "Terminal"
		activate
		set parent_window to do script ""
		set tabs_before to count of tabs of parent_window
	end tell
	delay 1

	set new_tab to TerminalManager's openNewTabInWindow(parent_window, "echo 'Hello from openNewTabInWindow test'")
	delay 1

	tell application "Terminal"
		set tabs_after to count of tabs of parent_window
		if tabs_after > tabs_before then
			log "Test openNewTerminalTab: PASSED"
		else
			log "Test openNewTerminalTab: FAILED - Tab count did not increase"
		end if

		-- Test setTitleOf on the new tab
		log "Testing setTitleOf for a tab..."
		TerminalManager's setTitleOf(new_tab, "Test Tab Title")
		delay 0.5
		if custom title of new_tab is "Test Tab Title" then
			log "Test setTitleOf (tab): PASSED"
		else
			log "Test setTitleOf (tab): FAILED"
		end if

		-- Clean up the created window
		close parent_window
	end tell
on error e
	-- Ensure cleanup even on error
	try
		tell application "Terminal" to close parent_window
	end try
	log "Test openNewTerminalTab or setTitleOf (tab): FAILED with error: " & e
end try

log "TerminalManager tests complete."
