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
    set title1 to WindowManager's generateWindowTitle("192.168.1.1", 1, "server", 8080, "tinyllama")
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
    set title2 to WindowManager's generateWindowTitle("192.168.1.1", 2, "chat", 8080, "tinyllama")
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
try
    log "Testing getMaxSequenceNumber..."
    -- Programmatically create a dummy window for the test
    tell application "Terminal"
        activate
        set test_window to do script ""
        set custom title of test_window to "Ollama Server #3 [127.0.0.1:12345]"
    end tell
    delay 0.5 -- Give terminal time to process

    set max_seq to WindowManager's getMaxSequenceNumber("127.0.0.1", 12345)

    -- Clean up the dummy window
    tell application "Terminal" to close test_window

    if max_seq is 3 then
        log "Test getMaxSequenceNumber: PASSED"
    else
        log "Test getMaxSequenceNumber: FAILED - Expected 3, got " & max_seq
    end if
on error e
    -- Ensure cleanup even on error
    try
        tell application "Terminal" to close test_window
    end try
    log "Test getMaxSequenceNumber: FAILED - " & e
end try

-- Test findLatestServerWindow
try
    log "Testing findLatestServerWindow..."
    -- Programmatically create a dummy window for the test
    tell application "Terminal"
        activate
        set test_window to do script ""
        set custom title of test_window to "Ollama Server #5 [127.0.0.1:54321]"
    end tell
    delay 0.5 -- Give terminal time to process

    set server_info to WindowManager's findLatestServerWindow("127.0.0.1", 54321)

    -- Clean up the dummy window
    tell application "Terminal" to close test_window

    if server_info's sequence is 5 then
        log "Test findLatestServerWindow: PASSED"
    else
        log "Test findLatestServerWindow: FAILED - Expected sequence 5, got " & server_info's sequence
    end if
on error e
    -- Ensure cleanup even on error
    try
        tell application "Terminal" to close test_window
    end try
    log "Test findLatestServerWindow: FAILED - " & e
end try
