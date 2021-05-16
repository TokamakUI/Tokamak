//===--- Demangler.cpp - String to Node-Tree Demangling -------------------===//
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
//  This file implements new Swift de-mangler.
//
//===----------------------------------------------------------------------===//

// MODIFICATION NOTE:
// This file has been modified for the OpenCombine open source project.
// - Some functions have been removed.
// - The swift namespace is wrapped in the opencombine namespace.

#include "swift/Demangling/Demangle.h"

using namespace tokamak;
using namespace swift;

string_view
swift::Demangle::makeSymbolicMangledNameStringRef(const char *base) {
  if (!base)
    return {};

  auto end = base;
  while (*end != '\0') {
    // Skip over symbolic references.
    if (*end >= '\x01' && *end <= '\x17')
      end += sizeof(uint32_t);
    else if (*end >= '\x18' && *end <= '\x1F')
      end += sizeof(void*);
    ++end;
  }
  return { base, size_t(end - base) };
}
