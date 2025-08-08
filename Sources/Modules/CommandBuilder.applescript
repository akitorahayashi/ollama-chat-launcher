-- CommandBuilder.applescript
-- This module is responsible for generating shell command strings.

on buildServerCommand(ip_address, port, model_name)
	-- パラメータをエスケープしてインジェクションを防ぐ
	set escaped_ip to my escapeShellParameter(ip_address)
	set escaped_port to my escapeShellParameter(port)

	-- 表示用のコマンド (エスケープされていない値を表示)
	set display_command to "echo '--- Private LLM Launcher ---'; " & ¬
		"echo 'IP Address: " & ip_address & "'; " & ¬
		"echo 'Port: " & port & "'; " & ¬
		"echo 'Model: " & model_name & "'; " & ¬
		"echo '--------------------------'; " & ¬
		"echo 'Starting Ollama server...';"

	-- 実行用のコマンド (エスケープされた値を使用)
	set server_command to "OLLAMA_HOST=http://" & escaped_ip & ":" & escaped_port & " ollama serve"
	return display_command & " " & server_command
end buildServerCommand

on buildModelCommand(ip_address, port, model_name)
	-- パラメータをエスケープしてインジェクションを防ぐ
	set escaped_ip to my escapeShellParameter(ip_address)
	set escaped_port to my escapeShellParameter(port)
	set escaped_model to my escapeShellParameter(model_name)

	-- 実行用のコマンド (エスケープされた値を使用)
	return "OLLAMA_HOST=http://" & escaped_ip & ":" & escaped_port & " ollama run " & escaped_model
end buildModelCommand

-- シェルパラメータを安全にエスケープする
on escapeShellParameter(param)
	return "'" & text 1 thru -2 of (do shell script "printf '%s' " & quoted form of param) & "'"
end escapeShellParameter
