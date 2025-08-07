MODULES_DIR = Modules
BUILD_DIR = build/modules
TESTS_DIR = Tests

# Dynamically get module names from the filesystem
MODULE_SOURCES := $(wildcard $(MODULES_DIR)/*.applescript)
MODULE_NAMES   := $(basename $(notdir $(MODULE_SOURCES)))

COMPILED_FILES = $(patsubst %,$(BUILD_DIR)/%.scpt,$(MODULE_NAMES))
TEST_FILES     = $(patsubst %,$(TESTS_DIR)/%.applescript,$(MODULE_NAMES))

# Default target
all: build

# Build all modules
build: $(COMPILED_FILES)

# Run all tests
test: build
	@set -e; \
	for test_file in $(TEST_FILES); do \
		printf '\n----- Running %s -----\n' "$$test_file"; \
		osascript "$$test_file"; \
		printf '---------------------------------\n'; \
	done

# Rule to compile a single module
$(BUILD_DIR)/%.scpt: $(MODULES_DIR)/%.applescript
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling $< -> $@"
	@osacompile -o $@ $<

# CI-specific target generator
define TEST_TEMPLATE
test-$(1): build
	@printf "\n--- Running test for $(1) module... ---\n"
	@osascript $(TESTS_DIR)/$(1).applescript
endef

$(foreach m,$(MODULE_NAMES),$(eval $(call TEST_TEMPLATE,$(m))))

run: build
	@echo "Running main script..."
	@osascript main.applescript

help:
	@printf "Usage: make [target]\n\n"
	@printf "Main Targets:\n"
	@printf "  all\t\tBuild all modules (default)\n"
	@printf "  build\t\tBuild all modules\n"
	@printf "  run\t\tRun the main application\n"
	@printf "  test\t\tRun all unit tests\n"
	@printf "  clean\t\tRemove build artifacts\n"
	@printf "\nCI Targets (Dynamically Generated):\n"
	@printf "  test-%%  (e.g., test-Network)\tCompile and test a specific module\n"

clean:
	-@rm -rf $(dir $(BUILD_DIR))

.PHONY: all build test clean run help
# Add dynamic test targets to .PHONY
.PHONY: $(patsubst %,test-%,$(MODULE_NAMES))
