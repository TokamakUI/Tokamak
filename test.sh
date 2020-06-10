#!/bin/bash

set -ex

swift test --enable-code-coverage
xcrun llvm-cov show \
  .build/debug/TokamakPackageTests.xctest/Contents/MacOS/TokamakPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata > coverage.txt
