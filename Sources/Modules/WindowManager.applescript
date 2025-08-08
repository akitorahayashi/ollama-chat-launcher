-- WindowManager.applescript
-- This module handles window and tab creation, naming, and window searching functionality.

-- ==========================================
-- Public API - Window and Tab Creation
-- ==========================================

on createNewWindow(title)
	tell application "Terminal"
		activate
		-- Always create a new window, regardless of existing windows
		tell application "System Events"
			keystroke "n" using command down
		end tell
		delay 0.5
		set new_window to front window
		set custom title of new_window to title
		return new_window
	end tell
end createNewWindow

on openNewTabInWindow(target_window)
	tell application "Terminal"
		activate
		set selected of target_window to true
		tell application "System Events"
			keystroke "t" using command down
		end tell
		delay 0.5
		set new_tab to selected tab of front window
		return new_tab
	end tell
end openNewTabInWindow

on generateWindowTitle(wifi_ip, sequence_number, ollama_port, model_name)
	return (sequence_number as text) & "." & model_name & " Server [" & wifi_ip & ":" & (ollama_port as text) & "]"
end generateWindowTitle

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

-- ==========================================
-- Private API
-- ==========================================

on _findServerWindows(wifi_ip, ollama_port)
	set server_windows to {}
	set expected_server_pattern to "[" & wifi_ip & ":" & ollama_port & "]"
	try
		tell application "Terminal"
			repeat with w in windows
				try
					set window_title to custom title of w
					if window_title contains "Server [" and window_title contains expected_server_pattern then
						-- シーケンス番号を抽出
						set seq_num to my _extractSequenceNumber(window_title)
						if seq_num is not missing value then
							copy {sequence:seq_num, window:w} to end of server_windows
							log "WindowManager: Found server window (seq " & seq_num & "): " & window_title
						end if
					end if
				on error window_error
					-- Skip this window if title cannot be read
				end try
			end repeat
		end tell
	on error error_message
		log "Window Management Error: An error occurred while finding server windows: " & error_message
	end try
	return server_windows
end _findServerWindows

on _extractSequenceNumber(window_title)
	try
		-- 先頭の数字＋.を抽出
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
