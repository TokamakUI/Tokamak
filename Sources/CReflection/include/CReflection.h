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

#ifndef COPENCOMBINEHELPERS_H
#define COPENCOMBINEHELPERS_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if __has_attribute(swift_name)
#define OPENCOMBINE_SWIFT_NAME(_name) __attribute__((swift_name(#_name)))
#else
#define OPENCOMBINE_SWIFT_NAME(_name)
#endif

#ifdef __cplusplus
extern "C"
{
#endif

#pragma mark - CombineIdentifier

  uint64_t opencombine_next_combine_identifier(void)
      OPENCOMBINE_SWIFT_NAME(nextCombineIdentifier());

#pragma mark - OpenCombineUnfairLock

  /// A wrapper around an opaque pointer for type safety in Swift.
  typedef struct OpenCombineUnfairLock
  {
    void *_Nonnull opaque;
  } OPENCOMBINE_SWIFT_NAME(UnfairLock) OpenCombineUnfairLock;

  /// Allocates a lock object. The allocated object must be destroyed by calling
  /// the destroy() method.
  OpenCombineUnfairLock opencombine_unfair_lock_alloc(void)
      OPENCOMBINE_SWIFT_NAME(UnfairLock.allocate());

  void opencombine_unfair_lock_lock(OpenCombineUnfairLock)
      OPENCOMBINE_SWIFT_NAME(UnfairLock.lock(self:));

  void opencombine_unfair_lock_unlock(OpenCombineUnfairLock)
      OPENCOMBINE_SWIFT_NAME(UnfairLock.unlock(self:));

  void opencombine_unfair_lock_assert_owner(OpenCombineUnfairLock mutex)
      OPENCOMBINE_SWIFT_NAME(UnfairLock.assertOwner(self:));

  void opencombine_unfair_lock_dealloc(OpenCombineUnfairLock lock)
      OPENCOMBINE_SWIFT_NAME(UnfairLock.deallocate(self:));

#pragma mark - OpenCombineUnfairRecursiveLock

  /// A wrapper around an opaque pointer for type safety in Swift.
  typedef struct OpenCombineUnfairRecursiveLock
  {
    void *_Nonnull opaque;
  } OPENCOMBINE_SWIFT_NAME(UnfairRecursiveLock) OpenCombineUnfairRecursiveLock;

  OpenCombineUnfairRecursiveLock opencombine_unfair_recursive_lock_alloc(void)
      OPENCOMBINE_SWIFT_NAME(UnfairRecursiveLock.allocate());

  void opencombine_unfair_recursive_lock_lock(OpenCombineUnfairRecursiveLock)
      OPENCOMBINE_SWIFT_NAME(UnfairRecursiveLock.lock(self:));

  void opencombine_unfair_recursive_lock_unlock(OpenCombineUnfairRecursiveLock)
      OPENCOMBINE_SWIFT_NAME(UnfairRecursiveLock.unlock(self:));

  void opencombine_unfair_recursive_lock_dealloc(OpenCombineUnfairRecursiveLock lock)
      OPENCOMBINE_SWIFT_NAME(UnfairRecursiveLock.deallocate(self:));

#pragma mark - Type metadata

  typedef bool (*_Nonnull OpenCombineFieldEnumerator)(
      void *_Nullable enumeratorContext,
      const char *_Nonnull fieldName,
      size_t fieldOffset,
      const void *_Nonnull fieldTypeMetadataPtr);

  bool
  opencombine_enumerate_fields(
      const void *_Nonnull type_metadata,
      bool allowResilientSuperclasses,
      void *_Nullable enumerator_context,
      OpenCombineFieldEnumerator enumerator) OPENCOMBINE_SWIFT_NAME(enumerateFields(typeMetadata:allowResilientSuperclasses:enumeratorContext:enumerator:));

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* COPENCOMBINEHELPERS_H */
