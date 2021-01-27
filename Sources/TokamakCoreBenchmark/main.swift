import Benchmark
import TokamakCore

private let bigType = NavigationView<HStack<VStack<Button<Text>>>>.self

benchmark("typeConstructorName TokamakCore") {
  _ = typeConstructorName(bigType)
}

Benchmark.main()
