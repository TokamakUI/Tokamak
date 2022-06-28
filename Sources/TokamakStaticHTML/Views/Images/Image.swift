// Copyright 2020 Tokamak contributors
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
//  Created by Max Desiatov on 11/04/2020.
//

@_spi(TokamakCore)
import TokamakCore

public typealias Image = TokamakCore.Image

extension Image: _HTMLPrimitive {
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    AnyView(_HTMLImage(proxy: _ImageProxy(self)))
  }
}

struct _HTMLImage: View {
  let proxy: _ImageProxy
  public var body: some View {
    let resolved = proxy.provider.resolve(in: proxy.environment)
    var attributes: [HTMLAttribute: String] = [:]
    switch resolved.storage {
    case let .named(name, bundle):
      attributes = [
        "src": bundle?.path(forResource: name, ofType: nil) ?? name,
        "style": "max-width: 100%; max-height: 100%;",
      ]
    case let .resizable(.named(name, bundle), _, _):
      attributes = [
        "src": bundle?.path(forResource: name, ofType: nil) ?? name,
        "style": "width: 100%; height: 100%;",
      ]
    default: break
    }
    if let label = resolved.label {
      attributes["alt"] = _TextProxy(label).rawText
    }
    return AnyView(HTML("img", attributes))
  }
}

@_spi(TokamakStaticHTML)
extension Image: HTMLConvertible {
  public var tag: String { "img" }
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    let proxy = _ImageProxy(self)
    let resolved = proxy.provider.resolve(in: proxy.environment)

    switch resolved.storage {
    case let .named(name, bundle):
      let src = bundle?.path(forResource: name, ofType: nil) ?? name
      if useDynamicLayout {
        return [
          "src": src,
          "data-loaded": _intrinsicSize != nil ? "true" : "false",
        ]
      } else {
        return [
          "src": src,
          "style": "max-width: 100%; max-height: 100%;",
        ]
      }
    case let .resizable(.named(name, bundle), _, _):
      let src = bundle?.path(forResource: name, ofType: nil) ?? name
      if useDynamicLayout {
        return [
          "src": src,
          "data-loaded": _intrinsicSize != nil ? "true" : "false",
        ]
      } else {
        return [
          "src": src,
          "style": "width: 100%; height: 100%;",
        ]
      }
    default: return [:]
    }
  }
}
