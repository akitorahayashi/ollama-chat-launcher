-- Tests for WindowManager.applescript

-- Load the test helper script
set testHelperPath to (path to me as text) & "TestHelper.applescript"
set TestHelper to load script file testHelperPath

-- Load the module to be tested
set WindowManager to TestHelper's loadModuleForTest("WindowManager", false)

-- Run all tests
runTests()

on runTests()
	log "Running tests for WindowManager.applescript"

	try
		test_generateWindowTitle()
		test_extractSequenceNumber_valid()
		test_extractSequenceNumber_invalid()
		test_extractSequenceNumber_noDot()
		test_getMaxSequenceNumberFromList_normal()
		test_getMaxSequenceNumberFromList_empty()
		test_getMaxSequenceNumberFromList_single()

		log "All WindowManager tests passed."
	on error err
		log "A test failed: " & err
		error err
	end try

	log "Tests for WindowManager.applescript completed."
end runTests

-- Test cases
on test_generateWindowTitle()
	set expected to "3.llama2 Server [192.168.1.1:12345]"
	set actual to WindowManager's generateWindowTitle("192.168.1.1", 3, 12345, "llama2")
	TestHelper's assertEquals(expected, actual, "test_generateWindowTitle")
end test_generateWindowTitle

on test_extractSequenceNumber_valid()
	set title to "12.some-model Server [1.2.3.4:5678]"
	set expected to 12
	set actual to WindowManager's _extractSequenceNumber(title)
	TestHelper's assertEquals(expected, actual, "test_extractSequenceNumber_valid")
end test_extractSequenceNumber_valid

on test_extractSequenceNumber_invalid()
	set title to "invalid.some-model Server [1.2.3.4:5678]"
	set expected to missing value
	set actual to WindowManager's _extractSequenceNumber(title)
	TestHelper's assertEquals(expected, actual, "test_extractSequenceNumber_invalid")
end test_extractSequenceNumber_invalid

on test_extractSequenceNumber_noDot()
	set title to "no-dot-title"
	set expected to missing value
	set actual to WindowManager's _extractSequenceNumber(title)
	TestHelper's assertEquals(expected, actual, "test_extractSequenceNumber_noDot")
end test_extractSequenceNumber_noDot

on test_getMaxSequenceNumberFromList_normal()
	set server_list to [{sequence:1}, {sequence:5}, {sequence:3}]
	set expected to 5
	set actual to WindowManager's _getMaxSequenceNumberFromList(server_list)
	TestHelper's assertEquals(expected, actual, "test_getMaxSequenceNumberFromList_normal")
end test_getMaxSequenceNumberFromList_normal

on test_getMaxSequenceNumberFromList_empty()
	set server_list to {}
	set expected to 0
	set actual to WindowManager's _getMaxSequenceNumberFromList(server_list)
	TestHelper's assertEquals(expected, actual, "test_getMaxSequenceNumberFromList_empty")
end test_getMaxSequenceNumberFromList_empty

on test_getMaxSequenceNumberFromList_single()
	set server_list to [{sequence:10}]
	set expected to 10
	set actual to WindowManager's _getMaxSequenceNumberFromList(server_list)
	TestHelper's assertEquals(expected, actual, "test_getMaxSequenceNumberFromList_single")
end test_getMaxSequenceNumberFromList_single
