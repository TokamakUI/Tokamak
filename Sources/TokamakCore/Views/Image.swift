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

public struct Image: View {
  let label: Text?
  let imageName: String
  let isSystem: Bool

  public init(_ name: String) {
    label = Text(name)
    imageName = name
    isSystem = false
  }

  public init(_ name: String, label: Text) {
    self.label = label
    imageName = name
    isSystem = false
  }

  public init(decorative name: String) {
    label = nil
    imageName = name
    isSystem = false
  }

  public init(systemName: String) {
    label = nil
    imageName = systemName
    isSystem = true
  }

  public var body: Never {
    neverBody("Image")
  }
}

/// This is a helper class that works around absence of "package private" access control in Swift
public struct _ImageProxy {
  public let subject: Image

  public init(_ subject: Image) { self.subject = subject }

  public var label: String? { subject.label?.content }
  public var imageName: String { subject.imageName }
  public var isSystem: Bool { subject.isSystem }
}
