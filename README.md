# Ollama AppleScript Runner

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

This command compiles all the necessary AppleScript modules and the main library into the `build/` directory.

```bash
make build
```

### Run the Application

This command executes the default entry point script (`Tinyllama.applescript`). This will start the Ollama server with the configuration defined in that file.

```bash
make run
```

### Run Tests

This command runs all the tests located in the `Tests/` directory.

```bash
make test
```

## Configuration

To change the model or port, you can edit the entry point script (`Tinyllama.applescript`) or create a new one.

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

### Creating a New Configuration

1.  Create a copy of `Tinyllama.applescript` and name it something descriptive (e.g., `Gemma.applescript`).
2.  Edit the `MODEL_NAME` and `OLLAMA_PORT` properties in your new file.
3.  To run your new configuration, you can either execute it directly with `osascript` or update the `run` target in the `Makefile` to point to your new script.