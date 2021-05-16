//===--- Config.h - Swift Language Platform Configuration -------*- C++ -*-===//
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
// Definitions of common interest in Swift.
//
//===----------------------------------------------------------------------===//

// MODIFICATION NOTE:
// This file has been modified for the OpenCombine open source project.
// Some macros have been renamed or removed.

#ifndef OPENCOMBINE_SWIFT_RUNTIME_CONFIG_H
#define OPENCOMBINE_SWIFT_RUNTIME_CONFIG_H

#ifdef __GNUC__
#define OPENCOMBINE_SWIFT_RUNTIME_ATTRIBUTE_NORETURN __attribute__((noreturn))
#elif defined(_MSC_VER)
#define OPENCOMBINE_SWIFT_RUNTIME_ATTRIBUTE_NORETURN __declspec(noreturn)
#else
#define OPENCOMBINE_SWIFT_RUNTIME_ATTRIBUTE_NORETURN
#endif

/// Does the current Swift platform support "unbridged" interoperation
/// with Objective-C?  If so, the implementations of various types must
/// implicitly handle Objective-C pointers.
///
/// Apple platforms support this by default.
#ifndef OPENCOMBINE_SWIFT_OBJC_INTEROP
#ifdef __APPLE__
#define OPENCOMBINE_SWIFT_OBJC_INTEROP 1
#else
#define OPENCOMBINE_SWIFT_OBJC_INTEROP 0
#endif
#endif

/// Which bits in the class metadata are used to distinguish Swift classes
/// from ObjC classes?
#ifndef OPENCOMBINE_SWIFT_CLASS_IS_SWIFT_MASK

#if !defined(__APPLE__)
// Non-Apple platforms always use 1.
#define OPENCOMBINE_SWIFT_CLASS_IS_SWIFT_MASK 1ULL
#else
// Builds for Swift-in-the-OS always use 2.
#define OPENCOMBINE_SWIFT_CLASS_IS_SWIFT_MASK 2ULL
#endif
#endif

// Define mappings for calling conventions.

#if __has_attribute(swiftcall)
#define OPENCOMBINE_SWIFT_CALLING_CONVENTION __attribute__((swiftcall))
#define OPENCOMBINE_SWIFT_CONTEXT __attribute__((swift_context))
#define OPENCOMBINE_SWIFT_ERROR_RESULT __attribute__((swift_error_result))
#define OPENCOMBINE_SWIFT_INDIRECT_RESULT __attribute__((swift_indirect_result))
#else
#define OPENCOMBINE_SWIFT_CALLING_CONVENTION
#define OPENCOMBINE_SWIFT_CONTEXT
#define OPENCOMBINE_SWIFT_ERROR_RESULT
#define OPENCOMBINE_SWIFT_INDIRECT_RESULT
#endif

#endif // OPENCOMBINE_SWIFT_RUNTIME_CONFIG_H
