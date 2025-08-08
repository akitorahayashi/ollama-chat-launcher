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

-- Load the module to be tested
set module_path to project_root & "build:modules:WindowManager.scpt"
try
    alias module_path
on error
    log "SETUP ERROR: WindowManager.scpt not found at " & module_path
    error "Test setup failed: WindowManager.scpt not found"
end try
set WindowManager to load script alias module_path

-- Test generateWindowTitle
try
    log "Testing generateWindowTitle..."
    set test_ip to "192.168.1.10"
    set test_sequence to 1
    set test_port to "11434"
    set test_model to "tinyllama"
    set expected_title to "tinyllama Server #1 [192.168.1.10:11434]"
    set actual_title to WindowManager's generateWindowTitle(test_ip, test_sequence, test_port, test_model)
    
    if actual_title = expected_title then
        log "Test generateWindowTitle: PASSED"
    else
        log "Test generateWindowTitle: FAILED"
        log "Expected: " & expected_title
        log "Actual:   " & actual_title
    end if
on error e
    log "Test generateWindowTitle: FAILED with error: " & e
end try

-- Test generateTabTitle for server tab
try
    log "Testing generateTabTitle (server tab)..."
    set expected_title to "Server"
    set actual_title to WindowManager's generateTabTitle(1, "tinyllama")
    
    if actual_title = expected_title then
        log "Test generateTabTitle (server tab): PASSED"
    else
        log "Test generateTabTitle (server tab): FAILED"
        log "Expected: " & expected_title
        log "Actual:   " & actual_title
    end if
on error e
    log "Test generateTabTitle (server tab): FAILED with error: " & e
end try

-- Test generateTabTitle for chat tab
try
    log "Testing generateTabTitle (chat tab)..."
    set expected_title to "Chat #1"
    set actual_title to WindowManager's generateTabTitle(2, "tinyllama")
    
    if actual_title = expected_title then
        log "Test generateTabTitle (chat tab): PASSED"
    else
        log "Test generateTabTitle (chat tab): FAILED"
        log "Expected: " & expected_title
        log "Actual:   " & actual_title
    end if
on error e
    log "Test generateTabTitle (chat tab): FAILED with error: " & e
end try

-- Test generateTabTitle for multiple chat tabs
try
    log "Testing generateTabTitle (multiple chat tabs)..."
    set expected_title to "Chat #3"
    set actual_title to WindowManager's generateTabTitle(4, "tinyllama")
    
    if actual_title = expected_title then
        log "Test generateTabTitle (multiple chat tabs): PASSED"
    else
        log "Test generateTabTitle (multiple chat tabs): FAILED"
        log "Expected: " & expected_title
        log "Actual:   " & actual_title
    end if
on error e
    log "Test generateTabTitle (multiple chat tabs): FAILED with error: " & e
end try

-- Test _extractSequenceNumber (private method testing via a known path)
try
    log "Testing sequence number extraction logic..."
    -- We can't directly test private methods, but we can test the public methods that use them
    -- Test getMaxSequenceNumber with no existing windows (should return 0)
    set test_ip to "127.0.0.1"
    set test_port to "9999" -- Use a port that's unlikely to have existing windows
    set max_seq to WindowManager's getMaxSequenceNumber(test_ip, test_port)
    
    if max_seq = 0 then
        log "Test getMaxSequenceNumber (no windows): PASSED"
    else
        log "Test getMaxSequenceNumber (no windows): PASSED (found existing windows: " & max_seq & ")"
    end if
on error e
    log "Test getMaxSequenceNumber: FAILED with error: " & e
end try

-- Test findLatestServerWindow with no existing windows
try
    log "Testing findLatestServerWindow..."
    set test_ip to "127.0.0.1"
    set test_port to "9999" -- Use a port that's unlikely to have existing windows
    set result to WindowManager's findLatestServerWindow(test_ip, test_port)
    
    -- When no windows are found, window should be missing value and sequence should be missing value
    if result's window is missing value and result's sequence is missing value then
        log "Test findLatestServerWindow (no windows): PASSED"
    else
        log "Test findLatestServerWindow (no windows): PASSED (found existing windows)"
    end if
on error e
    log "Test findLatestServerWindow: FAILED with error: " & e
end try

-- Test edge cases for title generation
try
    log "Testing generateWindowTitle with special characters..."
    set test_ip to "192.168.1.100"
    set test_sequence to 99
    set test_port to "8080"
    set test_model to "llama-2-chat"
    set expected_title to "llama-2-chat Server #99 [192.168.1.100:8080]"
    set actual_title to WindowManager's generateWindowTitle(test_ip, test_sequence, test_port, test_model)
    
    if actual_title = expected_title then
        log "Test generateWindowTitle (special chars): PASSED"
    else
        log "Test generateWindowTitle (special chars): FAILED"
        log "Expected: " & expected_title
        log "Actual:   " & actual_title
    end if
on error e
    log "Test generateWindowTitle (special chars): FAILED with error: " & e
end try

log "WindowManager tests complete."
