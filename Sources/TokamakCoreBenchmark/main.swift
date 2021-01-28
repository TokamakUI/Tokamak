import Benchmark
import TokamakCore

private let bigType = NavigationView<HStack<VStack<Button<Text>>>>.self

benchmark("mangledName Runtime") {
  _ = typeInfo(of: bigType)!.mangledName
}

benchmark("typeConstructorName TokamakCore") {
  _ = typeConstructorName(bigType)
}

Benchmark.main()
