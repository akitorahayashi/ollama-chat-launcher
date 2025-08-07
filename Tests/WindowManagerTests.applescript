-- Load the module to be tested
set module_path to (path to me as text) & "::build:modules:WindowManager.scpt"
try
    alias module_path
on error
    log "SETUP ERROR: WindowManager.scpt not found at " & module_path
    return
end try
set WindowManager to load script alias module_path

-- Test generateWindowTitle
try
    set title1 to WindowManager's generateWindowTitle("192.168.1.1", 1, "server", 8080, "test-model")
    if title1 is "Ollama Server #1 [192.168.1.1:8080]" then
        log "Test generateWindowTitle (server): PASSED"
    else
        log "Test generateWindowTitle (server): FAILED - Unexpected title: " & title1
    end if
on error e
    log "Test generateWindowTitle (server): FAILED - " & e
end try

try
    set title2 to WindowManager's generateWindowTitle("192.168.1.1", 2, "chat", 8080, "test-model")
    if title2 is "Ollama Chat #2 [192.168.1.1:8080] (test-model)" then
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
