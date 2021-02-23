//===--- AlignOf.h - Portable calculation of type alignment -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the AlignedCharArrayUnion class.
//
//===----------------------------------------------------------------------===//

// MODIFICATION NOTE:
// This file has been modified for the OpenCombine open source project.
// - The llvm namespace is wrapped in the opencombine namespace.

#ifndef OPENCOMBINE_LLVM_SUPPORT_ALIGNOF_H
#define OPENCOMBINE_LLVM_SUPPORT_ALIGNOF_H

#include "llvm/Support/Compiler.h"
#include <cstddef>

namespace tokamak {
namespace llvm {

namespace detail {

template <typename T, typename... Ts> class AlignerImpl {
  T t;
  AlignerImpl<Ts...> rest;
  AlignerImpl() = delete;
};

template <typename T> class AlignerImpl<T> {
  T t;
  AlignerImpl() = delete;
};

template <typename T, typename... Ts> union SizerImpl {
  char arr[sizeof(T)];
  SizerImpl<Ts...> rest;
};

template <typename T> union SizerImpl<T> { char arr[sizeof(T)]; };
} // end namespace detail

/// A suitably aligned and sized character array member which can hold elements
/// of any type.
///
/// These types may be arrays, structs, or any other types. This exposes a
/// `buffer` member which can be used as suitable storage for a placement new of
/// any of these types.
template <typename T, typename... Ts> struct AlignedCharArrayUnion {
  alignas(detail::AlignerImpl<T, Ts...>) char buffer[sizeof(
      llvm::detail::SizerImpl<T, Ts...>)];
};

} // end namespace llvm
} // end namespace tokamak

#endif // OPENCOMBINE_LLVM_SUPPORT_ALIGNOF_H
