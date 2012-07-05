#!/bin/bash

env -i bash --noprofile

# Directory containing this file (absolute)
SCRIPT_FILE_DIR=`dirname $0`
SCRIPT_FILE_DIR=`cd $SCRIPT_FILE_DIR; pwd`

coconutkit_dir="$SCRIPT_FILE_DIR/../../CoconutKit"
make_fmwk_dir="$SCRIPT_FILE_DIR/../../Submodules/make-fmwk"

pushd "$coconutkit_dir" > /dev/null
"$make_fmwk_dir"/make-fmwk.sh -o /LeStudioSDK/Binaries/CoconutKit -u trunk Release
"$make_fmwk_dir"/make-fmwk.sh -o /LeStudioSDK/Binaries/CoconutKit -u trunk Debug
popd > /dev/null