-- Load the modules to be tested
set module_base_path to (path to me as text) & "::build:modules:"
set modules_to_load to {{"ServerManager", ""}, {"WindowManager", ""}, {"Network", ""}}

repeat with i from 1 to count of modules_to_load
    set module_info to item i of modules_to_load
    set module_name to item 1 of module_info
    set module_path to module_base_path & module_name & ".scpt"
    try
        alias module_path
        set item 2 of module_info to (load script alias module_path)
    on error
        log "SETUP ERROR: " & module_name & ".scpt not found at " & module_path
        return
    end try
end repeat

set ServerManager to item 2 of item 1 of modules_to_load
set WindowManager to item 2 of item 2 of modules_to_load
set Network to item 2 of item 3 of modules_to_load


-- The following tests require a running Terminal application and will create windows and tabs.
-- They are designed to be run in a controlled environment.

-- Test waitForServer
-- This test is difficult to automate without a mock server.
-- We can test the timeout case.
try
    log "Testing waitForServer timeout. This will take 30 seconds."
    set result to ServerManager's waitForServer(54321, Network)
    if not result then
        log "Test waitForServer (timeout): PASSED"
    else
        log "Test waitForServer (timeout): FAILED - Server did not time out."
    end if
on error e
    log "Test waitForServer (timeout): FAILED - " & e
end try

-- The following tests are highly dependent on user interaction and environment.
-- They are provided as a template for manual testing.

log "MANUAL TEST: The following tests for ServerManager require manual observation."
log "MANUAL TEST: They will open new Terminal windows and tabs."

try
    log "Testing createNewTerminalWindow..."
    tell application "Terminal"
        set window_count_before to count of windows
    end tell

    set new_window to ServerManager's createNewTerminalWindow("echo 'Hello from createNewTerminalWindow test'")

    tell application "Terminal"
        set window_count_after to count of windows
        if window_count_after > window_count_before then
            log "Test createNewTerminalWindow: PASSED"
        else
            log "Test createNewTerminalWindow: FAILED - Window count did not increase"
        end if
        -- Clean up the created window
        if new_window is not missing value then
            close new_window
        end if
    end tell
on error e
    log "Test createNewTerminalWindow: FAILED - " & e
end try


try
    log "Testing openNewTerminalTab..."
    -- Create a new window to work in
    tell application "Terminal"
        activate
        set parent_window to do script ""
        set tabs_before to count of tabs of parent_window
    end tell
    delay 0.5

    set new_tab to ServerManager's openNewTerminalTab(parent_window, "echo 'Hello from openNewTerminalTab test'")

    tell application "Terminal"
        set tabs_after to count of tabs of parent_window
        if tabs_after > tabs_before then
            log "Test openNewTerminalTab: PASSED"
        else
            log "Test openNewTerminalTab: FAILED - Tab count did not increase"
        end if
        -- Clean up the created window
        close parent_window
    end tell
on error e
    -- Ensure cleanup even on error
    try
        tell application "Terminal" to close parent_window
    end try
    log "Test openNewTerminalTab: FAILED - " & e
end try
