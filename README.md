## Overview

This project provides a modular AppleScript framework for automatically starting and managing local Ollama servers, making it easy to interact with different language models directly from your terminal.

## Features

- **Automatic Server Management**: Automatically starts a new Ollama server if one isn't running on the configured IP and port.
- **Smart Window Handling**: If a server is already running, the script finds the existing Terminal window and opens a new tab for a chat session instead of creating a new server.
- **Dynamic IP Detection**: Automatically uses your local Wi-Fi IP address, or falls back to `localhost` if Wi-Fi is disconnected. You can also override this with a static IP.
- **Easy Configuration**: All settings are managed via properties at the top of the main script.

## Prerequisites

- macOS with AppleScript support.
- Ollama installed and accessible in your system's path.

## How to Use

### 1. Configure the Script

Open `Sources/Main.applescript` and edit the properties at the top to match your desired setup.

```applescript
-- ==========================================
-- Configuration
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 55765
-- Optional: Manually specify the server's IP address.
property OVERRIDE_IP_ADDRESS : missing value
-- Optional: Specify a custom path for Ollama models.
property OLLAMA_MODELS_PATH : "~/.ollama/models"
```

### 2. Build the Modules

The script is modular and requires its components to be compiled before the first run. The `Makefile` handles this process.

```bash
make build
```
This command compiles the source files from `Sources/Modules/` into executable script objects (`.scpt`) in the `build/modules/` directory.

### 3. Run from Script Editor

Run the main script `Sources/Main.applescript` directly from the Apple Script Editor. The script will automatically detect the correct IP, check if a server is already running, and either create a new server instance or a new chat tab in the existing server's window.

### 4. Create a Standalone Application

You can create a standalone `.app` for easier access.

1.  Open `Sources/Main.applescript` in Script Editor.
2.  Choose `File > Export...` and set the `File Format` to `Application`.
3.  After exporting, you must manually copy the compiled modules from `build/modules/` into your app's bundle. The destination path inside the app is: `YourApp.app/Contents/Resources/Modules/`.

The script is designed to look for modules in this location when it's run as a standalone application.

## Development and How It Works

- **`Sources/`**: Contains all AppleScript source code.
  - `Main.applescript`: The main entry point and application logic.
  - `Modules/`: Helper modules for tasks like networking, window management, and command construction.
- **`build/`**: Directory for compiled script objects. This is created by the `Makefile`.
- **`Makefile`**: Provides commands for building and cleaning the project.

### Module Loading

When you run `Main.applescript` from the Script Editor, it **always** loads the compiled (`.scpt`) modules from the `build/modules/` directory. It does **not** load the raw `.applescript` source files. Therefore, you must run `make build` after any changes to the modules for them to take effect.
