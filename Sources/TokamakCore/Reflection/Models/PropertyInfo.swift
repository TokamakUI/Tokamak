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

public struct PropertyInfo {
  public let name: String
  public let type: Any.Type
  public let isVar: Bool
  public let offset: Int
  public let ownerType: Any.Type

  public func set<TObject>(value: Any, on object: inout TObject) {
    withValuePointer(of: &object) { pointer in
      set(value: value, pointer: pointer)
    }
  }

  public func set(value: Any, on object: inout Any) {
    withValuePointer(of: &object) { pointer in
      set(value: value, pointer: pointer)
    }
  }

  private func set(value: Any, pointer: UnsafeMutableRawPointer) {
    let valuePointer = pointer.advanced(by: offset)
    let sets = setters(type: type)
    sets.set(value: value, pointer: valuePointer)
  }

  public func get(from object: Any) -> Any {
    var object = object
    return withValuePointer(of: &object) { pointer in
      let valuePointer = pointer.advanced(by: offset)
      let gets = getters(type: type)
      return gets.get(from: valuePointer)
    }
  }
}
