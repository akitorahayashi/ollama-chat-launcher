-- ServerManager.applescript
-- This module is responsible for waiting for the server to start.

property SERVER_STARTUP_TIMEOUT : 30
property SERVER_CHECK_INTERVAL : 0.5 -- Increased from 0.1 to reduce CPU usage

on waitForServer(ip_address, ollama_port, Network)
	set elapsed to 0
	set last_log_time to -10 -- Initialize to ensure the first log appears immediately
	log "Waiting for server to start... (Timeout: " & SERVER_STARTUP_TIMEOUT & "s)"

	repeat until Network's isPortInUse(ollama_port, ip_address)
		delay SERVER_CHECK_INTERVAL
		set elapsed to elapsed + SERVER_CHECK_INTERVAL

		if elapsed > SERVER_STARTUP_TIMEOUT then
			log "Timeout: Server startup timed out. Please check manually."
			return false
		end if

		-- Log progress every 5 seconds
		if (elapsed - last_log_time) > 5 then
			log "Waiting... " & round (elapsed) & "s / " & SERVER_STARTUP_TIMEOUT & "s"
			set last_log_time to elapsed
		end if
	end repeat

	log "Server started successfully."
	return true
end waitForServer

on round(n)
	return n div 1
end round
