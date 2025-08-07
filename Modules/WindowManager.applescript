property OLLAMA_PORT : 0
property MODEL_NAME : ""

on generateWindowTitle(wifi_ip, sequence_number, title_type)
	if title_type is "server" then
		return "Ollama Server #" & sequence_number & " [" & wifi_ip & ":" & OLLAMA_PORT & "]"
	else if title_type is "chat" then
		return "Ollama Chat #" & sequence_number & " [" & wifi_ip & ":" & OLLAMA_PORT & "] (" & MODEL_NAME & ")"
	end if
end generateWindowTitle

on getMaxSequenceNumber(wifi_ip)
	set max_seq to 0
	set expected_server_pattern to "[" & wifi_ip & ":" & OLLAMA_PORT & "]"
	try
		tell application "Terminal"
			repeat with w in windows
				try
					set window_title to custom title of w
					-- 現在の設定と完全一致するOllamaサーバーウィンドウから連番を抽出
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
									if seq_num > max_seq then set max_seq to seq_num
								end try
							end if
						end if
					end if
				on error
					-- このウィンドウはスキップ
				end try
			end repeat
		end tell
	on error error_message
		log "ウィンドウ管理エラー: Terminalウィンドウの連番取得中にエラーが発生しました: " & error_message
		error "getMaxSequenceNumber failed"
	end try
	return max_seq
end getMaxSequenceNumber

on findLatestServerWindow(wifi_ip)
	set max_seq to 0
	set latest_window to missing value
	set latest_sequence to missing value
	set expected_server_pattern to "[" & wifi_ip & ":" & OLLAMA_PORT & "]"

	try
		tell application "Terminal"
			repeat with w in windows
				try
					set window_title to custom title of w
					-- 現在の設定と完全一致するOllamaサーバーウィンドウを探す
					if window_title starts with "Ollama Server #" and window_title contains expected_server_pattern then
						if window_title contains "#" then
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
										if seq_num > max_seq then
											set max_seq to seq_num
											set latest_window to w
											set latest_sequence to seq_num
										end if
									end try
								end if
							end if
						end if
					end if
				on error
					-- このウィンドウはスキップ
				end try
			end repeat
		end tell
	on error
		-- ウィンドウ検索でエラーが発生した場合
	end try

	return {window:latest_window, sequence:latest_sequence}
end findLatestServerWindow
