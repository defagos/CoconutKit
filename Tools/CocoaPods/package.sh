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
GLOBAL_HEADER_FILE="$PUBLIC_HEADERS_OUTPUT_DIR/CoconutKit.h"
PRECOMPILED_HEADER_FILE="$COCONUT_KIT_DIR/CoconutKit-Prefix.pch"
LICENSE_FILE="$MAIN_DIR/LICENSE"

# Cleanup any existing package, and create a package directory
if [ -d "$OUTPUT_DIR" ]; then
    echo "Files already exist. Cleaning up first..."
    rm -r "$OUTPUT_DIR"
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

# Create a folder for public headers
mkdir -p "$OUTPUT_DIR/PublicHeaders"

# Create a global header file, starting with the .pch imports (common to all files)
echo "Generating global header file..."
cat "$PRECOMPILED_HEADER_FILE" | grep "#import" >> "$GLOBAL_HEADER_FILE"
public_headers_arr=(`cat "$PUBLIC_HEADER_FILE" | grep -v '^$'`)
for public_header_file_name in ${public_headers_arr[@]}
do
    echo "#import \"$public_header_file_name\"" >> "$GLOBAL_HEADER_FILE"
done

# Extract public header files
echo "Extracting public headers..."
header_files=(`find $OUTPUT_DIR/Sources -name "*.h"`)
for header_file in ${header_files[@]}
do
    
    header_file_name=`basename $header_file`
    grep "$header_file_name" "$PUBLIC_HEADER_FILE" > /dev/null
    if [ "$?" -eq "0" ]; then
        mv "$header_file" "$PUBLIC_HEADERS_OUTPUT_DIR"
    fi
done

# Copy precompiled header
cp "$PRECOMPILED_HEADER_FILE" "$OUTPUT_DIR"

# Copy license file
echo "Copying license file..."
cp "$LICENSE_FILE" "$OUTPUT_DIR"

echo "Done"
