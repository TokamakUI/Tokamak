// MIT License
//
// Copyright (c) 2017 Wesley Wickwire
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
  func testClass() {
    var md = ClassMetadata(type: MyClass<Int>.self)
    let info = md.toTypeInfo()
    #if os(WASI)
    XCTAssert(md.genericArgumentOffset == 18)
    #else
    XCTAssert(md.genericArgumentOffset == 15)
    #endif
    XCTAssert(info.properties.first { $0.name == "baseProperty" } != nil)
    XCTAssert(info.inheritance[0] == BaseClass.self)
    XCTAssert(info.superClass == BaseClass.self)
    XCTAssert(info.mangledName != "")
    XCTAssert(info.kind == .class)
    XCTAssert(info.type == MyClass<Int>.self)
    XCTAssert(info.properties.count == 3)
    XCTAssert(info.size == MemoryLayout<MyClass<Int>>.size)
    XCTAssert(info.alignment == MemoryLayout<MyClass<Int>>.alignment)
    XCTAssert(info.stride == MemoryLayout<MyClass<Int>>.stride)
    XCTAssert(info.genericTypes.count == 1)
    XCTAssert(info.genericTypes[0] == Int.self)
  }

  func testResilientClass() {
    #if canImport(Darwin)
    class DerivedResilient: JSONEncoder {}
    let md1 = ClassMetadata(type: BaseClass.self)
    let md2 = ClassMetadata(type: JSONDecoder.self)
    let md3 = ClassMetadata(type: DerivedResilient.self)
    XCTAssertFalse(md1.hasResilientSuperclass)
    XCTAssertFalse(md2.hasResilientSuperclass)
    XCTAssertTrue(md3.hasResilientSuperclass)
    #endif
  }

  func testGenericStruct() {
    struct A<B, C, D, E, F, G, H> { let b: B }
    var md = StructMetadata(type: A<Int, String, Bool, Int, Int, Int, Int>.self)
    let args = md.genericArguments()
    let props = md.properties()
    XCTAssert(args.count == 7)
    XCTAssert(args[0] == Int.self)
    XCTAssert(args[1] == String.self)
    XCTAssert(args[2] == Bool.self)
    XCTAssert(args[3] == Int.self)
    XCTAssert(props.count == 1)
    XCTAssert(props[0].type == Int.self)
  }

  func testStruct() {
    struct A {
      let a, b, c, d: Int
      var e: Int
    }

    var md = StructMetadata(type: A.self)
    let info = md.toTypeInfo()
    XCTAssert(info.genericTypes.count == 0)
    XCTAssert(info.kind == .struct)
    XCTAssert(info.type == A.self)
    XCTAssert(info.properties.count == 5)
    XCTAssert(info.size == MemoryLayout<A>.size)
    XCTAssert(info.alignment == MemoryLayout<A>.alignment)
    XCTAssert(info.stride == MemoryLayout<A>.stride)
    XCTAssert(!info.properties[0].isVar)
    XCTAssert(info.properties[4].isVar)
  }

  // https://github.com/wickwirew/Runtime/issues/42
  func testNestedStruct() {
    let nest: () -> () = {
      struct NestedA {
        let a, b, c, d: Int
        var e: Int
      }

      var md = StructMetadata(type: NestedA.self)
      let info = md.toTypeInfo()
      XCTAssert(info.genericTypes.count == 0)
      XCTAssert(info.kind == .struct)
      XCTAssert(info.type == NestedA.self)
      XCTAssert(info.properties.count == 5)
      XCTAssert(info.size == MemoryLayout<NestedA>.size)
      XCTAssert(info.alignment == MemoryLayout<NestedA>.alignment)
      XCTAssert(info.stride == MemoryLayout<NestedA>.stride)
      XCTAssert(!info.properties[0].isVar)
      XCTAssert(info.properties[4].isVar)
    }

    nest()
  }

  func testProtocol() {
    var md = ProtocolMetadata(type: MyProtocol.self)
    let info = md.toTypeInfo()
    XCTAssert(info.kind == .existential)
    XCTAssert(info.type == MyProtocol.self)
    XCTAssert(info.size == MemoryLayout<MyProtocol>.size)
    XCTAssert(info.alignment == MemoryLayout<MyProtocol>.alignment)
    XCTAssert(info.stride == MemoryLayout<MyProtocol>.stride)
  }

  func testTuple() {
    let type = (a: Int, b: Bool, c: String).self
    var md = TupleMetadata(type: type)
    let info = md.toTypeInfo()
    XCTAssert(info.kind == .tuple)
    XCTAssert(info.type == (a: Int, b: Bool, c: String).self)
    XCTAssert(info.properties.count == 3)
    XCTAssert(info.size == MemoryLayout<(a: Int, b: Bool, c: String)>.size)
    XCTAssert(info.alignment == MemoryLayout<(a: Int, b: Bool, c: String)>.alignment)
    XCTAssert(info.stride == MemoryLayout<(a: Int, b: Bool, c: String)>.stride)
  }

  func testTupleNoLabels() {
    let type = (Int, Bool, String).self
    let md = TupleMetadata(type: type)
    XCTAssert(md.labels() == ["", "", ""])
    XCTAssert(md.numberOfElements() == 3)
  }

  func testFunction() throws {
    let info = try functionInfo(of: myFunc)
    XCTAssert(info.numberOfArguments == 3)
    XCTAssert(info.argumentTypes[0] == Int.self)
    XCTAssert(info.argumentTypes[1] == Bool.self)
    XCTAssert(info.argumentTypes[2] == String.self)
    XCTAssert(info.returnType == String.self)
    XCTAssert(!info.throws)
  }

  func testFunctionThrows() {
    let t = ((Int) throws -> String).self
    let md = FunctionMetadata(type: t)
    let info = md.info()
    XCTAssert(info.numberOfArguments == 1)
    XCTAssert(info.argumentTypes[0] == Int.self)
    XCTAssert(info.returnType == String.self)
    XCTAssert(info.throws)
  }

  func testVoidFunction() {
    let t = type(of: voidFunction)
    let md = FunctionMetadata(type: t)
    let info = md.info()
    XCTAssert(info.numberOfArguments == 0)
  }

  func testEnum() {
    var md = EnumMetadata(type: MyEnum<String>.self)
    let info = md.toTypeInfo()
    XCTAssert(info.cases[0].name == "a")
    XCTAssert(info.cases[1].name == "b")
    XCTAssert(info.cases[2].name == "c")
    XCTAssert(info.cases[3].name == "d")
  }

  func testEnumTestEnumWithPayload() {
    enum Foo {
      case a, b, c
      case hasPayload(Int)
      case hasTuplePayload(Bool, Int)
    }

    var md = EnumMetadata(type: Foo.self)
    let info = md.toTypeInfo()

    guard let hasPayload = info.cases.first(where: { $0.name == "hasPayload" }),
          let hasTuplePayload = info.cases.first(where: { $0.name == "hasTuplePayload" })
    else {
      return XCTFail("Missing payload cases")
    }

    XCTAssertEqual(md.numberOfCases, 5)
    XCTAssertEqual(md.numberOfPayloadCases, 2)
    XCTAssert(hasPayload.payloadType == Int.self)
    XCTAssert(hasTuplePayload.payloadType == (Bool, Int).self)
  }

  #if canImport(Foundation)
  func testObjcEnum() {
    var md = EnumMetadata(type: ComparisonResult.self)
    let info = md.toTypeInfo()
    XCTAssertEqual(info.numberOfEnumCases, 3)
    XCTAssertEqual(info.numberOfPayloadEnumCases, 0)
  }
  #endif

  func testOptional() throws {
    let info = try XCTUnwrap(typeInfo(of: Double?.self))
    XCTAssert(info.cases[0].name == "some")
    XCTAssert(info.cases[1].name == "none")
  }
}

private enum MyEnum<T>: Int {
  case a, b, c, d
}

func voidFunction() {}

func myFunc(a: Int, b: Bool, c: String) -> String {
  ""
}

private protocol MyProtocol {
  var a: Int { get set }
  func doSomething(value: Int) -> Bool
}

private class BaseClass {
  var baseProperty: Int = 0
}

private class MyClass<T>: BaseClass {
  var property: String = ""
  var gen: T
  init(g: T) {
    gen = g
  }
}

private struct MyStruct<T> {
  var a, b: Int
  var c: String
  var d: T
}
