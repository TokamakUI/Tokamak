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
//  Created by Carson Katri on 7/17/20.
//

import Runtime

public protocol DynamicProperty {
  mutating func update()
}

extension DynamicProperty {
  public mutating func update() {}
}

extension TypeInfo {
  /// Extract all `DynamicProperty` from a type, recursively.
  /// This is necessary as a `DynamicProperty` can be nested.
  /// `EnvironmentValues` can also be injected at this point.
  func dynamicProperties(_ environment: EnvironmentValues,
                         source: inout Any,
                         shouldUpdate: Bool) -> [PropertyInfo] {
    var dynamicProps = [PropertyInfo]()
    for prop in properties where prop.type is DynamicProperty.Type {
      dynamicProps.append(prop)
      // swiftlint:disable force_try
      let propInfo = try! typeInfo(of: prop.type)
      _ = propInfo.injectEnvironment(from: environment, into: &source)
      var extracted = try! prop.get(from: source)
      dynamicProps.append(
        contentsOf: propInfo.dynamicProperties(environment,
                                               source: &extracted,
                                               shouldUpdate: shouldUpdate)
      )
      // swiftlint:disable:next force_cast
      var extractedDynamicProp = extracted as! DynamicProperty
      if shouldUpdate {
        extractedDynamicProp.update()
      }
      try! prop.set(value: extractedDynamicProp, on: &source)
      // swiftlint:enable force_try
    }
    return dynamicProps
  }
}
