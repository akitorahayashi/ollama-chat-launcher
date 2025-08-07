-- ==========================================
-- Ollama管理モジュール
-- 役割: Ollamaサーバーの起動、チャットセッションの実行、
--       既存サーバー/新規サーバーの処理分岐など、アプリケーションの核となるフローを管理します。
-- ==========================================
script OllamaManager
	property parent : missing value

	-- ==========================================
	-- サーバー操作関数群
	-- ==========================================
	on startOllamaServer(wifi_ip)
		set next_seq to (parent's WindowManager's getMaxSequenceNumber(wifi_ip) + 1)
		set window_title to parent's WindowManager's generateWindowTitle(wifi_ip, next_seq, "server")
		set command to "OLLAMA_HOST=" & wifi_ip & ":" & parent's OLLAMA_PORT & " ollama serve"

		set new_window to parent's TerminalManager's createNewTerminalWindow(command)
		parent's TerminalManager's setTerminalTitle(new_window, window_title)

		return {window:new_window, sequence:next_seq}
	end startOllamaServer

	on validateServerWindow(target_window, wifi_ip, sequence_number)
		if target_window is missing value then
			set msg to "Ollamaサーバーのウィンドウが見つかりませんでした。"
			set details to "検索条件: IP=" & wifi_ip & ", PORT=" & parent's OLLAMA_PORT & return & "期待ウィンドウ名: " & parent's WindowManager's generateWindowTitle(wifi_ip, sequence_number, "server")

			tell application "Terminal"
				set details to details & return & "現在のTerminalウィンドウ一覧:"
				repeat with w in windows
					set details to details & return & "- " & custom title of w
				end repeat
			end tell

			parent's Utils's showError("ウィンドウエラー", msg & return & details, stop)
			error "Server window not found"
		end if
	end validateServerWindow

	on executeOllamaModel(target_window, wifi_ip, sequence_number)
		my validateServerWindow(target_window, wifi_ip, sequence_number)

		set command to "OLLAMA_HOST=http://" & wifi_ip & ":" & parent's OLLAMA_PORT & " ollama run " & parent's MODEL_NAME
		set new_tab to parent's TerminalManager's openNewTerminalTab(target_window, command)
		set tab_title to parent's WindowManager's generateWindowTitle(wifi_ip, sequence_number, "chat")
		parent's TerminalManager's setTerminalTitle(new_tab, tab_title)
	end executeOllamaModel

	-- ==========================================
	-- メインフロー制御関数群
	-- ==========================================
	on handleExistingServer(wifi_ip)
		set server_info to parent's WindowManager's findLatestServerWindow(wifi_ip)
		set server_window to server_info's window
		set sequence_number to server_info's sequence
		if server_window is not missing value then
			my executeOllamaModel(server_window, wifi_ip, sequence_number)
		else
			my handleNewServer(wifi_ip)
		end if
	end handleExistingServer

	on handleNewServer(wifi_ip)
		set server_info to my startOllamaServer(wifi_ip)
		set server_window to server_info's window
		set sequence_number to server_info's sequence

		script port_checker
			property parent_ref : parent
			on check()
				return parent_ref's NetworkManager's isPortInUse(parent_ref's OLLAMA_PORT)
			end check
		end script

		set wait_successful to parent's Utils's waitFor(port_checker, parent's SERVER_STARTUP_TIMEOUT, parent's SERVER_CHECK_INTERVAL, "サーバーの起動がタイムアウトしました。")

		if wait_successful then
			delay 1 -- サーバー完全起動のための待機
			my executeOllamaModel(server_window, wifi_ip, sequence_number)
		else
			parent's Utils's showError("起動失敗", "サーバーの起動に失敗しました。", stop)
		end if
	end handleNewServer
end script
