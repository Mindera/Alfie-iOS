#!/bin/bash

set -ex

BINARY_DESTINATION_PATH="../AlfieKit"

cd "${BINARY_DESTINATION_PATH}"
# --allow-network-connections all: pre-grants the apollo-cli-install plugin's network
# access (it downloads the apollo-ios-cli binary from GitHub Releases over HTTPS), so
# the run is non-interactive — no SwiftPM permission prompt to answer.
swift package --allow-writing-to-package-directory --allow-network-connections all apollo-cli-install
./apollo-ios-cli generate

rm -f ./apollo-ios-cli
