#!/bin/bash

SCRIPT_FILE_DIR=`dirname $0`
SCRIPT_FILE_DIR=`cd $SCRIPT_FILE_DIR; pwd`

HOOKS_GIT_DIR="$SCRIPT_FILE_DIR/.git/hooks"

if [ ! -d "$HOOKS_GIT_DIR" ]; then
    mkdir -p "$HOOKS_GIT_DIR"
fi

for file in "$SCRIPT_FILE_DIR"/git_hooks/*; do
    file_name=`basename $file`
    destination_file="$HOOKS_GIT_DIR/$file_name"

    if [ -L "$destination_file" ]; then
        rm -f "$destination_file"
    fi
    ln -s "$file" "$destination_file"
done
