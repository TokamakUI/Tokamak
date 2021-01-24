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

struct TupleMetadata: MetadataType, TypeInfoConvertible {
  var pointer: UnsafeMutablePointer<TupleMetadataLayout>

  func numberOfElements() -> Int {
    pointer.pointee.numberOfElements
  }

  func labels() -> [String] {
    guard Int(bitPattern: pointer.pointee.labelsString) != 0
    else { return (0..<numberOfElements()).map { _ in "" } }
    return String(cString: pointer.pointee.labelsString).split(separator: " ").map(String.init)
  }

  func elements() -> UnsafeBufferPointer<TupleElementLayout> {
    pointer.pointee.elementVector.vector(n: numberOfElements())
  }

  func properies() -> [PropertyInfo] {
    let names = labels()
    let el = elements()
    let num = numberOfElements()
    var properties = [PropertyInfo]()
    for i in 0..<num {
      properties
        .append(PropertyInfo(
          name: names[i],
          type: el[i].type,
          isVar: true,
          offset: el[i].offset,
          ownerType: type
        ))
    }
    return properties
  }

  mutating func toTypeInfo() -> TypeInfo {
    var info = TypeInfo(metadata: self)
    info.properties = properies()
    return info
  }
}
