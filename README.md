## Overview

This project provides a modular AppleScript framework for automatically starting and managing an Ollama server and interacting with different models.

The project is structured to separate the core logic from the specific configurations (like which model to run and on which port), allowing for easy customization and extension.

## Project Structure

- `Sources/`: Contains the core logic.
  - `Main.applescript`: A library script containing the main application logic. It does not run on its own.
  - `Modules/`: Contains helper modules for tasks like networking and window management.
- `Tests/`: Contains unit and integration tests for the modules and the main application flow.
- `Tinyllama.applescript`: An example entry point script. This is what you run to start the application. It defines the configuration and calls the main library.
- `Makefile`: Provides convenient commands for building, running, and testing the project.

## Prerequisites

- macOS with AppleScript support.
- Ollama installed.

## Usage

This project uses a `Makefile` to simplify common tasks.

### Build the Project

This command compiles all the necessary AppleScript modules and the main library into the `build/` directory. You must run this before executing any entry point scripts.

```bash
make build
```

### Running the Application

After building the project, you can run any of the model-specific entry point scripts. These scripts, like `Tinyllama.applescript`, define which model to run and on which port.

There are two primary ways to run an entry point script:

1.  **Using the command line:**
    Open your terminal, navigate to the project directory, and use `osascript`:
    ```bash
    osascript Tinyllama.applescript
    ```

2.  **Using Script Editor:**
    Open the entry point script (e.g., `Tinyllama.applescript`) in the Script Editor application and click the "Run" button.

### Run Tests

This command runs all the tests located in the `Tests/` directory.

```bash
make test
```

## Configuration

To change the model or port, you can create and edit entry point scripts. The project is designed to support multiple configurations for different models (e.g., `Tinyllama.applescript`, `Gemma.applescript`).

### Example: `Tinyllama.applescript`

```applescript
-- ==========================================
-- Configuration
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 55764

-- ==========================================
-- Main Logic
-- ==========================================
try
  tell application "Finder"
    set project_folder to (container of (path to me)) as text
  end tell
  set main_lib_path to (project_folder & "build:Main.scpt")

  set MainLib to load script alias main_lib_path
  MainLib's runWithConfiguration(MODEL_NAME, OLLAMA_PORT)

on error err
  log "Error in Tinyllama entry point: " & err
end try
```

### Creating a New Model Entrypoint

1.  Create a copy of an existing entry point script (like `Tinyllama.applescript`) and give it a descriptive name (e.g., `Gemma.applescript`).
2.  Open the new file and edit the `MODEL_NAME` and `OLLAMA_PORT` properties to match your desired configuration.
3.  Run your new script using one of the methods described in the "Running the Application" section.
