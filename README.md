## Overview

This project provides a modular AppleScript framework for automatically starting and managing local Ollama servers, making it easy to interact with different language models directly from your terminal.

## Features

- **Automatic Server Management**: Automatically starts a new Ollama server if one isn't running on the configured IP and port.
- **Smart Window Handling**: If a server is already running, the script finds the existing Terminal window and opens a new tab for a chat session instead of creating a new server.
- **Dynamic IP Detection**: Automatically uses your local Wi-Fi IP address, or falls back to `localhost` if Wi-Fi is disconnected. You can also override this with a static IP.
- **Easy Configuration**: All settings are managed via properties at the top of the main script.

## Prerequisites

- macOS with AppleScript support.
- Ollama installed and accessible via your `PATH` environment variable.

## How to Use

### 1. Configure the Script

Open `Sources/Main.applescript` and edit the properties at the top to match your desired setup.

```applescript
-- ==========================================
-- Configuration
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 11434 -- Default Ollama port. Change only if you intentionally use a different instance.
-- Optional: Manually specify the server's IP address.
property OVERRIDE_IP_ADDRESS : missing value
-- Optional: Specify a custom path for Ollama models. Use $HOME instead of ~ for reliability.
property OLLAMA_MODELS_PATH : "$HOME/.ollama/models"
```

### 2. Build the Script

The `Makefile` handles the compilation of the main script and all its modules.

```bash
make build
```
This command compiles `Sources/Main.applescript` into `build/Main.scpt` and all modules from `Sources/Modules/` into the `build/Modules/` directory.

### 3. Run the Compiled Script

Execute the compiled script from your terminal.

```bash
osascript build/Main.scpt
```

The script will automatically detect the correct IP, check if a server is already running, and either create a new server instance or a new chat tab in the existing server's window. 

**Note:** On the first run, macOS may prompt for Automation permissions to control the Terminal application. Please allow it for the script to function correctly.

## Development and How It Works

- **`Sources/`**: Contains all AppleScript source code.
  - `Main.applescript`: The main entry point and application logic.
  - `Modules/`: Helper modules for tasks like networking, window management, and command construction.
- **`build/`**: Directory for all compiled script objects (`.scpt`). This directory is created and managed by the `Makefile`.
  - `Main.scpt`: The compiled, executable main script.
  - `Modules/`: Contains all compiled helper modules.
- **`Makefile`**: Provides commands for building and cleaning the project.

### Build and Execution Flow

1.  `make build` compiles all `.applescript` files from the `Sources` directory into `.scpt` files in the `build` directory.
2.  Running `osascript build/Main.scpt` executes the main script.
3.  The `Main.scpt` loads its required modules from the `build/Modules/` directory relative to its own location.

This ensures that you are always running a fully compiled version of the script and its dependencies. Remember to run `make build` after making any changes to the source files.