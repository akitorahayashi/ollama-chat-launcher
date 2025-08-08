-- ==========================================
-- Main Module Tests
-- ==========================================

-- Mainモジュールをロード
global MainModule
set script_path to path to me
tell application "Finder"
	set script_container to container of script_path as text
	set parent_container to container of alias script_container as text
end tell
set MainModule to load script alias (parent_container & "build:Main.scpt")

-- グローバル変数でテスト状態を管理
global test_server_window, test_chat_tab, test_model_name, test_port, test_ip

-- テスト設定
set test_model_name to "tinyllama"
set test_port to "11435"
set test_ip to "127.0.0.1"

-- ==========================================
-- Test Cases
-- ==========================================

-- テスト1: ポートが使用中の場合のエラー処理
on testPortInUseError()
	log "Test 1: Testing port in use error handling"
	try
		-- 事前にポートを使用状態にする（テスト用サーバを起動）
		do shell script "echo 'Starting test server on port " & test_port & "'"
		do shell script "nohup python3 -m http.server " & test_port & " > /dev/null 2>&1 &"
		delay 2
		
		-- MainのrunWithConfigurationを実行（エラーが期待される）
		try
			MainModule's runWithConfiguration(test_model_name, test_port, test_ip)
			log "✗ Test 1 FAILED: Expected error did not occur"
		on error expected_error
			if expected_error contains "Port" and expected_error contains "already in use" then
				log "✓ Test 1 PASSED: Correctly detected port in use"
			else
				log "✗ Test 1 FAILED: Unexpected error: " & expected_error
			end if
		end try
		
		-- テスト用サーバを停止
		do shell script "pkill -f 'python3 -m http.server " & test_port & "'"
		delay 1
		
	on error test_error
		log "✗ Test 1 ERROR: " & test_error
		-- テスト用サーバを停止（エラー時のクリーンアップ）
		try
			do shell script "pkill -f 'python3 -m http.server " & test_port & "'"
		end try
	end try
end testPortInUseError

-- テスト2: 既存サーバウィンドウでの新しいタブ作成
on testExistingServerNewTab()
	log "Test 2: Testing new tab creation in existing server window"
	try
		-- 最初にサーバを起動
		MainModule's runWithConfiguration(test_model_name, test_port, test_ip)
		delay 5
		
		-- サーバウィンドウを取得
		tell application "Terminal"
			if (count of windows) > 0 then
				set test_server_window to front window
				set initial_tab_count to count of tabs of test_server_window
			else
				error "No Terminal windows found"
			end if
		end tell
		
		-- 2回目の実行（新しいタブが作成されるはず）
		MainModule's runWithConfiguration(test_model_name, test_port, test_ip)
		delay 3
		
		tell application "Terminal"
			set final_tab_count to count of tabs of test_server_window
			if final_tab_count > 0 then
				set test_chat_tab to tab final_tab_count of test_server_window
			end if
		end tell
		
		if final_tab_count > initial_tab_count then
			log "✓ Test 2 PASSED: New tab created in existing server window"
		else
			log "✗ Test 2 FAILED: No new tab was created"
		end if
		
		-- クリーンアップ
		my cleanup()
		
	on error test_error
		log "✗ Test 2 ERROR: " & test_error
		my cleanup()
	end try
end testExistingServerNewTab

-- テスト3: 新しいサーバ起動とチャット開始
on testNewServerStartup()
	log "Test 3: Testing new server startup and chat initiation"
	try
		-- ポートが空いていることを確認
		do shell script "lsof -ti:" & test_port & " | xargs kill -9" & " || true"
		delay 1
		
		-- 初回実行（新しいサーバが起動されるはず）
		MainModule's runWithConfiguration(test_model_name, test_port, test_ip)
		delay 8
		
		tell application "Terminal"
			if (count of windows) > 0 then
				set test_server_window to front window
				set tab_count to count of tabs of test_server_window
				if tab_count >= 2 then
					set test_chat_tab to tab tab_count of test_server_window
					log "✓ Test 3 PASSED: New server started and chat initiated"
				else
					log "✗ Test 3 FAILED: Expected at least 2 tabs (server + chat), found " & tab_count
				end if
			else
				error "No Terminal windows found"
			end if
		end tell
		
		-- クリーンアップ
		my cleanup()
		
	on error test_error
		log "✗ Test 3 ERROR: " & test_error
		my cleanup()
	end try
end testNewServerStartup

-- ==========================================
-- Main Test Runner
-- ==========================================

log "Starting Main Module Tests..."
log "Test configuration: Model=" & test_model_name & ", Port=" & test_port & ", IP=" & test_ip

-- テスト実行
my testPortInUseError()
delay 2
my testExistingServerNewTab()
delay 2
my testNewServerStartup()

log "All tests completed!"

-- 最終的なクリーンアップ（念のため）
try
	do shell script "lsof -ti:" & test_port & " | xargs kill -9" & " || true"
	delay 1
on error
	-- エラーは無視（プロセスが存在しない場合）
end try

log "Main Module Tests finished."

-- ==========================================
-- Test Helper Functions
-- ==========================================

-- チャットタブを終了（Ctrl+D）
on terminateChat()
	if test_chat_tab is not missing value then
		tell application "Terminal"
			set frontmost to true
			do script "exit" in test_chat_tab
		end tell
		delay 2
		log "Chat terminated"
	end if
end terminateChat

-- サーバを終了（Ctrl+C）
on terminateServer()
	if test_server_window is not missing value then
		tell application "Terminal"
			set frontmost to true
			-- サーバタブ（最初のタブ）を選択
			set selected tab of test_server_window to tab 1 of test_server_window
			-- Ctrl+Cを送信してサーバを停止
			tell application "System Events"
				key code 8 using control down
			end tell
		end tell
		delay 3
		log "Server terminated"
	end if
end terminateServer

-- ウィンドウを閉じる
on closeTestWindow()
	if test_server_window is not missing value then
		tell application "Terminal"
			close test_server_window
		end tell
		log "Test window closed"
	end if
end closeTestWindow

-- テスト後のクリーンアップ
on cleanup()
	try
		if test_chat_tab is not missing value then
			my terminateChat()
		end if
		if test_server_window is not missing value then
			my terminateServer()
			my closeTestWindow()
		end if
		log "Test cleanup completed"
	on error cleanup_error
		log "Cleanup error: " & cleanup_error
	end try
end cleanup