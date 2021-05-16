//===-- None.h - Simple null value for implicit construction ------*- C++ -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file provides None, an enumerator for use in implicit constructors
//  of various (usually templated) types to make such construction more
//  terse.
//
//===----------------------------------------------------------------------===//

// MODIFICATION NOTE:
// This file has been modified for the OpenCombine open source project.
// - The llvm namespace is wrapped in the opencombine namespace.

#ifndef OPENCOMBINE_LLVM_ADT_NONE_H
#define OPENCOMBINE_LLVM_ADT_NONE_H

namespace tokamak {
namespace llvm {
/// A simple null object to allow implicit construction of Optional<T>
/// and similar types without having to spell out the specialization's name.
// (constant value 1 in an attempt to workaround MSVC build issue... )
enum class NoneType { None = 1 };
const NoneType None = NoneType::None;
}
}

#endif
