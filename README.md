## 概要

Ollamaサーバーとモデルを自動起動するAppleScriptです。

## 特徴

- IPアドレスを自動で取得、手動で設定も可能
- ポート使用状況をチェック
- 簡単なカスタマイズ

## 設定

スクリプト上部の設定セクションを編集する

```applescript
set model_name to "gemma3:latest"
set ollama_port to 11500
set local_ip to getLocalIP() -- 自動取得 or "192.168.1.100" のように固定値を直接入力
```

### IP設定のパターン

- **Local PC**: `set local_ip to getLocalIP()`
- **Wi-Fi**: `set local_ip to getWifiIP()`
- **固定IP**: `set local_ip to "192.168.1.100"`（例）

## 使い方

### 基本
1. スクリプトを実行
2. 自動でOllamaサーバーが起動
3. 指定したモデルが実行される

### クイックアクション
1. Automator → 新規 → クイックアクション
2. AppleScriptを実行 を追加
3. スクリプト内容を貼り付け
4. 保存