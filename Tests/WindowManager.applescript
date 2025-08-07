-- Load the module to be tested
set module_path to (path to me as text) & "::build:modules:WindowManager.scpt"
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
-- They are designed to be run in a controlled environment.

-- Test getMaxSequenceNumber
try
    -- This test requires manual setup:
    -- 1. Open Terminal.
    -- 2. Create a window with the custom title "Ollama Server #3 [127.0.0.1:12345]"
    log "MANUAL TEST: Please set up Terminal for getMaxSequenceNumber test."
    delay 5
    set max_seq to WindowManager's getMaxSequenceNumber("127.0.0.1", 12345)
    if max_seq is 3 then
        log "Test getMaxSequenceNumber: PASSED"
    else
        log "Test getMaxSequenceNumber: FAILED - Expected 3, got " & max_seq
    end if
on error e
    log "Test getMaxSequenceNumber: FAILED - " & e
end try

-- Test findLatestServerWindow
try
    -- This test requires manual setup:
    -- 1. Open Terminal.
    -- 2. Create a window with the custom title "Ollama Server #5 [127.0.0.1:54321]"
    log "MANUAL TEST: Please set up Terminal for findLatestServerWindow test."
    delay 5
    set server_info to WindowManager's findLatestServerWindow("127.0.0.1", 54321)
    if server_info's sequence is 5 then
        log "Test findLatestServerWindow: PASSED"
    else
        log "Test findLatestServerWindow: FAILED - Expected sequence 5, got " & server_info's sequence
    end if
on error e
    log "Test findLatestServerWindow: FAILED - " & e
end try
