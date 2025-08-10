-- Tests for Network.applescript

-- Load the test helper script
set testHelperPath to (path to me as text) & "TestHelper.applescript"
set TestHelper to load script file testHelperPath

-- Load the module to be tested
set Network to TestHelper's loadModuleForTest("Network", false)

-- Run all tests
runTests()

on runTests()
	log "Running tests for Network.applescript"

	try
		-- Reset test flags before each run
		set Network's _forceWifiFailureForTesting to false

		test_getIPAddress_withOverride()
		test_getIPAddress_fallbackToLocalhost()
		-- We don't test the success case for Wi-Fi as it depends on the machine's state.
		-- The fallback test covers the other branch of the logic.

		log "All Network tests passed."
	on error err
		-- Ensure flag is reset even if a test fails
		set Network's _forceWifiFailureForTesting to false
		log "A test failed: " & err
		error err
	end try

	log "Tests for Network.applescript completed."
end runTests

-- Test cases
on test_getIPAddress_withOverride()
	set override_ip to "1.2.3.4"
	set actual_ip to Network's getIPAddress(override_ip)
	TestHelper's assertEquals(override_ip, actual_ip, "test_getIPAddress_withOverride")
end test_getIPAddress_withOverride

on test_getIPAddress_fallbackToLocalhost()
	-- Set the test flag to force the fallback logic
	set Network's _forceWifiFailureForTesting to true

	set expected_ip to "127.0.0.1"
	-- Pass missing value to ensure the override is not used
	set actual_ip to Network's getIPAddress(missing value)

	-- Reset the flag immediately after the call
	set Network's _forceWifiFailureForTesting to false

	TestHelper's assertEquals(expected_ip, actual_ip, "test_getIPAddress_fallbackToLocalhost")
end test_getIPAddress_fallbackToLocalhost
