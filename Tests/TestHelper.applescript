-- TestHelper.applescript
-- Provides common utility handlers for running tests.

-- Loads a module script from the 'Sources/Modules' or 'Sources' directory.
on loadModuleForTest(moduleName, isMain)
	try
		set scriptPath to POSIX path of (path to me)
		set testsDir to do shell script "dirname " & quoted form of scriptPath
		set projectRoot to do shell script "dirname " & quoted form of testsDir

		set modulePathPOSIX to ""
		if isMain is true then
			set modulePathPOSIX to projectRoot & "/Sources/" & moduleName & ".applescript"
		else
			set modulePathPOSIX to projectRoot & "/Sources/Modules/" & moduleName & ".applescript"
		end if

		return load script file (modulePathPOSIX)
	on error errMsg number errNum
		error "TestHelper failed to load module '" & moduleName & "'. Reason: " & errMsg
	end try
end loadModuleForTest

-- A simple assertion handler to make tests more readable.
-- Throws an error if the actual value does not equal the expected value.
on assertEquals(expected, actual, testName)
	if actual is not expected then
		error "Test Failed: " & testName & "
--> Expected: " & (expected as text) & "
--> Got: " & (actual as text)
	else
		log "Test Passed: " & testName
	end if
end assertEquals

on assertContains(expected_substring, actual_string, testName)
	if actual_string does not contain expected_substring then
		error "Test Failed: " & testName & "
--> Expected to contain: " & (expected_substring as text) & "
--> Got: " & (actual_string as text)
	else
		log "Test Passed: " & testName
	end if
end assertContains

on assertTrue(condition, testName)
	if not condition then
		error "Test Failed: " & testName & "
--> Expected: true
--> Got: false"
	else
		log "Test Passed: " & testName
	end if
end assertTrue

on assertFalse(condition, testName)
	if condition then
		error "Test Failed: " & testName & "
--> Expected: false
--> Got: true"
	else
		log "Test Passed: " & testName
	end if
end assertFalse

on fail(testName, message)
	error "Test Failed: " & testName & "
--> " & message
end fail
