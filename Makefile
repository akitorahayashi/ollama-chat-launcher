# Directories
SOURCES_DIR = Sources
MODULES_DIR = $(SOURCES_DIR)/Modules
TESTS_DIR   = Tests
BUILD_DIR   = build

# Main script
MAIN_SOURCE = $(SOURCES_DIR)/Main.applescript
MAIN_COMPILED = $(BUILD_DIR)/Main.scpt

# Dynamically get module names from the filesystem
MODULE_SOURCES := $(wildcard $(MODULES_DIR)/*.applescript)
MODULE_NAMES   := $(basename $(notdir $(MODULE_SOURCES)))

# Compiled module files
COMPILED_MODULES = $(patsubst %,$(BUILD_DIR)/modules/%.scpt,$(MODULE_NAMES))

# Test files
TEST_FILES     = $(wildcard $(TESTS_DIR)/*Tests.applescript)

# Default target
all: build

# Build all modules and the main script
build: $(MAIN_COMPILED)

# Rule to compile the main script, depends on modules being compiled
$(MAIN_COMPILED): $(MAIN_SOURCE) $(COMPILED_MODULES)
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling main script '$<' -> '$@'"
	@osacompile -o "$@" "$<"

# Rule to compile a single module
$(BUILD_DIR)/modules/%.scpt: $(MODULES_DIR)/%.applescript
	@mkdir -p $(BUILD_DIR)/modules
	@echo "Compiling module '$<' -> '$@'"
	@osacompile -o "$@" "$<"

# Run all tests
test: build
	@set -e; \
	for test_file in $(TEST_FILES); do \
		printf '\n----- Running %s -----\n' "$$test_file"; \
		osascript "$$test_file"; \
		printf '---------------------------------\n'; \
	done

# CI-specific target generator
define TEST_TEMPLATE
test-$(1): build
	@set -e; \
	printf '\n--- Running test for $(1) module... ---\n'; \
	osascript "$(TESTS_DIR)/$(1)Tests.applescript"
endef

$(foreach m,$(MODULE_NAMES),$(eval $(call TEST_TEMPLATE,$(m))))

run: build
	@echo "Running main script..."
	@osascript Tinyllama.applescript

help:
	@printf "Usage: make [target]\n\n"
	@printf "Main Targets:\n"
	@printf "  all\t\tBuild all modules and main script (default)\n"
	@printf "  build\t\tBuild all modules and main script\n"
	@printf "  run\t\tRun the main application\n"
	@printf "  test\t\tRun all unit tests\n"
	@printf "  clean\t\tRemove build artifacts\n"
	@printf "\nCI Targets (Dynamically Generated):\n"
	@printf "  test-%%  (e.g., test-Network)\tCompile and test a specific module\n"

clean:
	-@rm -rf $(BUILD_DIR)

.PHONY: all build test clean run help
# Add dynamic test targets to .PHONY
.PHONY: $(patsubst %,test-%,$(MODULE_NAMES))
