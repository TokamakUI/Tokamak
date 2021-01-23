#!/bin/bash

set -eux

swift build -c release --product TokamakCoreBenchmark
./.build/release/TokamakCoreBenchmark
swift build -c release --product TokamakStaticHTMLBenchmark
./.build/release/TokamakStaticHTMLBenchmark
