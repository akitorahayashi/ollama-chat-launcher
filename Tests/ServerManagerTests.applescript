-- Tests for ServerManager.applescript

-- ==========================================
-- Test Runner
-- ==========================================
on runTests()
	log "Running tests for ServerManager.applescript"
	set ServerManager to loadModuleForTest("ServerManager", false)

	try
		test_roundDown_positive(ServerManager)
		test_roundDown_integer(ServerManager)
		test_roundDown_zero(ServerManager)
	on error err
		error "A test failed: " & err
	end try
end runTests

-- ==========================================
-- Test Cases
-- ==========================================
on test_roundDown_positive(ServerManager)
	set testName to "test_roundDown_positive"
	set expected to 5
	set actual to ServerManager's roundDown(5.7)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_roundDown_positive

on test_roundDown_integer(ServerManager)
	set testName to "test_roundDown_integer"
	set expected to 10
	set actual to ServerManager's roundDown(10)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_roundDown_integer

on test_roundDown_zero(ServerManager)
	set testName to "test_roundDown_zero"
	set expected to 0
	set actual to ServerManager's roundDown(0.2)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_roundDown_zero

-- NOTE: The following handlers are not tested because they involve
-- complex side effects like network calls, shell scripts, and GUI manipulation,
-- which are not suitable for simple, repeatable unit tests.
-- - isOllamaServerRunning
-- - startServer
-- - waitForServer
-- - executeModelInWindow
-- - openChatInNewWindow

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

		return load script (POSIX file modulePathPOSIX as alias)
	on error errMsg number errNum
		error "Test failed to load module '" & moduleName & "'. Reason: " & errMsg
	end try
end loadModuleForTest

-- Run the tests
runTests()
