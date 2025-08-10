-- Tests for CommandBuilder.applescript

-- ==========================================
-- Test Runner
-- ==========================================
on runTests()
	log "Running tests for CommandBuilder.applescript"
	set CommandBuilder to loadModuleForTest("CommandBuilder", false)

	try
		test_buildServerCommand(CommandBuilder)
		test_buildModelCommand(CommandBuilder)
		test_escapeShellParameter_simple(CommandBuilder)
		test_escapeShellParameter_withSpaces(CommandBuilder)
	on error err
		error "A test failed: " & err
	end try
end runTests

-- ==========================================
-- Test Cases
-- ==========================================
on test_buildServerCommand(CommandBuilder)
	set testName to "test_buildServerCommand"
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
	set expected to expected_display & " " & expected_server

	set actual to CommandBuilder's buildServerCommand(ip_address, port, model_name, models_path)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_buildServerCommand

on test_buildModelCommand(CommandBuilder)
	set testName to "test_buildModelCommand"
	set ip_address to "127.0.0.1"
	set port to "11434"
	set model_name to "llama2"

	set expected to "OLLAMA_HOST=http://127.0.0.1:11434 ollama run 'llama2'"
	set actual to CommandBuilder's buildModelCommand(ip_address, port, model_name)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_buildModelCommand

on test_escapeShellParameter_simple(CommandBuilder)
	set testName to "test_escapeShellParameter_simple"
	set param to "simple"
	set expected to "'simple'"
	set actual to CommandBuilder's escapeShellParameter(param)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_escapeShellParameter_simple

on test_escapeShellParameter_withSpaces(CommandBuilder)
	set testName to "test_escapeShellParameter_withSpaces"
	set param to "parameter with spaces"
	set expected to "'parameter with spaces'"
	set actual to CommandBuilder's escapeShellParameter(param)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_escapeShellParameter_withSpaces

-- ==========================================
-- Test Utilities (Self-contained)
-- ==========================================
on loadModuleForTest(moduleName, isMain)
	try
		set scriptPath to POSIX path of (path to me)
		set testsDir to do shell script "dirname " & quoted form of scriptPath
		set projectRoot to do shell script "dirname " & quoted form of testsDir

		set modulePathPOSIX to ""
		if isMain is true then
			set modulePathPOSIX to projectRoot & "/build/" & moduleName & ".scpt"
		else
			set modulePathPOSIX to projectRoot & "/build/Modules/" & moduleName & ".scpt"
		end if

		return load script file (modulePathPOSIX)
	on error errMsg number errNum
		error "Test failed to load module '" & moduleName & "'. Reason: " & errMsg
	end try
end loadModuleForTest

-- Run the tests
runTests()
