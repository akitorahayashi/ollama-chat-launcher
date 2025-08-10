-- Tests for ServerManager.applescript

-- Load the test helper script
set testHelperPath to (path to me as text) & "TestHelper.applescript"
set TestHelper to load script file testHelperPath

-- Load the module to be tested
set ServerManager to TestHelper's loadModuleForTest("ServerManager", false)

-- Run all tests
runTests()

on runTests()
	log "Running tests for ServerManager.applescript"

	try
		test_roundDown_positive()
		test_roundDown_integer()
		test_roundDown_zero()

		log "All ServerManager tests passed."
	on error err
		log "A test failed: " & err
		error err
	end try

	log "Tests for ServerManager.applescript completed."
end runTests

-- Test cases
on test_roundDown_positive()
	set expected to 5
	set actual to ServerManager's roundDown(5.7)
	TestHelper's assertEquals(expected, actual, "test_roundDown_positive")
end test_roundDown_positive

on test_roundDown_integer()
	set expected to 10
	set actual to ServerManager's roundDown(10)
	TestHelper's assertEquals(expected, actual, "test_roundDown_integer")
end test_roundDown_integer

on test_roundDown_zero()
	set expected to 0
	set actual to ServerManager's roundDown(0.2)
	TestHelper's assertEquals(expected, actual, "test_roundDown_zero")
end test_roundDown_zero

-- NOTE: The following handlers are not tested because they involve
-- complex side effects like network calls, shell scripts, and GUI manipulation,
-- which are not suitable for simple, repeatable unit tests.
-- - isOllamaServerRunning
-- - startServer
-- - waitForServer
-- - executeModelInWindow
-- - openChatInNewWindow
