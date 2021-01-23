import Benchmark
import Runtime
import TokamakCore

private let bigType = NavigationView<HStack<VStack<Button<Text>>>>.self

benchmark("mangledName Runtime") {
  // swiftlint:disable:next force_try
  _ = try! typeInfo(of: bigType).mangledName
}

benchmark("typeConstructorName TokamakCore") {
  _ = typeConstructorName(bigType)
}

Benchmark.main()
