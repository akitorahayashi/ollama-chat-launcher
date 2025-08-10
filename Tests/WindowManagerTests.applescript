-- Tests for WindowManager.applescript

-- ==========================================
-- Test Runner
-- ==========================================
on runTests()
	log "Running tests for WindowManager.applescript"
	set WindowManager to loadModuleForTest("WindowManager", false)

	try
		test_generateWindowTitle(WindowManager)
		test_extractSequenceNumber_valid(WindowManager)
		test_extractSequenceNumber_invalid(WindowManager)
		test_extractSequenceNumber_noDot(WindowManager)
		test_getMaxSequenceNumberFromList_normal(WindowManager)
		test_getMaxSequenceNumberFromList_empty(WindowManager)
		test_getMaxSequenceNumberFromList_single(WindowManager)
	on error err
		error "A test failed: " & err
	end try
end runTests

-- ==========================================
-- Test Cases
-- ==========================================
on test_generateWindowTitle(WindowManager)
	set testName to "test_generateWindowTitle"
	set expected to "3.llama2 Server [192.168.1.1:12345]"
	set actual to WindowManager's generateWindowTitle("192.168.1.1", 3, 12345, "llama2")

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_generateWindowTitle

on test_extractSequenceNumber_valid(WindowManager)
	set testName to "test_extractSequenceNumber_valid"
	set title to "12.some-model Server [1.2.3.4:5678]"
	set expected to 12
	set actual to WindowManager's _extractSequenceNumber(title)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_extractSequenceNumber_valid

on test_extractSequenceNumber_invalid(WindowManager)
	set testName to "test_extractSequenceNumber_invalid"
	set title to "invalid.some-model Server [1.2.3.4:5678]"
	set expected to missing value
	set actual to WindowManager's _extractSequenceNumber(title)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: missing value
--> Got: " & actual
	end if
end test_extractSequenceNumber_invalid

on test_extractSequenceNumber_noDot(WindowManager)
	set testName to "test_extractSequenceNumber_noDot"
	set title to "no-dot-title"
	set expected to missing value
	set actual to WindowManager's _extractSequenceNumber(title)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: missing value
--> Got: " & actual
	end if
end test_extractSequenceNumber_noDot

on test_getMaxSequenceNumberFromList_normal(WindowManager)
	set testName to "test_getMaxSequenceNumberFromList_normal"
	set server_list to [{sequence:1}, {sequence:5}, {sequence:3}]
	set expected to 5
	set actual to WindowManager's _getMaxSequenceNumberFromList(server_list)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_getMaxSequenceNumberFromList_normal

on test_getMaxSequenceNumberFromList_empty(WindowManager)
	set testName to "test_getMaxSequenceNumberFromList_empty"
	set server_list to {}
	set expected to 0
	set actual to WindowManager's _getMaxSequenceNumberFromList(server_list)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_getMaxSequenceNumberFromList_empty

on test_getMaxSequenceNumberFromList_single(WindowManager)
	set testName to "test_getMaxSequenceNumberFromList_single"
	set server_list to [{sequence:10}]
	set expected to 10
	set actual to WindowManager's _getMaxSequenceNumberFromList(server_list)

	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & expected & "
--> Got: " & actual
	end if
end test_getMaxSequenceNumberFromList_single

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
