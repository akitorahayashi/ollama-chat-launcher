# Use bash with strict error handling for all shell commands
SHELL := /bin/bash -euo pipefail

# Application name
APP_NAME = Tinyllama

# Directories
SOURCES_DIR = Sources
MODULES_DIR = $(SOURCES_DIR)/Modules
TESTS_DIR   = Tests
BUILD_DIR   = build

# Output directories
COMPILED_MAIN_SCRIPT = $(BUILD_DIR)/Main.scpt
COMPILED_MODULES_DIR = $(BUILD_DIR)/Modules

# Source files
MAIN_SOURCE    = $(SOURCES_DIR)/Main.applescript
MODULE_SOURCES = $(wildcard $(MODULES_DIR)/*.applescript)
TEST_SOURCES   = $(wildcard $(TESTS_DIR)/*.applescript)
MODULE_NAMES   := $(basename $(notdir $(MODULE_SOURCES)))
TEST_NAMES     := $(basename $(notdir $(TEST_SOURCES)))

# Paths for compiled modules
COMPILED_MODULES = $(patsubst %,$(COMPILED_MODULES_DIR)/%.scpt,$(MODULE_NAMES))

# Dynamically generate test targets
test_targets = $(patsubst %,test-%,$(TEST_NAMES))

# Default target
all: build

# Main build target
build: clean $(COMPILED_MODULES) $(COMPILED_MAIN_SCRIPT)

# Create .app and copy modules
create: build
	@echo "Removing old $(APP_NAME).app if exists..."
	rm -rf $(APP_NAME).app
	@echo "Compiling build/Main.scpt to $(APP_NAME).app..."
	osacompile -o $(APP_NAME).app build/Main.scpt
	@echo "Copying modules to $(APP_NAME).app..."
	mkdir -p $(APP_NAME).app/Contents/Resources/Scripts/Modules
	cp build/Modules/*.scpt $(APP_NAME).app/Contents/Resources/Scripts/Modules/
	@echo "Done. $(APP_NAME).app is ready."

# Run the .app
run: create
	@echo "Launching $(APP_NAME).app..."
	open $(APP_NAME).app

# Rule to compile the main script
$(COMPILED_MAIN_SCRIPT): $(MAIN_SOURCE)
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling main script: $<"
	@osacompile -o "$@" "$<"

# Rule to compile a single module into the build directory
$(COMPILED_MODULES_DIR)/%.scpt: $(MODULES_DIR)/%.applescript
	@mkdir -p $(COMPILED_MODULES_DIR)
	@echo "Compiling module: $<"
	@osacompile -o "$@" "$<"

# Rule to run a single test
test-%:
	@printf '\n----- Running %s -----\n' "$(TESTS_DIR)/$*.applescript"
	@osascript "$(TESTS_DIR)/$*.applescript"
	@echo "---------------------------------"

# Run all tests
test: $(test_targets)
	@echo "\nAll tests completed successfully."

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	-@rm -rf $(BUILD_DIR)
	@echo "Done."

# Help message
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all        Builds all modules (default)"
	@echo "  build      Builds all modules"
	@echo "  create     Compiles and packages $(APP_NAME).app"
	@echo "  run        Creates (if needed) and launches $(APP_NAME).app"
	@echo "  test       Runs all tests"
	@echo "  test-<name> Runs a specific test (e.g., make test-CommandBuilderTests)"
	@echo "  clean      Removes all build artifacts"
	@echo "  help       Shows this help message"

.PHONY: all build create run test $(test_targets) clean help
