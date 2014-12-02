#!/bin/bash

SCRIPT_FILE_DIR=`dirname $0`
SCRIPT_FILE_DIR=`cd $SCRIPT_FILE_DIR; pwd`

for file in "$SCRIPT_FILE_DIR"/git_hooks/*; do
    file_name=`basename $file`
    destination_file="$SCRIPT_FILE_DIR/.git/hooks/$file_name"

    if [ -f "$destination_file" ]; then
        rm -f "$destination_file"
    fi
    ln -s "$file" "$destination_file"
done
