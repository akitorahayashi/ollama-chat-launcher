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

To customize the application, you can create and edit entry point scripts like `Tinyllama.applescript`. This file serves as the main configuration file for a specific model.

To create a new configuration for a different model, simply copy the `Tinyllama.applescript` file. For example, to create a configuration for a Gemma model, you could run the following command in your terminal:

```bash
cp Tinyllama.applescript Gemma.applescript
```

Then, open the new `Gemma.applescript` file and edit the configuration properties (`MODEL_NAME`, `OLLAMA_PORT`, `OVERRIDE_IP_ADDRESS`) at the top to match your needs.

### Example Configuration (`Tinyllama.applescript`)

The entry point script contains all the necessary configuration properties. Below is the full content of `Tinyllama.applescript`, which you can use as a template.

```applescript
-- ==========================================
-- Configuration
-- ==========================================
property MODEL_NAME : "tinyllama"
property OLLAMA_PORT : 55764
-- Optional: Manually specify the IP address for the server.
-- If set to 'missing value', the script will automatically use the active
-- Wi-Fi IP address, or fall back to localhost (127.0.0.1).
-- This is useful for setups like macOS Internet Sharing (e.g., "192.168.2.1").
-- Example: property OVERRIDE_IP_ADDRESS : "192.168.2.1"
property OVERRIDE_IP_ADDRESS : missing value

-- ==========================================
-- Main Logic
-- ==========================================
try
    tell application "Finder"
        set project_folder to (container of (path to me)) as text
    end tell
    set main_lib_path to (project_folder & "build:Main.scpt")

    set MainLib to load script alias main_lib_path
    MainLib's runWithConfiguration(MODEL_NAME, OLLAMA_PORT, OVERRIDE_IP_ADDRESS)

on error err
    log "Error in Tinyllama entry point: " & err
end try
```
