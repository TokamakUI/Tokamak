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

public struct Image: PrimitiveView {
  let label: Text?
  let name: String
  let bundle: Bundle?

  public init(_ name: String, bundle: Bundle? = nil) {
    label = Text(name)
    self.name = name
    self.bundle = bundle
  }

  public init(_ name: String, bundle: Bundle? = nil, label: Text) {
    self.label = label
    self.name = name
    self.bundle = bundle
  }

  public init(decorative name: String, bundle: Bundle? = nil) {
    label = nil
    self.name = name
    self.bundle = bundle
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _ImageProxy {
  public let subject: Image

  public init(_ subject: Image) { self.subject = subject }

  public var labelString: String? { subject.label?.storage.rawText }
  public var name: String { subject.name }
  public var path: String? { subject.bundle?.path(forResource: subject.name, ofType: nil) }
}
