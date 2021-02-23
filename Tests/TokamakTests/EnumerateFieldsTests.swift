// MIT License
//
// Copyright (c) 2019 Sergej Jaskiewicz
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
//
//  Created by Sergej Jaskiewicz on 29.11.2019.
//

import CoreFoundation
import Foundation
import TokamakCore
import XCTest

// This file contains tests for internal OpenCombine APIs.

#if !OPENCOMBINE_COMPATIBILITY_TEST

final class EnumerateFieldsTests: TestCase {
  func testStructLetsAndVars() {
    var fields = [FieldInfo]()
    enumerateFields(
      ofType: CommonValue.self,
      allowResilientSuperclasses: false
    ) { field in
      fields.append(field)
      return true
    }

    #if arch(wasm32)
    XCTAssertEqual(fields, [.init("field1", 0, Int.self),
                            .init("field2", 4, Bool.self),
                            .init("field3", 5, Bool.self),
                            .init("field4", 8, [String].self),
                            .init("field5", 0, Void.self)])
    #else
    XCTAssertEqual(fields, [.init("field1", 0, Int.self),
                            .init("field2", 8, Bool.self),
                            .init("field3", 9, Bool.self),
                            .init("field4", 16, [String].self),
                            .init("field5", 0, Void.self)])
    #endif
    if hasFailed { return }
    let value = CommonValue(
      field1: 42,
      field2: true,
      field3: false,
      field4: ["it", "works"],
      field5: ()
    )
    XCTAssertEqual(loadField(fields[0], from: value, as: Int.self), 42)
    XCTAssertEqual(loadField(fields[1], from: value, as: Bool.self), true)
    XCTAssertEqual(loadField(fields[2], from: value, as: Bool.self), false)
    XCTAssertEqual(
      loadField(fields[3], from: value, as: [String].self),
      ["it", "works"]
    )
    loadField(fields[4], from: value, as: Void.self)
  }

  func testGenericStruct() {
    var fields = [FieldInfo]()
    enumerateFields(
      ofType: GenericValue<Int, String>.self,
      allowResilientSuperclasses: false
    ) { field in
      fields.append(field)
      return true
    }

    #if arch(wasm32)
    XCTAssertEqual(fields, [.init("field1", 0, Int.self),
                            .init("field2", 4, String.self),
                            .init("field3", 16, Bool.self)])
    #else
    XCTAssertEqual(fields, [.init("field1", 0, Int.self),
                            .init("field2", 8, String.self),
                            .init("field3", 24, Bool.self)])
    #endif
    if hasFailed { return }
    let value = GenericValue(field1: 12_345_678, field2: "🦊", field3: true)
    XCTAssertEqual(loadField(fields[0], from: value, as: Int.self), 12_345_678)
    XCTAssertEqual(loadField(fields[1], from: value, as: String.self), "🦊")
    XCTAssertEqual(loadField(fields[2], from: value, as: Bool.self), true)
  }

  func testTuple() {
    enumerateFields(ofType: Void.self, allowResilientSuperclasses: false) { _ in
      XCTFail("should not be called")
      return true
    }

    typealias Tuple =
      (Int, String, label1: Double, Bool, s̈pin̈al_tap̈: IndexPath, label3: Float)
    var fields = [FieldInfo]()
    enumerateFields(
      ofType: Tuple.self,
      allowResilientSuperclasses: true
    ) { field in
      fields.append(field)
      return true
    }
    #if arch(wasm32)
    XCTAssertEqual(fields, [.init("", 0, Int.self),
                            .init("", 4, String.self),
                            .init("label1", 16, Double.self),
                            .init("", 24, Bool.self),
                            .init("s̈pin̈al_tap̈", 28, IndexPath.self),
                            .init("label3", 40, Float.self)])
    #else
    XCTAssertEqual(fields, [.init("", 0, Int.self),
                            .init("", 8, String.self),
                            .init("label1", 24, Double.self),
                            .init("", 32, Bool.self),
                            .init("s̈pin̈al_tap̈", 40, IndexPath.self),
                            .init("label3", 60, Float.self)])
    #endif
    if hasFailed { return }
    let value: Tuple = (1234, "🌚", 59.1, false, [9, 3, 1], 10.1)
    XCTAssertEqual(loadField(fields[0], from: value, as: Int.self), 1234)
    XCTAssertEqual(loadField(fields[1], from: value, as: String.self), "🌚")
    XCTAssertEqual(loadField(fields[2], from: value, as: Double.self), 59.1)
    XCTAssertEqual(loadField(fields[3], from: value, as: Bool.self), false)
    XCTAssertEqual(loadField(fields[4], from: value, as: IndexPath.self), [9, 3, 1])
    XCTAssertEqual(loadField(fields[5], from: value, as: Float.self), 10.1)
  }
}

private func loadField<FieldType>(_ field: FieldInfo,
                                  from instance: AnyObject,
                                  as type: FieldType.Type,
                                  file: StaticString = #file,
                                  line: UInt = #line) -> FieldType?
{
  if field.type != type {
    XCTFail("Type mismatch", file: file, line: line)
    return nil
  }
  return Unmanaged
    .passUnretained(instance)
    .toOpaque()
    .load(fromByteOffset: field.offset, as: type)
}

private func loadField<Value, FieldType>(_ field: FieldInfo,
                                         from value: Value,
                                         as type: FieldType.Type,
                                         file: StaticString = #file,
                                         line: UInt = #line) -> FieldType?
{
  if field.type != type {
    XCTFail("Type mismatch", file: file, line: line)
    return nil
  }
  return withUnsafePointer(to: value) {
    UnsafeRawPointer($0).load(fromByteOffset: field.offset, as: type)
  }
}

private struct CommonValue {
  var field1: Int
  let field2: Bool
  let field3: Bool
  var field4: [String]
  let field5: ()
}

private struct GenericValue<A, B> {
  let field1: A
  let field2: B
  let field3: Bool
}

#endif
