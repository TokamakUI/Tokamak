//
//  EnumTypeDescriptor.swift
//  Runtime
//
//  Created by Wes Wickwire on 4/6/19.
//

struct EnumTypeDescriptor: TypeDescriptor {
  var flags: ContextDescriptorFlags
  var parent: RelativePointer<Int32, UnsafeRawPointer>
  var mangledName: RelativePointer<Int32, CChar>
  var accessFunctionPointer: RelativePointer<Int32, UnsafeRawPointer>
  var fieldDescriptor: RelativePointer<Int32, FieldDescriptor>
  var numPayloadCasesAndPayloadSizeOffset: UInt32
  var numEmptyCases: UInt32
  var offsetToTheFieldOffsetVector: RelativeVectorPointer<Int32, Int32>
  var genericContextHeader: TargetTypeGenericContextDescriptorHeader

  var numberOfFields: Int32 {
    get { 0 }
    set {}
  }
}
