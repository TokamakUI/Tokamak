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

protocol TypeDescriptor {
  /// The offset type can differ between TypeDescriptors
  /// e.g. Struct are an Int32 and classes are an Int
  associatedtype FieldOffsetVectorOffsetType: FixedWidthInteger

  var flags: ContextDescriptorFlags { get set }
  var mangledName: RelativePointer<Int32, CChar> { get set }
  var fieldDescriptor: RelativePointer<Int32, FieldDescriptor> { get set }
  var numberOfFields: Int32 { get set }
  var offsetToTheFieldOffsetVector: RelativeVectorPointer<Int32, FieldOffsetVectorOffsetType> {
    get set
  }
  var genericContextHeader: TargetTypeGenericContextDescriptorHeader { get set }
}

typealias ContextDescriptorFlags = Int32
