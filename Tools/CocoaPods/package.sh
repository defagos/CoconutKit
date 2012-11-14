#!/bin/bash

# Directory containing this file (absolute)
SCRIPT_FILE_DIR=`dirname $0`
SCRIPT_FILE_DIR=`cd $SCRIPT_FILE_DIR; pwd`

# Paths
MAIN_DIR="$SCRIPT_FILE_DIR/../.."
COCONUT_KIT_DIR="$MAIN_DIR/CoconutKit"
SOURCES_DIR="$COCONUT_KIT_DIR/Sources"
RESOURCE_BUNDLE_DIR="$COCONUT_KIT_DIR/CoconutKit-resources.bundle"
PUBLIC_HEADER_FILE="$COCONUT_KIT_DIR/publicHeaders.txt"
OUTPUT_DIR="$SCRIPT_FILE_DIR/Files"
PUBLIC_HEADERS_OUTPUT_DIR="$OUTPUT_DIR/PublicHeaders"

# Cleanup any existing package, and create a package directory
if [ -d "$OUTPUT_DIR" ]; then
    echo "Files already exist. Cleaning up first..."
    rm -rf "$OUTPUT_DIR"
fi
echo "Creating package..."
mkdir -p "$OUTPUT_DIR"

# Build the resource bundle
echo "Building resource bundle..."
pushd "$MAIN_DIR/CoconutKit-resources" > /dev/null
xcodebuild > /dev/null
if [ "$?" -ne "0" ]; then
    echo "[Error] Could not create resource bundle"
    exit 1
fi
popd > /dev/null

# Copy files
echo "Copying files..."
cp -R "$RESOURCE_BUNDLE_DIR" "$OUTPUT_DIR"
cp -R "$SOURCES_DIR" "$OUTPUT_DIR"

# Extract public headers by comparison with publicHeaders.txt
echo "Extracting public headers..."
mkdir -p "$OUTPUT_DIR/PublicHeaders"

header_files=(`find $OUTPUT_DIR/Sources -name "*.h"`)
for header_file in ${header_files[@]}
do
    header_file_name=`basename $header_file`
    grep "$header_file_name" "$PUBLIC_HEADER_FILE" > /dev/null
    if [ "$?" -eq "0" ]; then
        mv "$header_file" "$PUBLIC_HEADERS_OUTPUT_DIR"
    fi
done

echo "Done"
