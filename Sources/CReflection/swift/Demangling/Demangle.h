//===--- Demangle.h - Interface to Swift symbol demangling ------*- C++ -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// This file is the public API of the demangler library.
// Tools which use the demangler library (like lldb) must include this - and
// only this - header file.
//
//===----------------------------------------------------------------------===//

// MODIFICATION NOTE:
// This file has been modified for the OpenCombine open source project.
// - Some declarations have been removed.
// - The swift namespace is wrapped in the opencombine namespace.

#ifndef OPENCOMBINE_SWIFT_DEMANGLING_DEMANGLE_H
#define OPENCOMBINE_SWIFT_DEMANGLING_DEMANGLE_H

#include <memory>
#include <string>
#include <cassert>
#include <cstdint>
#include "stl_polyfill/string_view.h"

namespace tokamak {
namespace swift {
namespace Demangle {
/// Form a StringRef around the mangled name starting at base, if the name may
/// contain symbolic references.
string_view makeSymbolicMangledNameStringRef(const char *base);

} // end namespace Demangle
} // end namespace swift
} // end namespace tokamak

#endif // OPENCOMBINE_SWIFT_DEMANGLING_DEMANGLE_H
