-- ==========================================
-- ネットワークモジュール
-- 役割: Wi-Fi IPアドレスの取得や、特定のポートが使用中かどうかの確認など、
--       ネットワーク関連の処理を担当します。
-- ==========================================
script NetworkManager
	property parent : missing value

	-- ==========================================
	-- ネットワーク関連関数群
	-- ==========================================
	on getWifiIP()
		set shell_result to parent's Utils's executeShell("ifconfig en0 | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}'", false)
		if not shell_result's success or shell_result's output is "" then
			parent's Utils's showError("ネットワークエラー", "Wi-Fi IPアドレスが取得できませんでした。Wi-Fiに接続しているか確認してください。", caution)
			error "Wi-Fi IPアドレスが取得できませんでした"
		end if
		return shell_result's output
	end getWifiIP

	on isPortInUse(port_number)
		set shell_result to parent's Utils's executeShell("lsof -i tcp:" & port_number, true)
		return shell_result's success
	end isPortInUse

	on waitForServer()
		set elapsed to 0
		repeat until my isPortInUse(parent's OLLAMA_PORT)
			delay parent's SERVER_CHECK_INTERVAL
			set elapsed to elapsed + parent's SERVER_CHECK_INTERVAL
			if elapsed > parent's SERVER_STARTUP_TIMEOUT then
				parent's Utils's showError("タイムアウト", "サーバーの起動がタイムアウトしました。手動で確認してください。", caution)
				return false
			end if
		end repeat
		return true
	end waitForServer
end script
