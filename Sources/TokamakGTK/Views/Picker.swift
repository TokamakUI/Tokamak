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

import CGTK
import TokamakCore

extension _PickerContainer: AnyWidget {
  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget> {
    let comboBox = gtk_combo_box_text_new()!
    comboBox.withMemoryRebound(to: GtkComboBoxText.self, capacity: 1) { gtkComboBox in
      for element in elements {
        if let text = mapAnyView(element.anyContent, transform: { (view: Text) in view }) {
          gtk_combo_box_text_append_text(gtkComboBox, _TextProxy(text).rawText)
        }
      }
    }
    updateSelection(of: comboBox)
    setupSignal(for: comboBox)
    return comboBox
  }

  func update(widget: Widget) {
    if case let .widget(comboBox) = widget.storage {
      comboBox.disconnect(gtype: gtk_combo_box_text_get_type(), signal: "changed")
      updateSelection(of: comboBox)
      setupSignal(for: comboBox)
    }
  }

  func updateSelection(of comboBox: UnsafeMutablePointer<GtkWidget>) {
    comboBox.withMemoryRebound(to: GtkComboBox.self, capacity: 1) {
      guard let activeElement = elements.firstIndex(where: {
        guard let selectedValue = $0.anyId as? SelectionValue else { return false }
        return selectedValue == selection
      }) else { return }
      gtk_combo_box_set_active($0, Int32(activeElement))
    }
  }

  func setupSignal(for comboBox: UnsafeMutablePointer<GtkWidget>) {
    comboBox.connect(signal: "changed") { box in
      box?.withMemoryRebound(to: GtkComboBox.self, capacity: 1) { plainComboBox in
        if gtk_combo_box_get_active(plainComboBox) != 0 {
          plainComboBox.withMemoryRebound(to: GtkComboBoxText.self, capacity: 1) { comboBoxText in
            let activeElement = gtk_combo_box_text_get_active_text(comboBoxText)!
            defer {
              g_free(activeElement)
            }
            let element = elements.first {
              guard let text = mapAnyView($0.anyContent, transform: { (view: Text) in view })
              else { return false }
              return _TextProxy(text).rawText == String(cString: activeElement)
            }
            if let selectedValue = element?.anyId as? SelectionValue {
              selection = selectedValue
            }
          }
        }
      }
    }
  }
}
