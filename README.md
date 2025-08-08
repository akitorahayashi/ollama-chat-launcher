## Overview

This project provides a modular AppleScript framework for automatically starting and managing an Ollama server and interacting with different language models directly from your terminal.

The project is built into a standalone macOS Application (`.app`), providing a clean, easy-to-use interface for creating new terminal sessions with your favorite Ollama models. The model and other settings are fully configurable.

## Project Structure

- `Sources/`: Contains all the AppleScript source code.
  - `Main.applescript`: The main entry point and logic for the application. All configuration is handled within this file.
  - `Modules/`: Contains helper modules for tasks like networking and window management.
- `Makefile`: Provides convenient commands for building the application.

## Prerequisites

- macOS with AppleScript support.
- Ollama installed.

## Usage

This project uses a `Makefile` to simplify the build process.

### 1. Build the Application

This command compiles the main script and all modules into a standalone application, `Ollama Scripter.app`, located in the `build/` directory.

```bash
make build
```

### 2. Run the Application

After building the project, you can run the application in two ways:

1.  **From the command line:**
    ```bash
    open build/"Ollama Scripter.app"
    ```
2.  **From Finder:**
    Navigate to the `build` directory and double-click on `Ollama Scripter.app`.

Each time you run the application, it will:
- Check if an Ollama server is already running on the configured port.
- If not, it will open a new Terminal window and start the server.
- It will then open a new tab in that Terminal window and run the specified Ollama model.
- If a server is already running, it will simply open a new tab and run the model.

## Configuration

All configuration is handled directly within the `Sources/Main.applescript` file. To change the default model, port, or IP address, open this file and edit the properties at the top.

Because the model is configurable, you can easily switch to any model you have available in Ollama (e.g., `gemma`, `llama3`, `mistral`, etc.).

### Example Configuration (`Sources/Main.applescript`)

```applescript
-- ==========================================
-- Configuration
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 55764
-- Optional: Manually specify the server's IP address. If not set, the Wi-Fi IP is used, falling back to localhost if Wi-Fi is off.
property OVERRIDE_IP_ADDRESS : missing value
```

After changing a property like `MODEL_NAME`, simply rebuild the application to apply the changes:
```bash
make build
```
