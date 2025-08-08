-- TerminalManager.applescript
-- ターミナルのウィンドウ・タブ操作に特化したモジュール

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
	tell application "Terminal"
		set custom title of target to title
	end tell
end setTitleOf
