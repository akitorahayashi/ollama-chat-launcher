-- Tests for Network.applescript

-- ==========================================
-- Test Runner
-- ==========================================
on runTests()
	log "Running tests for Network.applescript"
	set Network to loadModuleForTest("Network", false)

	try
		-- Reset test flags before each run
		set Network's _forceWifiFailureForTesting to false

		test_getIPAddress_withOverride(Network)
		test_getIPAddress_fallbackToLocalhost(Network)

	on error err
		-- Ensure flag is reset even if a test fails
		set Network's _forceWifiFailureForTesting to false
		error "A test failed: " & err
	end try
end runTests

-- ==========================================
-- Test Cases
-- ==========================================
on test_getIPAddress_withOverride(Network)
	set testName to "test_getIPAddress_withOverride"
	set expected to "1.2.3.4"
	set actual to Network's getIPAddress(expected)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_getIPAddress_withOverride

on test_getIPAddress_fallbackToLocalhost(Network)
	set testName to "test_getIPAddress_fallbackToLocalhost"
	set Network's _forceWifiFailureForTesting to true

	set expected to "127.0.0.1"
	set actual to Network's getIPAddress(missing value)

	set Network's _forceWifiFailureForTesting to false

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_getIPAddress_fallbackToLocalhost

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
