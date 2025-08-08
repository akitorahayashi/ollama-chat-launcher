-- CommandBuilder.applescript
-- シェルコマンドの文字列を生成する責務を担うモジュール

on buildServerCommand(ip_address, port, model_name)
	set display_command to "echo '--- Private LLM Launcher ---'; " & ¬
		"echo 'IP Address: " & ip_address & "'; " & ¬
		"echo 'Port: " & port & "'; " & ¬
		"echo 'Model: " & model_name & "'; " & ¬
		"echo '--------------------------'; " & ¬
		"echo 'Starting Ollama server...';"

	set server_command to "OLLAMA_HOST=" & ip_address & ":" & port & " ollama serve"
	return display_command & " " & server_command
end buildServerCommand

on buildModelCommand(ip_address, port, model_name)
	return "OLLAMA_HOST=http://" & ip_address & ":" & port & " ollama run " & model_name
end buildModelCommand
