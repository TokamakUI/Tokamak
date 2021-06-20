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

extension UnsafePointer {
  var raw: UnsafeRawPointer {
    UnsafeRawPointer(self)
  }

  var mutable: UnsafeMutablePointer<Pointee> {
    UnsafeMutablePointer<Pointee>(mutating: self)
  }

  func buffer(n: Int) -> UnsafeBufferPointer<Pointee> {
    UnsafeBufferPointer(start: self, count: n)
  }

  func vector<T>(at keyPath: KeyPath<Pointee, T>) -> UnsafePointer<T> {
    let offset = MemoryLayout<Pointee>.offset(of: keyPath)!
    return raw.advanced(by: offset).assumingMemoryBound(to: T.self)
  }

  func advance<T>(offset keyPath: KeyPath<Pointee, MetadataOffset<T>>) -> UnsafePointer<T> {
    let offset = MemoryLayout<Pointee>.offset(of: keyPath)!
    return pointee[keyPath: keyPath].apply(to: raw.advanced(by: offset))
  }
}

extension UnsafePointer where Pointee: Equatable {
  func advance(to value: Pointee) -> UnsafePointer<Pointee> {
    var pointer = self
    while pointer.pointee != value {
      pointer = pointer.advanced(by: 1)
    }
    return pointer
  }
}

extension UnsafeMutablePointer {
  var raw: UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(self)
  }
}
