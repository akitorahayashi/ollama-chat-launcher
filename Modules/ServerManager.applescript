-- Properties for local constants
property SERVER_STARTUP_TIMEOUT : 30
property SERVER_CHECK_INTERVAL : 0.1

-- Properties for other modules, inherited from the parent script
on waitForServer(ollama_port, Network)
        set elapsed to 0
        repeat until Network's isPortInUse(ollama_port)
            delay SERVER_CHECK_INTERVAL
            set elapsed to elapsed + SERVER_CHECK_INTERVAL
            if elapsed > SERVER_STARTUP_TIMEOUT then
                log "タイムアウト: サーバーの起動がタイムアウトしました。手動で確認してください。"
                return false
            end if
        end repeat
        return true
    end waitForServer

    on openNewTerminalTab(parent_window, command)
        tell application "Terminal"
            activate
            set current_window to parent_window
            set selected of current_window to true
            tell application "System Events"
                keystroke "t" using command down
            end tell
            delay 0.5
            do script command in front window
            return selected tab of front window
        end tell
    end openNewTerminalTab

    on setTerminalTitle(window_or_tab, title)
        tell application "Terminal"
            set custom title of window_or_tab to title
        end tell
    end setTerminalTitle

    on createNewTerminalWindow(command)
        tell application "Terminal"
            activate
            do script command
            return front window
        end tell
    end createNewTerminalWindow

    on startOllamaServer(wifi_ip, ollama_port, model_name, WindowManager)
        set next_seq to (WindowManager's getMaxSequenceNumber(wifi_ip, ollama_port) + 1)
        set window_title to WindowManager's generateWindowTitle(wifi_ip, next_seq, "server", ollama_port, model_name)
        set command to "OLLAMA_HOST=" & wifi_ip & ":" & ollama_port & " ollama serve"

        set new_window to my createNewTerminalWindow(command)
        my setTerminalTitle(new_window, window_title)

        return {window:new_window, sequence:next_seq}
    end startOllamaServer

    on validateServerWindow(target_window, wifi_ip, sequence_number, ollama_port, model_name, WindowManager)
        if target_window is missing value then
            set msg to "Ollamaサーバーのウィンドウが見つかりませんでした。"
            set details to "検索条件: IP=" & wifi_ip & ", PORT=" & ollama_port & return & "期待ウィンドウ名: " & WindowManager's generateWindowTitle(wifi_ip, sequence_number, "server", ollama_port, model_name)

            tell application "Terminal"
                set details to details & return & "現在のTerminalウィンドウ一覧:"
                repeat with w in windows
                    set details to details & return & "- " & custom title of w
                end repeat
            end tell

            log "ウィンドウエラー: " & msg & return & details
            error "Server window not found"
        end if
    end validateServerWindow

    on executeOllamaModel(target_window, wifi_ip, sequence_number, model_name, ollama_port, WindowManager)
        my validateServerWindow(target_window, wifi_ip, sequence_number, ollama_port, model_name, WindowManager)

        set command to "OLLAMA_HOST=http://" & wifi_ip & ":" & ollama_port & " ollama run " & model_name
        set new_tab to my openNewTerminalTab(target_window, command)
    set tab_title to WindowManager's generateWindowTitle(wifi_ip, sequence_number, "chat", ollama_port, model_name)
    my setTerminalTitle(new_tab, tab_title)
end executeOllamaModel
