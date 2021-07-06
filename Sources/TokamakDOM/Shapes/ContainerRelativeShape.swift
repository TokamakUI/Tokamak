// Copyright 2020-2021 Tokamak contributors
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

import Foundation
import JavaScriptKit
@_spi(TokamakCore) import TokamakCore
import TokamakStaticHTML

//extension _ContainerShapeModifier._ContainerShapeView : _DOMPrimitive {
//  public var renderedBody: AnyView {
//    AnyView(
//      content
//        .environment(\._containerShape, { rect, proxy in
//          guard let parentProxy = self.proxy else { return nil }
//          return shape
//            .inset(by: abs(proxy.size.width - parentProxy.size.width))
//            .path(in: rect)
//        })
//    )
//  }
//}
