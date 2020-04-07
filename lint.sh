#!/bin/bash

set -ex

brew update
brew install swiftformat swiftlint

swiftformat --lint --verbose .
swiftlint
