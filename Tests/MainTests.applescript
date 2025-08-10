-- Tests for Main.applescript

-- Load the test helper script
set testHelperPath to (path to me as text) & "TestHelper.applescript"
set TestHelper to load script file testHelperPath

-- Load the main script to be tested
set MainScript to TestHelper's loadModuleForTest("Main", true)

-- Run all tests
runTests()

on runTests()
	log "Running tests for Main.applescript"

	try
		test_validateParameters_valid()
		test_validateParameters_invalidIP()
		test_validateParameters_invalidPort_low()
		test_validateParameters_invalidPort_high()
		test_validateParameters_invalidPort_text()
		test_validateParameters_invalidModelName()

		log "All Main script tests passed."
	on error err
		log "A test failed: " & err
		error err
	end try

	log "Tests for Main.applescript completed."
end runTests

-- Test cases for validateParameters
on test_validateParameters_valid()
	try
		MainScript's validateParameters("1.2.3.4", 12345, "good-model")
		TestHelper's assertTrue(true, "test_validateParameters_valid")
	on error
		TestHelper's fail("test_validateParameters_valid", "Should not have thrown an error.")
	end try
end test_validateParameters_valid

on test_validateParameters_invalidIP()
	try
		MainScript's validateParameters("invalid-ip", 12345, "good-model")
		TestHelper's fail("test_validateParameters_invalidIP", "Should have thrown an error for invalid IP.")
	on error err
		TestHelper's assertContains("Invalid IP address", err, "test_validateParameters_invalidIP")
	end try
end test_validateParameters_invalidIP

on test_validateParameters_invalidPort_low()
	try
		MainScript's validateParameters("1.2.3.4", 0, "good-model")
		TestHelper's fail("test_validateParameters_invalidPort_low", "Should have thrown an error for low port.")
	on error err
		TestHelper's assertContains("Port number out of valid range", err, "test_validateParameters_invalidPort_low")
	end try
end test_validateParameters_invalidPort_low

on test_validateParameters_invalidPort_high()
	try
		MainScript's validateParameters("1.2.3.4", 65536, "good-model")
		TestHelper's fail("test_validateParameters_invalidPort_high", "Should have thrown an error for high port.")
	on error err
		TestHelper's assertContains("Port number out of valid range", err, "test_validateParameters_invalidPort_high")
	end try
end test_validateParameters_invalidPort_high

on test_validateParameters_invalidPort_text()
	try
		MainScript's validateParameters("1.2.3.4", "not-a-port", "good-model")
		TestHelper's fail("test_validateParameters_invalidPort_text", "Should have thrown an error for non-numeric port.")
	on error err
		TestHelper's assertContains("Invalid port number", err, "test_validateParameters_invalidPort_text")
	end try
end test_validateParameters_invalidPort_text

on test_validateParameters_invalidModelName()
	try
		MainScript's validateParameters("1.2.3.4", 12345, "")
		TestHelper's fail("test_validateParameters_invalidModelName", "Should have thrown an error for empty model name.")
	on error err
		TestHelper's assertContains("Model name cannot be empty", err, "test_validateParameters_invalidModelName")
	end try
end test_validateParameters_invalidModelName

-- NOTE: The main execution block of Main.applescript is not tested
-- as it constitutes an integration test of the entire application.
