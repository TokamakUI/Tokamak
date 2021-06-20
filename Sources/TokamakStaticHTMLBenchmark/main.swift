// Copyright 2021 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Benchmark
import TokamakStaticHTML

benchmark("render Text") {
  _ = StaticHTMLRenderer(Text("text"))
}

struct BenchmarkApp: App {
  var body: some Scene {
    WindowGroup("Benchmark") {
      Text("Hello, World!")
    }
  }
}

benchmark("render App unsorted attributes") {
  _ = StaticHTMLRenderer(BenchmarkApp()).render(shouldSortAttributes: false)
}

benchmark("render App sorted attributes") {
  _ = StaticHTMLRenderer(BenchmarkApp()).render(shouldSortAttributes: true)
}

benchmark("render List unsorted attributes") {
  _ = StaticHTMLRenderer(List(1..<100) { Text("\($0)") }).render(shouldSortAttributes: false)
}

benchmark("render List sorted attributes") {
  _ = StaticHTMLRenderer(List(1..<100) { Text("\($0)") }).render(shouldSortAttributes: true)
}

Benchmark.main()
