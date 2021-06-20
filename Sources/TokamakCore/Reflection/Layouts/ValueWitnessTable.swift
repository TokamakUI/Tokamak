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

struct ValueWitnessTable {
  let initializeBufferWithCopyOfBuffer: UnsafeRawPointer
  let destroy: UnsafeRawPointer
  let initializeWithCopy: UnsafeRawPointer
  let assignWithCopy: UnsafeRawPointer
  let initializeWithTake: UnsafeRawPointer
  let assignWithTake: UnsafeRawPointer
  let getEnumTagSinglePayload: UnsafeRawPointer
  let storeEnumTagSinglePayload: UnsafeRawPointer
  let size: Int
  let stride: Int
  let flags: Int
}

enum ValueWitnessFlags {
  static let alignmentMask = 0x0000_FFFF
  static let isNonPOD = 0x0001_0000
  static let isNonInline = 0x0002_0000
  static let hasExtraInhabitants = 0x0004_0000
  static let hasSpareBits = 0x0008_0000
  static let isNonBitwiseTakable = 0x0010_0000
  static let hasEnumWitnesses = 0x0020_0000
}
