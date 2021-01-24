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

struct ClassTypeDescriptor: TypeDescriptor {
  var flags: ContextDescriptorFlags
  var parent: Int32
  var mangledName: RelativePointer<Int32, CChar>
  var fieldTypesAccessor: RelativePointer<Int32, Int>
  var fieldDescriptor: RelativePointer<Int32, FieldDescriptor>
  var superClass: RelativePointer<Int32, Any.Type>
  var negativeSizeAndBoundsUnion: NegativeSizeAndBoundsUnion
  var metadataPositiveSizeInWords: Int32
  var numImmediateMembers: Int32
  var numberOfFields: Int32
  var offsetToTheFieldOffsetVector: RelativeVectorPointer<Int32, Int>
  var genericContextHeader: TargetTypeGenericContextDescriptorHeader

  struct NegativeSizeAndBoundsUnion: Union {
    var raw: Int32

    var metadataNegativeSizeInWords: Int32 {
      raw
    }

    mutating func resilientMetadataBounds()
      -> UnsafeMutablePointer<RelativePointer<Int32, TargetStoredClassMetadataBounds>>
    {
      bind()
    }
  }
}

struct TargetStoredClassMetadataBounds {
  var immediateMembersOffset: Int
  var bounds: TargetMetadataBounds
}

struct TargetMetadataBounds {
  var negativeSizeWords: UInt32
  var positiveSizeWords: UInt32
}
