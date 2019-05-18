#!/bin/bash

brew update
brew install swiftformat swiftlint

swiftformat --lint --verbose .
swiftlint