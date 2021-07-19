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
//  Created by Carson Katri on 9/9/20.
//

import struct Foundation.URL

public struct Link<Label>: _PrimitiveView where Label: View {
  let destination: URL
  let label: Label

  public init(destination: URL, @ViewBuilder label: () -> Label) {
    (self.destination, self.label) = (destination, label())
  }
}

public extension Link where Label == Text {
  init<S: StringProtocol>(_ titleKey: S, destination: URL) {
    self.init(destination: destination) { Text(titleKey) }
  }
}

public struct _LinkProxy<Label> where Label: View {
  public let subject: Link<Label>

  public init(_ subject: Link<Label>) { self.subject = subject }

  public var label: Label { subject.label }
  public var destination: URL {
    subject.destination
  }
}
