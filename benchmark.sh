#!/bin/bash

set -eux

swift build -c release --product TokamakCoreBenchmark
stat -f "::warning file=Sources/TokamakCoreBenchmark/main.swift,line=1,col=1::TokamakCoreBenchmark is %z bytes." ./.build/release/TokamakCoreBenchmark
./.build/release/TokamakCoreBenchmark
swift build -c release --product TokamakStaticHTMLBenchmark
stat -f "::warning file=Sources/TokamakStaticHTMLBenchmark/main.swift,line=1,col=1::TokamakStaticHTMLBenchmark is %z bytes." ./.build/release/TokamakStaticHTMLBenchmark
./.build/release/TokamakStaticHTMLBenchmark
