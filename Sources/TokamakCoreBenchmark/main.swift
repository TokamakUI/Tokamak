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
@_spi(TokamakCore) import TokamakCore
import TokamakTestRenderer

private let bigType = NavigationView<HStack<VStack<Button<Text>>>>.self

benchmark("mangledName Runtime") {
  _ = typeInfo(of: bigType)!.mangledName
}

benchmark("typeConstructorName TokamakCore") {
  _ = typeConstructorName(bigType)
}

struct UpdateWide: View {
  @State
  var update = -1

  var body: some View {
    VStack {
      ForEach(0..<1000) {
        if update == $0 {
          Text("Updated")
        } else {
          Text("\($0)")
        }
      }
      Button("Update") {
        update = 999
      }
    }
  }
}

benchmark("update wide (StackReconciler)") { state in
  let view = UpdateWide()
  let renderer = TestRenderer(view)
  var button: _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>?
  mapAnyView(
    renderer.rootTarget.subviews[0].subviews[1].subviews[0]
      .view
  ) { (v: _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>) in
    button = v
  }
  try state.measure {
    button?.action()
  }
}

benchmark("update wide (FiberReconciler)") { state in
  let view = UpdateWide()
  let reconciler = TestFiberRenderer(
    .root,
    size: .init(width: 500, height: 500),
    useDynamicLayout: true
  ).render(view)
  guard case let .view(view, _) = reconciler.current // RootView
    .child? // LayoutView
    .child? // ModifiedContent
    .child? // _ViewModifier_Content
    .child? // UpdateLast
    .child? // VStack
    .child? // TupleView
    .child?.sibling? // Button
    .child? // ConditionalContent
    .child? // AnyView
    .child? // _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
    .content,
    let button = view as? _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
  else { return }

  try state.measure {
    button.action()
  }
}

struct UpdateNarrow: View {
  @State
  var update = -1

  var body: some View {
    VStack {
      ForEach(0..<1000) {
        if update == $0 {
          Text("Updated")
        } else {
          Text("\($0)")
        }
      }
      Button("Update") {
        update = 0
      }
    }
  }
}

benchmark("update narrow (StackReconciler)") { state in
  let view = UpdateNarrow()
  let renderer = TestRenderer(view)
  var button: _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>?
  mapAnyView(
    renderer.rootTarget.subviews[0].subviews[1].subviews[0]
      .view
  ) { (v: _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>) in
    button = v
  }
  try state.measure {
    button?.action()
  }
}

benchmark("update narrow (FiberReconciler)") { state in
  let view = UpdateNarrow()
  let reconciler = TestFiberRenderer(
    .root,
    size: .init(width: 500, height: 500),
    useDynamicLayout: true
  ).render(view)
  guard case let .view(view, _) = reconciler.current // RootView
    .child? // LayoutView
    .child? // ModifiedContent
    .child? // _ViewModifier_Content
    .child? // UpdateLast
    .child? // VStack
    .child? // TupleView
    .child?.sibling? // Button
    .child? // ConditionalContent
    .child? // AnyView
    .child? // _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
    .content,
    let button = view as? _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
  else { return }
  try state.measure {
    button.action()
  }
}

struct UpdateDeep: View {
  @State
  var update = "A"

  struct RecursiveView: View {
    let count: Int
    let content: String

    init(_ count: Int, content: String) {
      self.count = count
      self.content = content
    }

    var body: some View {
      if count == 0 {
        Text(content)
      } else {
        RecursiveView(count - 1, content: content)
      }
    }
  }

  var body: some View {
    VStack {
      RecursiveView(1000, content: update)
      Button("Update") {
        update = "B"
      }
    }
  }
}

benchmark("update deep (StackReconciler)") { state in
  let view = UpdateDeep()
  let renderer = TestRenderer(view)
  var button: _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>?
  mapAnyView(
    renderer.rootTarget.subviews[0].subviews[1].subviews[0]
      .view
  ) { (v: _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>) in
    button = v
  }
  try state.measure {
    button?.action()
  }
}

benchmark("update deep (FiberReconciler)") { state in
  let view = UpdateDeep()
  let reconciler = TestFiberRenderer(
    .root,
    size: .init(width: 500, height: 500),
    useDynamicLayout: true
  ).render(view)
  guard case let .view(view, _) = reconciler.current // RootView
    .child? // ModifiedContent
    .child? // _ViewModifier_Content
    .child? // UpdateLast
    .child? // VStack
    .child? // TupleView
    .child?.sibling? // Button
    .child? // ConditionalContent
    .child? // AnyView
    .child? // _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
    .content,
    let button = view as? _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
  else { return }
  try state.measure {
    button.action()
  }
}

struct UpdateShallow: View {
  @State
  var update = "A"

  struct RecursiveView: View {
    let count: Int

    init(_ count: Int) {
      self.count = count
    }

    var body: some View {
      if count == 0 {
        Text("RecursiveView")
      } else {
        RecursiveView(count - 1)
      }
    }
  }

  var body: some View {
    VStack {
      Text(update)
      RecursiveView(1000)
      Button("Update") {
        update = "B"
      }
    }
  }
}

benchmark("update shallow (StackReconciler)") { _ in
  let view = UpdateShallow()
  let renderer = TestRenderer(view)
  var button: _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>?
  mapAnyView(
    renderer.rootTarget.subviews[0].subviews[1].subviews[0]
      .view
  ) { (v: _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>) in
    button = v
  }
  // Using state.measure here hangs the benchmark app?
  button?.action()
}

benchmark("update shallow (FiberReconciler)") { _ in
  let view = UpdateShallow()
  let reconciler = TestFiberRenderer(
    .root,
    size: .init(width: 500, height: 500),
    useDynamicLayout: true
  ).render(view)
  guard case let .view(view, _) = reconciler.current // RootView
    .child? // ModifiedContent
    .child? // _ViewModifier_Content
    .child? // UpdateLast
    .child? // VStack
    .child? // TupleView
    .child?.sibling? // Button
    .child? // ConditionalContent
    .child? // AnyView
    .child? // _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
    .content,
    let button = view as? _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
  else { return }
  // Using state.measure here hangs the benchmark app?g
  button.action()
}

Benchmark.main()
