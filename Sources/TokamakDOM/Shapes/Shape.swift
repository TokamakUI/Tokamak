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
//  Created by Carson Katri on 6/29/20.
//

import TokamakCore

// This isn't identical to the SwiftUI API, but is a simple overload to support HTML `border`.
// fileprivate struct _BorderModifier : ViewModifier, DOMViewModifier {
//    let color: Color
//    let width: CGFloat
//
//    var attributes: [String : String] {
//        ["style": "border-color: \(color.description); border-width: \(width); border-style: solid;"]
//    }
//
//    func body(content: Content) -> some View {
//        content
//    }
// }
// extension View {
//    public func border(_ content: S, width: CGFloat = 1) -> some View {
//        modifier(_BorderModifier(color: content, width: width))
//    }
// }

// extension _OverlayModifier : DOMViewModifier where Overlay == _StrokedShape<Rectangle._Inset> {
//  public var attributes: [String : String] {
//    ["style": "border: 1px solid red"]
//  }
// }
