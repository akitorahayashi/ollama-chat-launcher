-- ==========================================
-- ターミナル操作モジュール
-- 役割: Terminal.appに対する低レベルな操作（新規ウィンドウ/タブの作成、タイトルの設定）を抽象化します。
-- ==========================================
script TerminalManager
	property parent : missing value

	-- ==========================================
	-- Terminal操作抽象化レイヤー
	-- ==========================================
	on openNewTerminalTab(parent_window, command)
		tell application "Terminal"
			activate
			set current_window to parent_window
			-- ウィンドウを選択してからCmd+Tで新しいタブを作成
			set selected of current_window to true
			tell application "System Events"
				keystroke "t" using command down
			end tell
			delay 0.5
			-- 新しいタブでコマンドを実行
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
end script
