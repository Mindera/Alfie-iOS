#!/bin/bash

set -ex

BINARY_DESTINATION_PATH="../AlfieKit"

cd "${BINARY_DESTINATION_PATH}"
swift package --allow-writing-to-package-directory apollo-cli-install
./apollo-ios-cli generate
