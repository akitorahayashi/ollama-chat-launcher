## Overview

This project provides a modular AppleScript framework for automatically starting and managing an Ollama server and interacting with different language models directly from your terminal.

The main script (`Sources/Main.applescript`) is designed to be run from the Script Editor during development. It can also be manually saved as a standalone `.app` from the Script Editor.

## Project Structure

- `Sources/`: Contains all the AppleScript source code.
  - `Main.applescript`: The main entry point and logic for the application. All configuration is handled within this file.
  - `Modules/`: Contains helper modules for tasks like networking and window management.
- `Makefile`: Provides convenient commands for compiling modules and running tests.

## Prerequisites

- macOS with AppleScript support.
- Ollama installed.

## Development Workflow

### 1. Compile Modules

The `Makefile` is used to compile the source modules in `Sources/Modules/` into script objects (`.scpt`) in the `build/modules/` directory. The test scripts depend on these compiled modules.

```bash
make build
```
This command only compiles the modules, it does not create an application.

### 2. Running the Main Script

The main script (`Sources/Main.applescript`) can be run directly from the Apple Script Editor. When run this way, it will load the raw `.applescript` module files from the `Sources/Modules` directory, allowing for rapid development and testing without needing to recompile each time.

### 3. Running Tests

The test suite can be run via the `Makefile`. This will first compile the modules and then execute the test scripts.

```bash
make test
```

## Configuration

All configuration is handled directly within the `Sources/Main.applescript` file. To change the default model, port, or IP address, open this file and edit the properties at the top.

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

## Creating a Standalone Application

You can create a standalone `.app` from the main script by opening `Sources/Main.applescript` in Script Editor and choosing `File > Export...`. Set the `File Format` to `Application`.

The script includes logic to detect if it's running as an application. If so, it will attempt to load the compiled (`.scpt`) modules from its own `Contents/Resources` directory. For this to work, you must manually copy the compiled modules from `build/modules/` into your exported app's `Contents/Resources/` folder after exporting.
