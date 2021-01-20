#!/bin/bash

set -eux

swift build -c release --product TokamakStaticHTMLBenchmark
./.build/release/TokamakStaticHTMLBenchmark
