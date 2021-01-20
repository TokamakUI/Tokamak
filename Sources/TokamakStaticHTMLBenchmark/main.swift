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

benchmark("render App") {
  _ = StaticHTMLRenderer(BenchmarkApp())
}

benchmark("render List") {
  _ = StaticHTMLRenderer(List(1..<100) { Text("\($0)") })
}

Benchmark.main()
