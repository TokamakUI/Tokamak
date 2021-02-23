//===--- Unreachable.h - Implements swift_runtime_unreachable ---*- C++ -*-===//
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
//  This file defines swift_runtime_unreachable, an LLVM-independent
//  implementation of llvm_unreachable.
//
//===----------------------------------------------------------------------===//

// MODIFICATION NOTE:
// This file has been modified for the OpenCombine open source project.
// - Symbols have been prefix with the 'opencombine' prefix.

#ifndef OPENCOMBINE_SWIFT_RUNTIME_UNREACHABLE_H
#define OPENCOMBINE_SWIFT_RUNTIME_UNREACHABLE_H

#include <assert.h>
#include <stdlib.h>

#include "swift/Runtime/Config.h"

OPENCOMBINE_SWIFT_RUNTIME_ATTRIBUTE_NORETURN
inline static void opencombine_swift_runtime_unreachable(const char *msg) {
  assert(false && msg);
  (void)msg;
  abort();
}

#endif // OPENCOMBINE_SWIFT_RUNTIME_UNREACHABLE_H
