-- CommandBuilder.applescript
-- This module is responsible for building shell command strings only.
-- It does NOT execute commands - that is the responsibility of the caller.

on buildServerCommand(ip_address, port, model_name, ollama_models_path)
	-- Only escape parameters that might contain spaces or special characters.
	set escaped_model_name to my escapeShellParameter(model_name)
	set escaped_models_path to my escapeShellParameter(ollama_models_path)

	set display_command to "echo '--- Private LLM Launcher ---'; " & ¬
		"echo 'IP Address: " & ip_address & "'; " & ¬
		"echo 'Port: " & port & "'; " & ¬
		"echo 'Model: " & model_name & "'; " & ¬
		"echo 'Models Path: " & ollama_models_path & "'; " & ¬
		"echo '--------------------------'; " & ¬
		"echo 'Starting Ollama server...';"

	-- IP and Port are not escaped as they are part of the URL and are not expected to have spaces.
	set server_command to "OLLAMA_MODELS=" & escaped_models_path & " OLLAMA_HOST=http://" & ip_address & ":" & port & " ollama serve"
	return display_command & " " & server_command
end buildServerCommand

on buildModelCommand(ip_address, port, model_name)
	-- Only escape parameters that might contain spaces or special characters.
	set escaped_model to my escapeShellParameter(model_name)

	-- IP and Port are not escaped as they are part of the URL.
	return "OLLAMA_HOST=http://" & ip_address & ":" & port & " ollama run " & escaped_model
end buildModelCommand

on escapeShellParameter(param)
	set param_as_string to param as string
	return quoted form of param_as_string
end escapeShellParameter
