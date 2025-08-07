-- ==========================================
-- ターミナル操作モジュール
-- 役割: Terminal.appに対する低レベルな操作（新規ウィンドウ/タブの作成、タイトルの設定）を抽象化します。
-- ==========================================
script TerminalManager
	property parent : missing value

	on openNewTerminalTab(parent_window, command)
		tell application "Terminal"
			activate
			set current_window to parent_window
			set initial_tab_count to count of tabs of current_window

			-- ウィンドウを選択してからCmd+Tで新しいタブを作成
			set selected of current_window to true
			tell application "System Events"
				keystroke "t" using command down
			end tell

			-- 新しいタブが実際に開くまで待機
			script tab_checker
				property target_window : current_window
				property original_count : initial_tab_count
				on check()
					return (count of tabs of target_window) > original_count
				end check
			end script
			set wait_successful to parent's Utils's waitFor(tab_checker, 2, 0.2, "新しいターミナルタブの作成に失敗しました。")

			if wait_successful then
				-- 新しいタブでコマンドを実行
				do script command in front window
				return selected tab of front window
			else
				-- タイムアウトした場合、エラーを報告
				parent's Utils's showError("タブ作成エラー", "新しいターミナルタブを開けませんでした。", stop)
				error "Failed to create a new tab."
			end if
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
end script
