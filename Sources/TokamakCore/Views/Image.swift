// Copyright 2018-2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Jed Fox on 07/01/2020.
//

import Foundation

public class _AnyImageProviderBox: AnyTokenBox, Equatable {
  public struct _Image {
    public indirect enum Storage {
      case named(String, bundle: Bundle?)
      case resizable(Storage, capInsets: EdgeInsets, resizingMode: Image.ResizingMode)
    }

    public let storage: Storage
    public let label: Text?

    public init(storage: Storage, label: Text?) {
      self.storage = storage
      self.label = label
    }
  }

  public static func == (lhs: _AnyImageProviderBox, rhs: _AnyImageProviderBox) -> Bool {
    lhs.equals(rhs)
  }

  public func equals(_ other: _AnyImageProviderBox) -> Bool {
    fatalError("implement \(#function) in subclass")
  }

  public func resolve(in environment: EnvironmentValues) -> _Image {
    fatalError("implement \(#function) in subclass")
  }
}

private class NamedImageProvider: _AnyImageProviderBox {
  let name: String
  let bundle: Bundle?
  let label: Text?

  init(name: String, bundle: Bundle?, label: Text?) {
    self.name = name
    self.bundle = bundle
    self.label = label
  }

  override func equals(_ other: _AnyImageProviderBox) -> Bool {
    guard let other = other as? NamedImageProvider else { return false }
    return other.name == name
      && other.bundle?.bundlePath == bundle?.bundlePath
      && other.label == label
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    .init(storage: .named(name, bundle: bundle), label: label)
  }
}

private class ResizableProvider: _AnyImageProviderBox {
  let parent: _AnyImageProviderBox
  let capInsets: EdgeInsets
  let resizingMode: Image.ResizingMode

  init(parent: _AnyImageProviderBox, capInsets: EdgeInsets, resizingMode: Image.ResizingMode) {
    self.parent = parent
    self.capInsets = capInsets
    self.resizingMode = resizingMode
  }

  override func equals(_ other: _AnyImageProviderBox) -> Bool {
    guard let other = other as? ResizableProvider else { return false }
    return other.parent.equals(parent)
      && other.capInsets == capInsets
      && other.resizingMode == resizingMode
  }

  override func resolve(in environment: EnvironmentValues) -> ResolvedValue {
    let resolved = parent.resolve(in: environment)
    return .init(
      storage: .resizable(
        resolved.storage,
        capInsets: capInsets,
        resizingMode: resizingMode
      ),
      label: resolved.label
    )
  }
}

public struct Image: _PrimitiveView, Equatable {
  @_spi(TokamakCore)
  public let provider: _AnyImageProviderBox

  @Environment(\.self)
  var environment

  @_spi(TokamakCore)
  @State
  public var _intrinsicSize: CGSize?

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.provider == rhs.provider
  }

  init(_ provider: _AnyImageProviderBox) {
    self.provider = provider
  }
}

public extension Image {
  init(_ name: String, bundle: Bundle? = nil) {
    self.init(name, bundle: bundle, label: Text(name))
  }

  init(_ name: String, bundle: Bundle? = nil, label: Text) {
    self.init(NamedImageProvider(name: name, bundle: bundle, label: label))
  }

  init(decorative name: String, bundle: Bundle? = nil) {
    self.init(NamedImageProvider(name: name, bundle: bundle, label: nil))
  }
}

public extension Image {
  enum ResizingMode: Hashable {
    case tile
    case stretch
  }

  func resizable(
    capInsets: EdgeInsets = EdgeInsets(),
    resizingMode: ResizingMode = .stretch
  ) -> Image {
    .init(ResizableProvider(parent: provider, capInsets: capInsets, resizingMode: resizingMode))
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _ImageProxy {
  public let subject: Image

  public init(_ subject: Image) { self.subject = subject }

  public var provider: _AnyImageProviderBox { subject.provider }
  public var environment: EnvironmentValues { subject.environment }
}

extension Image: Layout {
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    environment.measureImage(self, proposal, environment)
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(at: bounds.origin, proposal: proposal)
    }
  }
}
