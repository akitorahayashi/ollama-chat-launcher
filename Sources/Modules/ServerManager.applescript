-- ServerManager.applescript
-- サーバーが起動するのを待つ責務を担うモジュール

property SERVER_STARTUP_TIMEOUT : 30
property SERVER_CHECK_INTERVAL : 0.1

on waitForServer(ip_address, ollama_port, Network)
	set elapsed to 0
	repeat until Network's isPortInUse(ollama_port, ip_address)
		delay SERVER_CHECK_INTERVAL
		set elapsed to elapsed + SERVER_CHECK_INTERVAL
		if elapsed > SERVER_STARTUP_TIMEOUT then
			log "Timeout: Server startup timed out. Please check manually."
			return false
		end if
	end repeat
	return true
end waitForServer
