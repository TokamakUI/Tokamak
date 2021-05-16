//===--- Metadata.h - Swift Language ABI Metadata Support -------*- C++ -*-===//
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
// Swift runtime support for generating and uniquing metadata.
//
//===----------------------------------------------------------------------===//

#ifndef OPENCOMBINE_SWIFT_RUNTIME_METADATA_H
#define OPENCOMBINE_SWIFT_RUNTIME_METADATA_H

#include "swift/ABI/Metadata.h"
#include "swift/Reflection/Records.h"

// MODIFICATION NOTE:
// This file has been modified for the OpenCombine open source project.
// - Some declarations have been removed.
// - The swift namespace is wrapped in the opencombine namespace.
// - Replaced ArrayRef and StringRef with span and string_view

namespace tokamak {
namespace swift {

/// Compute the bounds of class metadata with a resilient superclass.
ClassMetadataBounds getResilientMetadataBounds(
                                           const ClassDescriptor *descriptor);
int32_t getResilientImmediateMembersOffset(const ClassDescriptor *descriptor);

#if OPENCOMBINE_SWIFT_OBJC_INTEROP

extern "C" Class swift_getInitializedObjCClass(Class c);

#endif

} // end namespace swift
} // end namespace tokamak

#endif // OPENCOMBINE_SWIFT_RUNTIME_METADATA_H
