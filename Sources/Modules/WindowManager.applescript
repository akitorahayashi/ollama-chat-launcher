on generateWindowTitle(wifi_ip, sequence_number, title_type, ollama_port, model_name)
        if title_type is "server" then
            return "Ollama Server #" & sequence_number & " [" & wifi_ip & ":" & ollama_port & "]"
        else if title_type is "chat" then
            return "Ollama Chat #" & sequence_number & " [" & wifi_ip & ":" & ollama_port & "] (" & model_name & ")"
        end if
    end generateWindowTitle

    on getMaxSequenceNumber(wifi_ip, ollama_port)
        set max_seq to 0
        set expected_server_pattern to "[" & wifi_ip & ":" & ollama_port & "]"
        try
            tell application "Terminal"
                repeat with w in windows
                    try
                        set window_title to custom title of w
                        -- Extract sequence number from Ollama server windows that exactly match the current settings
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
                        -- Skip this window
                    end try
                end repeat
            end tell
        on error error_message
            log "Window Management Error: An error occurred while retrieving the sequence number of the Terminal window: " & error_message
            error "getMaxSequenceNumber failed"
        end try
        return max_seq
    end getMaxSequenceNumber

    on findLatestServerWindow(wifi_ip, ollama_port)
        set max_seq to 0
        set latest_window to missing value
        set latest_sequence to missing value
        set expected_server_pattern to "[" & wifi_ip & ":" & ollama_port & "]"

        try
            tell application "Terminal"
                repeat with w in windows
                    try
                        set window_title to custom title of w
                        -- Find an Ollama server window that exactly matches the current settings
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
                        -- Skip this window
                    end try
                end repeat
            end tell
        on error
            -- If an error occurs during window search
        end try

    return {window:latest_window, sequence:latest_sequence}
end findLatestServerWindow
