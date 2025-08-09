# Directories
SOURCES_DIR = Sources
MODULES_DIR = $(SOURCES_DIR)/Modules
BUILD_DIR   = build

# Output directories
COMPILED_MAIN_SCRIPT = $(BUILD_DIR)/Main.scpt
COMPILED_MODULES_DIR = $(BUILD_DIR)/Modules

# Source files
MAIN_SOURCE    = $(SOURCES_DIR)/Main.applescript
MODULE_SOURCES = $(wildcard $(MODULES_DIR)/*.applescript)
MODULE_NAMES   := $(basename $(notdir $(MODULE_SOURCES)))

# Paths for compiled modules
COMPILED_MODULES = $(patsubst %,$(COMPILED_MODULES_DIR)/%.scpt,$(MODULE_NAMES))

# Default target
all: build

# Main build target
build: clean $(COMPILED_MODULES) $(COMPILED_MAIN_SCRIPT)

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

# Run all tests
test: build
	@if [ -z "$(TEST_FILES)" ]; then \
		echo "No test files found in $(TESTS_DIR)/. Skipping tests."; \
	else \
		set -euo pipefail; \
		for test_file in $(TEST_FILES); do \
			printf '\n----- Running %s -----\n' "$$test_file"; \
			if ! osascript "$$test_file" 2>&1; then \
				echo "Test $$test_file failed with error"; \
				exit 1; \
			fi; \
			echo "---------------------------------"; \
		done; \
	fi

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
	@echo "  all     Builds all modules (default)"
	@echo "  build   Builds all modules"
	@echo "  test    Runs all tests"
	@echo "  clean   Removes all build artifacts"
	@echo "  help    Shows this help message"

.PHONY: all build test clean help
