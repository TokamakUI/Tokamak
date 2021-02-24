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
//  Created by Sergej Jaskiewicz on 23/09/2019.
//

#ifndef CREFLECTION_H
#define CREFLECTION_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if __has_attribute(swift_name)
#define TOKAMAK_SWIFT_NAME(_name) __attribute__((swift_name(#_name)))
#else
#define TOKAMAK_SWIFT_NAME(_name)
#endif

#ifdef __cplusplus
extern "C"
{
#endif

#pragma mark - Type metadata

  typedef bool (*_Nonnull TokamakFieldEnumerator)(
      void *_Nullable enumeratorContext,
      const char *_Nonnull fieldName,
      size_t fieldOffset,
      const void *_Nonnull fieldTypeMetadataPtr);

  bool
  tokamak_enumerate_fields(
    const void *_Nonnull type_metadata,
    bool allowResilientSuperclasses,
    void *_Nullable enumerator_context,
    TokamakFieldEnumerator enumerator
  ) TOKAMAK_SWIFT_NAME(enumerateFields(typeMetadata:allowResilientSuperclasses:enumeratorContext:enumerator:));

  size_t tokamak_get_size(const void *_Nonnull opaqueMetadataPtr);
#ifdef __cplusplus
} // extern "C"
#endif

#endif /* CREFLECTION_H */
