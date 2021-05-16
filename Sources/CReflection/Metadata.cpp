//===--- Metadata.cpp - Swift Language ABI Metadata Support ---------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// Implementations of the metadata ABI functions.
//
//===----------------------------------------------------------------------===//

// MODIFICATION NOTE:
// This file has been modified for the OpenCombine open source project.
// - Some functions have been removed.
// - The swift namespace is wrapped in the opencombine namespace.

#include "swift/Runtime/Metadata.h"

using namespace tokamak;
using namespace swift;

#if OPENCOMBINE_SWIFT_OBJC_INTEROP
static ClassMetadataBounds computeMetadataBoundsForObjCClass(Class cls) {
  cls = swift_getInitializedObjCClass(cls);
  auto metadata = reinterpret_cast<const ClassMetadata *>(cls);
  return metadata->getClassBoundsAsSwiftSuperclass();
}
#endif

static ClassMetadataBounds
computeMetadataBoundsForSuperclass(const void *ref,
                                   TypeReferenceKind refKind) {
  switch (refKind) {
  case TypeReferenceKind::IndirectTypeDescriptor: {
    auto description = *reinterpret_cast<const ClassDescriptor * const *>(ref);
    if (!description) {
//      swift::fatalError(0, "instantiating class metadata for class with "
//                           "missing weak-linked ancestor");
        abort();
    }
    return description->getMetadataBounds();
  }

  case TypeReferenceKind::DirectTypeDescriptor: {
    auto description = reinterpret_cast<const ClassDescriptor *>(ref);
    return description->getMetadataBounds();
  }

  case TypeReferenceKind::DirectObjCClassName: {
#if OPENCOMBINE_SWIFT_OBJC_INTEROP
    auto cls = objc_lookUpClass(reinterpret_cast<const char *>(ref));
    return computeMetadataBoundsForObjCClass(cls);
#else
    break;
#endif
  }

  case TypeReferenceKind::IndirectObjCClass: {
#if OPENCOMBINE_SWIFT_OBJC_INTEROP
    auto cls = *reinterpret_cast<const Class *>(ref);
    return computeMetadataBoundsForObjCClass(cls);
#else
    break;
#endif
  }
  }
  opencombine_swift_runtime_unreachable("unsupported superclass reference kind");
}

static ClassMetadataBounds computeMetadataBoundsFromSuperclass(
                                      const ClassDescriptor *description,
                                      StoredClassMetadataBounds &storedBounds) {
  ClassMetadataBounds bounds;

  // Compute the bounds for the superclass, extending it to the minimum
  // bounds of a Swift class.
  if (const void *superRef = description->getResilientSuperclass()) {
    bounds = computeMetadataBoundsForSuperclass(superRef,
                           description->getResilientSuperclassReferenceKind());
  } else {
    bounds = ClassMetadataBounds::forSwiftRootClass();
  }

  // Add the subclass's immediate members.
  bounds.adjustForSubclass(description->areImmediateMembersNegative(),
                           description->NumImmediateMembers);

  // Cache before returning.
  storedBounds.initialize(bounds);
  return bounds;
}

ClassMetadataBounds
swift::getResilientMetadataBounds(const ClassDescriptor *description) {
  assert(description->hasResilientSuperclass());
  auto &storedBounds = *description->ResilientMetadataBounds.get();

  ClassMetadataBounds bounds;
  if (storedBounds.tryGet(bounds)) {
    return bounds;
  }

  return computeMetadataBoundsFromSuperclass(description, storedBounds);
}

int32_t
swift::getResilientImmediateMembersOffset(const ClassDescriptor *description) {
  assert(description->hasResilientSuperclass());
  auto &storedBounds = *description->ResilientMetadataBounds.get();

  ptrdiff_t result;
  if (storedBounds.tryGetImmediateMembersOffset(result)) {
    return result / sizeof(void*);
  }

  auto bounds = computeMetadataBoundsFromSuperclass(description, storedBounds);
  return bounds.ImmediateMembersOffset / sizeof(void*);
}
