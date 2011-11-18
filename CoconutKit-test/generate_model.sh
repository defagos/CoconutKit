#!/bin/bash

# Check whether mogenerator is available
which mogenerator > /dev/null
if [ "$?" -eq "0" ]; then
    echo "mogenerator found. Generating model files..."
else
    echo "mogenerator is not available. Cannot generate model files, using available ones if any"
    exit 0
fi

# Directory containing this file (absolute)
SCRIPT_FILE_DIR=`dirname $0`
SCRIPT_FILE_DIR=`cd $SCRIPT_FILE_DIR; pwd`

MODEL_DIR="$SCRIPT_FILE_DIR/Resources/Data/CoconutKitTestData.xcdatamodeld/CoconutKitTestData.xcdatamodel/"
HUMAN_DIR="$SCRIPT_FILE_DIR/Sources/Models/"
MACHINE_DIR="$SCRIPT_FILE_DIR/Sources/Models/Generated/"

if [ ! -d "$HUMAN_DIR" ]; then
    mkdir -p "$HUMAN_DIR"
fi
if [ -d "$MACHINE_DIR" ]; then
    rm -rf "$MACHINE_DIR"
fi
mkdir -p "$MACHINE_DIR"

mogenerator --model "$MODEL_DIR" --machine-dir "$MACHINE_DIR" --human-dir "$HUMAN_DIR"

echo "Done."