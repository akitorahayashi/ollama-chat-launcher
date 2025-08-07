## Overview

This is an AppleScript that automatically starts the Ollama server and model.

## Features

- Automatically retrieves the IP address, with an option for manual setting.
- Checks port usage.
- Easy to customize.

## Configuration

Edit the configuration section at the top of the script.

```applescript
set model_name to "gemma3:latest"
set ollama_port to 11500
set local_ip to getLocalIP() // Auto-detect or enter a fixed IP like "192.168.1.100"
```

### IP Configuration Patterns

- **Local PC**: `set local_ip to getLocalIP()`
- **Wi-Fi**: `set local_ip to getWifiIP()`
- **Static IP**: `set local_ip to "192.168.1.100"` (example)

## Usage

### Basic
1. Run the script.
2. The Ollama server will start automatically.
3. The specified model will be executed.

### Quick Action
1. Automator -> New -> Quick Action
2. Add "Run AppleScript"
3. Paste the script content
4. Save