-- CommandBuilder.applescript
-- This module is responsible for building shell command strings only.
-- It does NOT execute commands - that is the responsibility of the caller.

on buildServerCommand(ip_address, port, model_name)
	set escaped_ip to my escapeShellParameter(ip_address)
	set escaped_port to my escapeShellParameter(port)
	set escaped_model_name to my escapeShellParameter(model_name)

	set display_command to "echo '--- Private LLM Launcher ---'; " & ¬
		"echo 'IP Address: " & ip_address & "'; " & ¬
		"echo 'Port: " & port & "'; " & ¬
		"echo Model: " & escaped_model_name & "; " & ¬
		"echo '--------------------------'; " & ¬
		"echo 'Starting Ollama server...';"

	set server_command to "OLLAMA_HOST=http://" & escaped_ip & ":" & escaped_port & " ollama serve"
	return display_command & " " & server_command
end buildServerCommand

on buildModelCommand(ip_address, port, model_name)
	set escaped_ip to my escapeShellParameter(ip_address)
	set escaped_port to my escapeShellParameter(port)
	set escaped_model to my escapeShellParameter(model_name)

	return "OLLAMA_HOST=http://" & escaped_ip & ":" & escaped_port & " ollama run " & escaped_model
end buildModelCommand

on escapeShellParameter(param)
	set param_as_string to param as string
	return quoted form of param_as_string
end escapeShellParameter
