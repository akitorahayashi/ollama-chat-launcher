# App Details
APP_NAME = Tinyllama.app

# Directories
SOURCES_DIR = Sources
MODULES_DIR = $(SOURCES_DIR)/Modules
BUILD_DIR   = build
APP_PATH    = $(BUILD_DIR)/$(APP_NAME)

# Temp directory for compiled modules
COMPILED_MODULES_DIR = $(BUILD_DIR)/modules

# Source files
MAIN_SOURCE    = $(SOURCES_DIR)/Main.applescript
MODULE_SOURCES = $(wildcard $(MODULES_DIR)/*.applescript)
MODULE_NAMES   := $(basename $(notdir $(MODULE_SOURCES)))

# Paths for compiled modules in the temp directory
COMPILED_MODULES = $(patsubst %,$(COMPILED_MODULES_DIR)/%.scpt,$(MODULE_NAMES))

# Default target
all: build

# Main build target that depends on the final app
build: $(APP_PATH)

# Rule to create the final application
# This depends on the main source and all the compiled modules
$(APP_PATH): $(MAIN_SOURCE) $(COMPILED_MODULES)
	@echo "Creating application bundle..."
	@osacompile -o "$(APP_PATH)" "$(MAIN_SOURCE)"
	@echo "Copying compiled modules to application..."
	@mkdir -p "$(APP_PATH)/Contents/Resources"
	@cp $(COMPILED_MODULES) "$(APP_PATH)/Contents/Resources/"
	@echo "\nBuild complete."
	@echo "Run the application from: $(APP_PATH)"

# Rule to compile a single module into the temp directory
$(COMPILED_MODULES_DIR)/%.scpt: $(MODULES_DIR)/%.applescript
	@mkdir -p $(COMPILED_MODULES_DIR)
	@echo "Compiling module: $<"
	@osacompile -o "$@" "$<"

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
	@echo "  all     Builds the application (default)"
	@echo "  build   Builds the application"
	@echo "  clean   Removes all build artifacts"
	@echo "  help    Shows this help message"

.PHONY: all build clean help
