-- TerminalManager.applescript
-- This module specializes in managing Terminal windows and tabs.

-- ==========================================
-- Public API
-- ==========================================

on createNewWindowWithCommand(command)
	tell application "Terminal"
		activate
		do script command
		return front window
	end tell
end createNewWindowWithCommand

on openNewTabInWindow(target_window, command)
	tell application "Terminal"
		activate
		set selected of target_window to true
		tell application "System Events"
			keystroke "t" using command down
		end tell
		delay 0.5
		do script command in front window
		return selected tab of front window
	end tell
end openNewTabInWindow

on setTitleOf(target, title)
	try
		tell application "Terminal"
			set custom title of target to title
		end tell
	on error error_message
		log "Error setting title: " & error_message
		-- This error is not critical, so we log it but don't stop the script.
	end try
end setTitleOf

on generateWindowTitle(wifi_ip, sequence_number, title_type, ollama_port, model_name)
	if title_type is "server" then
		return "Ollama Server #" & sequence_number & " [" & wifi_ip & ":" & ollama_port & "]"
	else if title_type is "chat" then
		return "Ollama Chat #" & sequence_number & " [" & wifi_ip & ":" & ollama_port & "] (" & model_name & ")"
	end if
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
					if window_title starts with "Ollama Server #" and window_title contains expected_server_pattern then
						set old_delimiters to AppleScript's text item delimiters
						set AppleScript's text item delimiters to "#"
						set title_parts to text items of window_title
						set AppleScript's text item delimiters to old_delimiters
						if (count of title_parts) ≥ 2 then
							set seq_part to item 2 of title_parts
							set space_pos to offset of " " in seq_part
							if space_pos > 0 then
								set seq_str to text 1 thru (space_pos - 1) of seq_part
								try
									set seq_num to seq_str as integer
									copy {sequence:seq_num, window:w} to end of server_windows
								end try
							end if
						end if
					end if
				on error
					-- Skip this window
				end try
			end repeat
		end tell
	on error error_message
		log "Window Management Error: An error occurred while finding server windows: " & error_message
	end try
	return server_windows
end _findServerWindows
