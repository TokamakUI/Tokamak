import Benchmark
import TokamakStaticHTML

benchmark("render Text") {
  _ = StaticHTMLRenderer(Text("text"))
}

benchmark("render List") {
  _ = StaticHTMLRenderer(List(1..<100) { Text("\($0)") })
}

Benchmark.main()
