#!/bin/bash

set -eux

swift build -c release --product TokamakCoreBenchmark
ls -lh ./.build/release/TokamakCoreBenchmark | awk '{printf  "::warning file=Sources/TokamakCoreBenchmark/main.swift,line=1,col=1::TokamakCoreBenchmark is %s.",$5}'
./.build/release/TokamakCoreBenchmark
swift build -c release --product TokamakStaticHTMLBenchmark
ls -lh ./.build/release/TokamakStaticHTMLBenchmark | awk '{printf  "::warning file=Sources/TokamakStaticHTMLBenchmark/main.swift,line=1,col=1::TokamakStaticHTMLBenchmark is %s.",$5}'
./.build/release/TokamakStaticHTMLBenchmark
