#!/bin/bash

set -eux

swift build -c release --product TokamakCoreBenchmark
stat -f "TokamakCoreBenchmark: %z bytes" ./.build/release/TokamakCoreBenchmark
./.build/release/TokamakCoreBenchmark
swift build -c release --product TokamakStaticHTMLBenchmark
stat -f "TokamakStaticHTMLBenchmark: %z bytes" ./.build/release/TokamakStaticHTMLBenchmark
./.build/release/TokamakStaticHTMLBenchmark
