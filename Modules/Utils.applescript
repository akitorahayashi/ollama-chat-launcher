-- ==========================================
-- ユーティリティモジュール
-- 役割: エラー表示、シェルコマンド実行、文字列操作など、
--       プロジェクト全体で汎用的に使用される補助的な関数群を提供します。
-- ==========================================
script Utils
	property parent : missing value

	on showError(title, message, icon_type)
		display dialog message buttons {"OK"} default button "OK" with title title with icon icon_type
	end showError

	on executeShell(command, silent)
		try
			set result to do shell script command
			return {success:true, output:result}
		on error error_message
			return {success:false, output:error_message}
		end try
	end executeShell

	on extractFieldsFromString(text_to_split, delimiter)
		set old_delimiters to AppleScript's text item delimiters
		set AppleScript's text item delimiters to delimiter
		set string_list to text items of text_to_split
		set AppleScript's text item delimiters to old_delimiters
		return string_list
	end extractFieldsFromString

	on generateSimpleID()
		set current_time to current date
		set hours_str to (hours of current_time as string)
		set minutes_str to (minutes of current_time as string)
		set seconds_str to (seconds of current_time as string)

		-- 0埋めして2桁にする
		if length of hours_str < 2 then set hours_str to "0" & hours_str
		if length of minutes_str < 2 then set minutes_str to "0" & minutes_str
		if length of seconds_str < 2 then set seconds_str to "0" & seconds_str

		return hours_str & minutes_str & seconds_str
	end generateSimpleID

	on waitFor(condition_checker, timeout, poll_interval, description)
		set start_time to current date
		repeat
			if (current date) - start_time > timeout then
				my showError("タイムアウト", description, caution)
				return false
			end if

			if condition_checker's check() then
				return true
			end if

			delay poll_interval
		end repeat
	end waitFor
end script
