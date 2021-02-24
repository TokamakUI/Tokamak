// MIT License
//
// Copyright (c) 2017-2021 Wesley Wickwire and Tokamak contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@testable import TokamakCore
import XCTest

final class MetadataTests: XCTestCase {
  func testGenericStruct() {
    struct A<B, C, D, E, F, G, H> { let b: B }
    let md = StructMetadata(type: A<Int, String, Bool, Int, Int, Int, Int>.self)
    let props = md.properties()
    XCTAssert(props.count == 1)
    XCTAssert(props[0].type == Int.self)
  }

  func testStruct() {
    struct A {
      let a, b, c, d: Int
      var e: Int
    }

    let md = StructMetadata(type: A.self)
    let info = md.toTypeInfo()
    XCTAssert(info.kind == .struct)
    XCTAssert(info.type == A.self)
    XCTAssert(info.properties.count == 5)
    XCTAssert(info.size == MemoryLayout<A>.size)
  }

  // https://github.com/wickwirew/Runtime/issues/42
  func testNestedStruct() {
    let nest: () -> () = {
      struct NestedA {
        let a, b, c, d: Int
        var e: Int
      }

      let md = StructMetadata(type: NestedA.self)
      let info = md.toTypeInfo()
      XCTAssert(info.kind == .struct)
      XCTAssert(info.type == NestedA.self)
      XCTAssert(info.properties.count == 5)
      XCTAssert(info.size == MemoryLayout<NestedA>.size)
    }

    nest()
  }
}

private protocol MyProtocol {
  var a: Int { get set }
  func doSomething(value: Int) -> Bool
}

private struct MyStruct<T> {
  var a, b: Int
  var c: String
  var d: T
}
