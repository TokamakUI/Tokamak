#!/bin/bash

set -e 
set -o pipefail

brew update
brew install swiftformat swiftlint

swiftformat --lint --verbose .
swiftlint