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

import JavaScriptKit
import TokamakCore

public typealias Image = TokamakCore.Image

enum ImagesKey: EnvironmentKey {
  static var defaultValue: [String: String] = [:]
}

enum SystemImagesKey: EnvironmentKey {
  static var defaultValue: [String: String] = [:]
}

extension EnvironmentValues {
  var images: [String: String] {
    get {
      self[ImagesKey.self]
    }
    set {
      self[ImagesKey.self] = newValue
    }
  }

  var systemImages: [String: String] {
    get {
      self[SystemImagesKey.self]
    }
    set {
      self[SystemImagesKey.self] = newValue
    }
  }
}

extension View {
  public func tokamakDOM_provideImages(_ images: [String: String]) -> some View {
    environment(\.images, images)
  }

  public func tokamakDOM_provideSystemImages(_ systemImages: [String: String]) -> some View {
    environment(\.systemImages, systemImages)
  }
}

extension Image: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    AnyView(_HTMLImage(proxy: _ImageProxy(self)))
  }
}

struct _HTMLImage: View {
  @Environment(\.systemImages) var systemImages: [String: String]
  @Environment(\.images) var images: [String: String]
  let proxy: _ImageProxy
  public var body: some View {
    let lookup = proxy.isSystem ? systemImages : images
    if let src = lookup[proxy.imageName] {
      return AnyView(HTML("img", ["src": src, "style": "max-width: 100%; max-height: 100%"]))
    } else {
      return AnyView(Text("Invalid image name \(proxy.imageName). Options are \(lookup)"))
    }
  }
}
