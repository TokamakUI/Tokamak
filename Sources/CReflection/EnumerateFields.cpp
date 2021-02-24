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
//  Created by Sergej Jaskiewicz on 25.10.2019.
//

#include "CReflection.h"
#include "swift/ABI/Metadata.h"
#include "swift/Runtime/Metadata.h"
#include "swift/Reflection/Records.h"
#include "stl_polyfill/string_view.h"

using namespace tokamak;
using namespace swift;
using namespace reflection;

// This function is defined in the Swift runtime.
OPENCOMBINE_SWIFT_CALLING_CONVENTION
extern "C" const Metadata *
swift_getTypeByMangledNameInContext(const char *typeNameStart,
                                    size_t typeNameLength,
                                    const ContextDescriptor *context,
                                    const Metadata *const *genericArgs);

namespace
{
  const Metadata *getTypeMetadata(const FieldRecord &record,
                                  const Metadata *fieldOwner)
  {
    string_view mangledTypeName = record.getMangledTypeName(0);
    return swift_getTypeByMangledNameInContext(mangledTypeName.data(),
                                               mangledTypeName.size(),
                                               fieldOwner->getTypeContextDescriptor(),
                                               fieldOwner->getGenericArgs());
  }

  string_view nextTupleLabel(const char *&labels)
  {
    const char *start = labels;
    while (true)
    {
      char current = *labels++;
      if (current == ' ' || current == '\0')
      {
        break;
      }
    }
    return {start, size_t(labels - start - 1)};
  }

} // end anonymous namespace

bool opencombine_enumerate_fields(const void *opaqueMetadataPtr,
                                  bool allowResilientSuperclasses,
                                  void *enumeratorContext,
                                  OpenCombineFieldEnumerator enumerator)
{
  auto enumerateFields = [&](const auto *metadata,
                             const TypeContextDescriptor *description) -> bool {
    const auto *fieldOffsets = metadata->getFieldOffsets();
    const FieldDescriptor &fieldDescriptor = *description->Fields;

    for (const FieldRecord &fieldRecord : fieldDescriptor)
    {
      if (!enumerator(enumeratorContext,
                      fieldRecord.getFieldName(0).data(),
                      *fieldOffsets++,
                      getTypeMetadata(fieldRecord, metadata)))
      {
        return false;
      }
    }

    return true;
  };

  const Metadata *metadata = static_cast<const Metadata *>(opaqueMetadataPtr);

  if (const auto *structMetadata = llvm::dyn_cast<StructMetadata>(metadata))
  {
    return enumerateFields(structMetadata, structMetadata->getDescription());
  }

  return false;
}
