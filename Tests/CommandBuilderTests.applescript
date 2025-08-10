-- Tests for CommandBuilder.applescript

-- Load the test helper script
set testHelperPath to (path to me as text) & "TestHelper.applescript"
set TestHelper to load script file testHelperPath

-- Load the module to be tested
set CommandBuilder to TestHelper's loadModuleForTest("CommandBuilder", false)

-- Run all tests
runTests()

on runTests()
	log "Running tests for CommandBuilder.applescript"

	try
		test_buildServerCommand()
		test_buildModelCommand()
		test_escapeShellParameter_simple()
		test_escapeShellParameter_withSpaces()

		log "All CommandBuilder tests passed."
	on error err
		log "A test failed: " & err
		error err
	end try

	log "Tests for CommandBuilder.applescript completed."
end runTests

-- Test cases
on test_buildServerCommand()
	set ip_address to "192.168.1.100"
	set port to "8080"
	set model_name to "test-model"
	set models_path to "/Users/test/models"

	set expected_display to "echo '--- Private LLM Launcher ---'; " & ¬
		"echo 'IP Address: 192.168.1.100'; " & ¬
		"echo 'Port: 8080'; " & ¬
		"echo 'Model: test-model'; " & ¬
		"echo 'Models Path: /Users/test/models'; " & ¬
		"echo '--------------------------'; " & ¬
		"echo 'Starting Ollama server...';"
	set expected_server to "OLLAMA_MODELS='/Users/test/models' OLLAMA_HOST=http://192.168.1.100:8080 ollama serve"
	set expected_command to expected_display & " " & expected_server

	set actual_command to CommandBuilder's buildServerCommand(ip_address, port, model_name, models_path)

	TestHelper's assertEquals(expected_command, actual_command, "test_buildServerCommand")
end test_buildServerCommand

on test_buildModelCommand()
	set ip_address to "127.0.0.1"
	set port to "11434"
	set model_name to "llama2"

	set expected_command to "OLLAMA_HOST=http://127.0.0.1:11434 ollama run 'llama2'"

	set actual_command to CommandBuilder's buildModelCommand(ip_address, port, model_name)

	TestHelper's assertEquals(expected_command, actual_command, "test_buildModelCommand")
end test_buildModelCommand

on test_escapeShellParameter_simple()
	set param to "simple"
	set expected to "'simple'"
	set actual to CommandBuilder's escapeShellParameter(param)
	TestHelper's assertEquals(expected, actual, "test_escapeShellParameter_simple")
end test_escapeShellParameter_simple

on test_escapeShellParameter_withSpaces()
	set param to "parameter with spaces"
	set expected to "'parameter with spaces'"
	set actual to CommandBuilder's escapeShellParameter(param)
	TestHelper's assertEquals(expected, actual, "test_escapeShellParameter_withSpaces")
end test_escapeShellParameter_withSpaces
