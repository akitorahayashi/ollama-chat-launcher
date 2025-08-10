-- WindowManager.applescript
-- This module handles window and tab creation, naming, and window searching functionality.

property WINDOW_CREATION_TIMEOUT : 5
property TAB_CREATION_TIMEOUT : 5

-- Creates a new Terminal window and sets its title.
on createNewWindow(title)
	tell application "Terminal"
		activate
		set initial_window_count to count of windows
		-- Use UI scripting to ensure a new window is created and brought to the front.
		tell application "System Events"
			keystroke "n" using command down
		end tell

		-- Wait for the new window to appear.
		if not my waitForNewWindow(initial_window_count, WINDOW_CREATION_TIMEOUT) then
			error "Failed to create a new window in time."
		end if

		set new_window to front window
		set custom title of new_window to title
		return new_window
	end tell
end createNewWindow

-- Opens a new tab in a given window.
on openNewTabInWindow(target_window)
	tell application "Terminal"
		activate
		set selected of target_window to true
		set initial_tab_count to count of tabs of target_window
		-- Use UI scripting to create a new tab in the active window.
		tell application "System Events"
			keystroke "t" using command down
		end tell

		-- Wait for the new tab to be created.
		if not my waitForNewTab(target_window, initial_tab_count, TAB_CREATION_TIMEOUT) then
			error "Failed to create a new tab in time."
		end if

		set new_tab to selected tab of front window
		return new_tab
	end tell
end openNewTabInWindow

-- Waits for a new window to be created by checking the window count.
on waitForNewWindow(initial_count, timeout)
	set elapsed to 0
	repeat while (count of windows of application "Terminal") <= initial_count
		delay 0.2
		set elapsed to elapsed + 0.2
		if elapsed > timeout then
			log "Timeout waiting for new window."
			return false
		end if
	end repeat
	return true
end waitForNewWindow

-- Waits for a new tab to be created in a specific window.
on waitForNewTab(target_window, initial_tab_count, timeout)
	set elapsed to 0
	repeat while (count of tabs of target_window) <= initial_tab_count
		delay 0.2
		set elapsed to elapsed + 0.2
		if elapsed > timeout then
			log "Timeout waiting for new tab."
			return false
		end if
	end repeat
	return true
end waitForNewTab

-- Generates a standardized window title. Format: <sequence>.<model_name> Server [<ip>:<port>]
on generateWindowTitle(wifi_ip, sequence_number, ollama_port, model_name)
	return (sequence_number as text) & "." & model_name & " Server [" & wifi_ip & ":" & (ollama_port as text) & "]"
end generateWindowTitle

-- Finds the highest sequence number from existing server window titles to avoid duplicates.
on getMaxSequenceNumber(wifi_ip, ollama_port)
	set max_seq to 0
	set server_windows to my _findServerWindows(wifi_ip, ollama_port)
	repeat with server_info in server_windows
		if server_info's sequence > max_seq then
			set max_seq to server_info's sequence
		end if
	end repeat
	return max_seq
end getMaxSequenceNumber

-- Finds the most recent server window by looking for the highest sequence number in its title.
on findLatestServerWindow(wifi_ip, ollama_port)
	set max_seq to 0
	set latest_window to missing value
	set latest_sequence to missing value

	set server_windows to my _findServerWindows(wifi_ip, ollama_port)
	
	log "WindowManager: Found " & (count of server_windows) & " server windows for " & wifi_ip & ":" & ollama_port

	repeat with server_info in server_windows
		if server_info's sequence > max_seq then
			set max_seq to server_info's sequence
			set latest_window to server_info's window
			set latest_sequence to server_info's sequence
		end if
	end repeat
	
	if latest_sequence is not missing value then
		log "WindowManager: Latest server window found with sequence: " & latest_sequence & " (highest sequence number = newest server)"
	else
		log "WindowManager: No server windows found"
	end if

	return {window:latest_window, sequence:latest_sequence}
end findLatestServerWindow

-- Private helper: Finds all Terminal windows matching the server title pattern.
on _findServerWindows(wifi_ip, ollama_port)
	set server_windows to {}
	set expected_server_pattern to "[" & wifi_ip & ":" & ollama_port & "]"
	try
		tell application "Terminal"
			repeat with w in windows
				try
					set window_title to custom title of w
					if window_title contains "Server [" and window_title contains expected_server_pattern then
						set seq_num to my _extractSequenceNumber(window_title)
						if seq_num is not missing value then
							copy {sequence:seq_num, window:w} to end of server_windows
							log "WindowManager: Found server window (seq " & seq_num & "): " & window_title
						end if
					end if
				on error window_error
					-- Skip this window if its title cannot be read.
				end try
			end repeat
		end tell
	on error error_message
		log "Window Management Error: An error occurred while finding server windows: " & error_message
	end try
	return server_windows
end _findServerWindows

-- Private helper: Parses the sequence number from a window title (e.g., "1.model..." -> 1).
on _extractSequenceNumber(window_title)
	try
		-- Extract the number before the first ".".
		set dot_pos to offset of "." in window_title
		if dot_pos > 1 then
			set seq_str to text 1 thru (dot_pos - 1) of window_title
			set seq_num to seq_str as integer
			log "WindowManager: Extracted sequence number " & seq_num & " from title: " & window_title
			return seq_num
		else
			log "WindowManager: No dot found in title: " & window_title
		end if
	on error error_msg
		log "WindowManager: Sequence number parse error in title '" & window_title & "': " & error_msg
	end try
	return missing value
end _extractSequenceNumber
