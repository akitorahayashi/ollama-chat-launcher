#!/bin/zsh
# Compile all AppleScript modules in Modules/ and output to build/modules/

MODULES_DIR="$(cd "$(dirname "$0")" && pwd)/Modules"
BUILD_DIR="$(cd "$(dirname "$0")" && pwd)/build/modules"

for module in "$MODULES_DIR"/*.applescript; do
    base=$(basename "$module" .applescript)
    osacompile -o "$BUILD_DIR/$base.scpt" "$module"
done
