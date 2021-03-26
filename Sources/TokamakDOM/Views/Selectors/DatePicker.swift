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

import struct Foundation.Date
import JavaScriptKit
import TokamakCore
import TokamakStaticHTML

extension DatePicker: ViewDeferredToRenderer {
  @_spi(TokamakCore)
  public var deferredBody: AnyView {
    let proxy = _DatePickerProxy(self)

    let type = proxy.displayedComponents

    let attributes: [HTMLAttribute: String] = [
      "type": type.inputType,
      "min": proxy.min
        .map { type.format(date: JSDate(millisecondsSinceEpoch: $0.timeIntervalSince1970 * 1000))
        } ??
        "",
      "max": proxy.max
        .map { type.format(date: JSDate(millisecondsSinceEpoch: $0.timeIntervalSince1970 * 1000))
        } ??
        "",
      .value: type
        .format(date: JSDate(
          millisecondsSinceEpoch: proxy.valueBinding.wrappedValue
            .timeIntervalSince1970 * 1000
        )),
    ]

    return AnyView(
      HStack {
        proxy.label
        Text(" ")
        DynamicHTML(
          "input",
          attributes,
          listeners: [
            "input": { event in
              proxy.valueBinding
                .wrappedValue =
                Date(timeIntervalSince1970: JSDate(
                  unsafelyWrapping: JSDate.constructor
                    .new(event.target.object!.value.string!)
                ).valueOf() / 1000)
            },
          ]
        )
      }
    )
  }
}

extension DatePickerComponents {
  var inputType: String {
    switch (self.contains(.hourAndMinute), self.contains(.date)) {
    case (true, true): return "datetime-local"
    case (true, false): return "time"
    case (false, true): return "date"
    case (false, false):
      fatalError("invalid date components: must select at least date or hourAndMinute")
    }
  }

  func format(date: JSDate) -> String {
    switch (self.contains(.hourAndMinute), self.contains(.date)) {
    case (true, true):
      return String(date.toISOString().dropLast(8)) // remove seconds, milliseconds and Z
    case (true, false):
      let datetime = date.toISOString().dropLast(8)
      return String(
        datetime
          .dropFirst(datetime.count - 5)
      ) // year can be 4 or 7 characters according to the spec
    case (false, true):
      return String(date.toISOString().dropLast(14)) // remove time component
    case (false, false):
      fatalError("invalid date components: must select at least date or hourAndMinute")
    }
  }
}
