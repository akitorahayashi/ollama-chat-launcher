-- This is an integration test for the main script.
-- It requires all modules to be compiled and available.
-- It also requires a running Terminal application.

-- To run this test:
-- 1. Make sure all modules are compiled using: make build
-- 2. Run this script from the root of the repository using: osascript Tests/main.applescript

log "Running main script integration test..."
log "This test will attempt to start an Ollama server and a chat session."
log "Please observe the Terminal application for the expected behavior."

try
    run script POSIX file (POSIX path of (path to me) & "/../main.applescript")
    log "Main script integration test: COMPLETED (manual verification required)"
on error e
    log "Main script integration test: FAILED - " & e
end try
