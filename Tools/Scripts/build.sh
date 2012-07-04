#!/bin/bash

pushd "${PROJECT_DIR}"/../CoconutKit > /dev/null
"${PROJECT_DIR}"/../Submodules/make-fmwk/make-fmwk.sh -o /LeStudioSDK/Binaries/CoconutKit -u trunk Release
"${PROJECT_DIR}"/../Submodules/make-fmwk/make-fmwk.sh -o /LeStudioSDK/Binaries/CoconutKit -u trunk Debug
popd > /dev/null