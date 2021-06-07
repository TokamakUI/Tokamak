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
//  Created by Emil Pedersen on 2021-03-26.
//

import struct Foundation.Date
import JavaScriptKit
import TokamakCore
import TokamakStaticHTML

extension DatePicker: DOMPrimitive {
  var renderedBody: AnyView {
    let proxy = _DatePickerProxy(self)

    let type = proxy.displayedComponents

    let attributes: [HTMLAttribute: String] = [
      "type": type.inputType,
      "min": proxy.min.map { type.format(date: $0) } ?? "",
      "max": proxy.max.map { type.format(date: $0) } ?? "",
      .value: type.format(date: proxy.valueBinding.wrappedValue),
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
              let current = JSDate(
                millisecondsSinceEpoch: proxy.valueBinding.wrappedValue
                  .timeIntervalSince1970 * 1000
              )
              let str = event.target.object!.value.string!
              let decomposed = type.parse(date: str)
              if let date = decomposed.date {
                let components = date.components(separatedBy: "-")
                if components.count == 3 {
                  current.fullYear = Int(components[0]) ?? 0
                  current.month = (Int(components[1]) ?? 0) - 1
                  current.date = Int(components[2]) ?? 0
                }
              }
              if let time = decomposed.time {
                let components = time.components(separatedBy: ":")
                if components.count == 2 {
                  current.hours = Int(components[0]) ?? 0
                  current.minutes = Int(components[1]) ?? 0
                }
              }
              let ms = current.valueOf()
              if ms.isFinite {
                proxy.valueBinding.wrappedValue = Date(timeIntervalSince1970: ms / 1000)
              }
            },
          ]
        )
      }
    )
  }
}

extension DatePickerComponents {
  var inputType: String {
    switch (contains(.hourAndMinute), contains(.date)) {
    case (true, true): return "datetime-local"
    case (true, false): return "time"
    case (false, true): return "date"
    case (false, false):
      fatalError("invalid date components: must select at least date or hourAndMinute")
    }
  }

  func format(date: Date) -> String {
    let date = JSDate(millisecondsSinceEpoch: date.timeIntervalSince1970 * 1000)
    var partial: [String] = []
    if contains(.date) {
      let y = date.fullYear
      let year: String
      if y < 0 {
        year = "-" + "00000\(-y)".suffix(6)
      } else if y > 9999 {
        year = "+" + "00000\(y)".suffix(6)
      } else {
        year = String("000\(y)".suffix(4))
      }
      partial.append("\(year)-\("0\(date.month + 1)".suffix(2))-\("0\(date.date)".suffix(2))")
    }
    if contains(.hourAndMinute) {
      partial.append("\("0\(date.hours)".suffix(2)):\("0\(date.minutes)".suffix(2))")
    }
    return partial.joined(separator: "T")
  }

  /// Decomposes a formatted string into a date and a time component
  func parse(date: String) -> (date: String?, time: String?) {
    switch (contains(.hourAndMinute), contains(.date)) {
    case (true, true):
      let components = date.components(separatedBy: "T")
      if components.count == 2 {
        return (components[0], components[1])
      }
      return (nil, nil)
    case (true, false):
      return (nil, date)
    case (false, true):
      return (date, nil)
    case (false, false):
      return (nil, nil)
    }
  }
}
