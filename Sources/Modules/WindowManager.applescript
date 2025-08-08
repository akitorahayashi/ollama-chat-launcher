-- WindowManager.applescript
-- This module handles window and tab creation, naming, and window searching functionality.

-- ==========================================
-- Public API - Window and Tab Creation
-- ==========================================

on createNewWindow(title)
	tell application "Terminal"
		activate
		-- Check if there are any windows, if not create one
		if (count of windows) = 0 then
			-- Create a new window by opening a new Terminal
			tell application "System Events"
				keystroke "n" using command down
			end tell
			delay 0.5
		end if
		set new_window to front window
		set custom title of new_window to title
		return new_window
	end tell
end createNewWindow

on openNewTabInWindow(target_window, title)
	tell application "Terminal"
		activate
		set selected of target_window to true
		tell application "System Events"
			keystroke "t" using command down
		end tell
		delay 0.5
		set new_tab to selected tab of front window
		set custom title of new_tab to title
		return new_tab
	end tell
end openNewTabInWindow

-- ==========================================
-- Public API - Title Generation
-- ==========================================

on generateWindowTitle(wifi_ip, sequence_number, ollama_port, model_name)
	return model_name & " Server #" & sequence_number & " [" & wifi_ip & ":" & ollama_port & "]"
end generateWindowTitle

on generateTabTitle(tab_number, model_name)
	if tab_number = 1 then
		return "Server"
	else
		return "Chat #" & (tab_number - 1)
	end if
end generateTabTitle

-- ==========================================
-- Public API - Window Search
-- ==========================================

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

	repeat with server_info in server_windows
		if server_info's sequence > max_seq then
			set max_seq to server_info's sequence
			set latest_window to server_info's window
			set latest_sequence to server_info's sequence
		end if
	end repeat

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
					if window_title contains "Server #" and window_title contains expected_server_pattern then
						-- シーケンス番号を抽出
						set seq_num to my _extractSequenceNumber(window_title)
						if seq_num is not missing value then
							copy {sequence:seq_num, window:w} to end of server_windows
						end if
					end if
				on error
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
		-- "Server #" の後の数字を抽出
		set server_pos to offset of "Server #" in window_title
		if server_pos > 0 then
			set after_server to text (server_pos + 8) thru -1 of window_title
			set space_pos to offset of " " in after_server
			if space_pos > 0 then
				set seq_str to text 1 thru (space_pos - 1) of after_server
			else
				-- スペースがない場合、最後まで取る
				set bracket_pos to offset of " [" in after_server
				if bracket_pos > 0 then
					set seq_str to text 1 thru (bracket_pos - 1) of after_server
				else
					set seq_str to after_server
				end if
			end if
			return seq_str as integer
		end if
	on error
	error "WindowManager: Sequence number parse error in title: " & window_title
	end try
	return missing value
end _extractSequenceNumber
