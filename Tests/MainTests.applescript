-- Tests for Main.applescript

-- ==========================================
-- Test Runner
-- ==========================================
on runTests()
	log "Running tests for Main.applescript"
	set MainScript to loadModuleForTest("Main", true)

	try
		test_validateParameters_valid(MainScript)
		test_validateParameters_invalidIP(MainScript)
		test_validateParameters_invalidPort_low(MainScript)
		test_validateParameters_invalidPort_high(MainScript)
		test_validateParameters_invalidPort_text(MainScript)
		test_validateParameters_invalidModelName(MainScript)
	on error err
		error "A test failed: " & err
	end try
end runTests

-- ==========================================
-- Test Cases
-- ==========================================
on test_validateParameters_valid(MainScript)
	set testName to "test_validateParameters_valid"
	try
		MainScript's validateParameters("1.2.3.4", 12345, "good-model")
	on error err
		error "Test Failed: " & testName & ". Should not have thrown an error. Got: " & err
	end try
end test_validateParameters_valid

on test_validateParameters_invalidIP(MainScript)
	set testName to "test_validateParameters_invalidIP"
	try
		MainScript's validateParameters("invalid-ip", 12345, "good-model")
		error "Test Failed: " & testName & ". Should have thrown an error for invalid IP."
	on error err
		if err does not contain "Invalid IP address" then
			error "Test Failed: " & testName & ". Wrong error message. Got: " & err
		end if
	end try
end test_validateParameters_invalidIP

on test_validateParameters_invalidPort_low(MainScript)
	set testName to "test_validateParameters_invalidPort_low"
	try
		MainScript's validateParameters("1.2.3.4", 0, "good-model")
		error "Test Failed: " & testName & ". Should have thrown an error for low port."
	on error err
		if err does not contain "Port number out of valid range" then
			error "Test Failed: " & testName & ". Wrong error message. Got: " & err
		end if
	end try
end test_validateParameters_invalidPort_low

on test_validateParameters_invalidPort_high(MainScript)
	set testName to "test_validateParameters_invalidPort_high"
	try
		MainScript's validateParameters("1.2.3.4", 65536, "good-model")
		error "Test Failed: " & testName & ". Should have thrown an error for high port."
	on error err
		if err does not contain "Port number out of valid range" then
			error "Test Failed: " & testName & ". Wrong error message. Got: " & err
		end if
	end try
end test_validateParameters_invalidPort_high

on test_validateParameters_invalidPort_text(MainScript)
	set testName to "test_validateParameters_invalidPort_text"
	try
		MainScript's validateParameters("1.2.3.4", "not-a-port", "good-model")
		error "Test Failed: " & testName & ". Should have thrown an error for non-numeric port."
	on error err
		if err does not contain "Invalid port number" then
			error "Test Failed: " & testName & ". Wrong error message. Got: " & err
		end if
	end try
end test_validateParameters_invalidPort_text

on test_validateParameters_invalidModelName(MainScript)
	set testName to "test_validateParameters_invalidModelName"
	try
		MainScript's validateParameters("1.2.3.4", 12345, "")
		error "Test Failed: " & testName & ". Should have thrown an error for empty model name."
	on error err
		if err does not contain "Model name cannot be empty" then
			error "Test Failed: " & testName & ". Wrong error message. Got: " & err
		end if
	end try
end test_validateParameters_invalidModelName

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
