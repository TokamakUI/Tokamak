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

func withValuePointer<Value, Result>(
  of value: inout Value,
  _ body: (UnsafeMutableRawPointer) -> Result
) -> Result {
  let kind = Kind(type: Value.self)

  switch kind {
  case .struct:
    return withUnsafePointer(to: &value) { body($0.mutable.raw) }
  case .existential:
    return withExistentialValuePointer(of: &value, body)
  default:
    fatalError()
  }
}

func withExistentialValuePointer<Value, Result>(
  of value: inout Value,
  _ body: (UnsafeMutableRawPointer) -> Result
) -> Result {
  withUnsafePointer(to: &value) {
    let container = $0
      .withMemoryRebound(to: ExistentialContainer.self, capacity: 1) { $0.pointee }
    let info = metadata(of: container.type)
    if info.kind == .class || info.size > ExistentialContainerBuffer.size() {
      let base = $0
        .withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) { $0.pointee }
      if info.kind == .struct {
        return body(base.advanced(by: existentialHeaderSize))
      } else {
        return body(base)
      }
    } else {
      return body($0.mutable.raw)
    }
  }
}

var existentialHeaderSize: Int {
  if is64Bit {
    return 16
  } else {
    return 8
  }
}

var is64Bit: Bool {
  MemoryLayout<Int>.size == 8
}
