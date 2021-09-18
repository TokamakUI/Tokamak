// Copyright 2021 Tokamak contributors
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

import TokamakCore

// TOOD: Add _AnyModifiedActionContent similar to TokamakStaticHTML/ModifiedContent.swift?
extension ModifiedContent: DOMPrimitive where Content: View, Modifier: DOMActionModifier {
  public var renderedBody: AnyView {
    // TODO: Combine DOM nodes when possible, rather than generating arbitrary new ones
    AnyView(DynamicHTML("div", listeners: modifier.listeners) {
      content
    })
  }
}
