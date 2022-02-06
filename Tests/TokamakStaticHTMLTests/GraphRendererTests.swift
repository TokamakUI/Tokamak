//
//  File.swift
//
//
//  Created by Carson Katri on 2/6/22.
//

@_spi(TokamakCore) import TokamakCore
@testable import TokamakStaticHTML
import XCTest

struct TestView: View {
  var body: some View {
    Text("Hello, world!")
  }
}

final class GraphRendererTests: XCTestCase {
  func testRenderer() {
    let reconciler = StaticHTMLGraphRenderer().render(TestView())
    print(reconciler.tree)
  }
}
