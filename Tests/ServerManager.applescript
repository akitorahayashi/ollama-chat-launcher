-- Load the modules to be tested
set module_path to (path to me as text) & "::build:modules:"
set ServerManager to load script alias (module_path & "ServerManager.scpt")
set WindowManager to load script alias (module_path & "WindowManager.scpt")
set Network to load script alias (module_path & "Network.scpt")


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
    log "MANUAL TEST: Testing openNewTerminalTab. A new Terminal window and tab should open."
    delay 3
    tell application "Terminal" to activate
    do script ""
    set parent_window to front window
    set new_tab to ServerManager's openNewTerminalTab(parent_window, "echo 'Hello from openNewTerminalTab test'")
    if new_tab is not missing value then
        log "Test openNewTerminalTab: PASSED (visual confirmation needed)"
    else
        log "Test openNewTerminalTab: FAILED"
    end if
    delay 2
    tell application "Terminal" to close parent_window
on error e
    log "Test openNewTerminalTab: FAILED - " & e
end try
