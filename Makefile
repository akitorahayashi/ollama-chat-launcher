MODULES_DIR = Modules
BUILD_DIR = build/modules
TESTS_DIR = Tests

MODULE_NAMES = Network ServerManager WindowManager
MODULE_FILES = $(patsubst %,$(MODULES_DIR)/%.applescript,$(MODULE_NAMES))
COMPILED_FILES = $(patsubst %,$(BUILD_DIR)/%.scpt,$(MODULE_NAMES))
TEST_FILES = $(patsubst %,$(TESTS_DIR)/%.applescript,$(MODULE_NAMES))

# Default target
all: build

# Build all modules
build: $(COMPILED_FILES)

# Run all tests
test: build
	@for test_file in $(TEST_FILES); do \
		echo "\n----- Running $$test_file -----"; \
		osascript "$$test_file"; \
		echo "---------------------------------"; \
	done

# Rule to compile a single module
$(BUILD_DIR)/%.scpt: $(MODULES_DIR)/%.applescript
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling $< -> $@"
	@osacompile -o $@ $<

# CI-specific targets
test-net:
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling and testing Network module..."
	@osacompile -o $(BUILD_DIR)/Network.scpt $(MODULES_DIR)/Network.applescript
	@osascript $(TESTS_DIR)/Network.applescript

test-server:
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling and testing ServerManager module..."
	@osacompile -o $(BUILD_DIR)/ServerManager.scpt $(MODULES_DIR)/ServerManager.applescript
	@osascript $(TESTS_DIR)/ServerManager.applescript

test-window:
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling and testing WindowManager module..."
	@osacompile -o $(BUILD_DIR)/WindowManager.scpt $(MODULES_DIR)/WindowManager.applescript
	@osascript $(TESTS_DIR)/WindowManager.applescript

run: build
	@echo "Running main script..."
	@osascript main.applescript

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all                  Build all modules (default)"
	@echo "  build                Build all modules"
	@echo "  run                  Run the main application"
	@echo "  test                 Run all unit tests"
	@echo "  clean                Remove build artifacts"
	@echo "  test-net             Compile and test the Network module"
	@echo "  test-server          Compile and test the ServerManager module"
	@echo "  test-window          Compile and test the WindowManager module"

clean:
	rm -rf build

.PHONY: all build test clean run help test-net test-server test-window
