#!/bin/bash

swift package generate-xcodeproj --xcconfig-overrides Package.xcconfig
git checkout HEAD Tokamak.xcodeproj/xcshareddata/xcschemes/TokamakCLI.xcscheme
set -o pipefail && xcodebuild -scheme TokamakUIKit -sdk iphonesimulator | xcpretty
set -o pipefail && xcodebuild -scheme TokamakAppKit -sdk macosx | xcpretty
# this runs the build the second time, but it's the only way to make sure
# that `Package.swift` is in a good state
swift build --target Tokamak
set -o pipefail && xcodebuild test -enableCodeCoverage YES -scheme Tokamak | xcpretty