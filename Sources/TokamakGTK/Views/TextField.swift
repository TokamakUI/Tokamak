//
//  File.swift
//
//
//  Created by Morten Bek Ditlevsen on 27/12/2020.
//

import CGTK
import Foundation
import TokamakCore

extension TextField: ViewDeferredToRenderer where Label == Text {
  public var deferredBody: AnyView {
    AnyView(WidgetView(build: { _ in
      let proxy = _TextFieldProxy(self)
      let entry = gtk_entry_new()!
      entry.withMemoryRebound(to: GtkEntry.self, capacity: 1) {
        gtk_entry_set_text($0, _TextFieldProxy(self).textBinding.wrappedValue)
      }
      return entry
    }, update: { _ in

    }) {})
  }

//  func new(_ application: UnsafeMutablePointer<GtkApplication>) -> UnsafeMutablePointer<GtkWidget> {
//    let proxy = _TextFieldProxy(self)
//    let entry = gtk_entry_new()!
//    entry.withMemoryRebound(to: GtkEntry.self, capacity: 1) {
//      gtk_entry_set_text($0, _TextFieldProxy(self).textBinding.wrappedValue)
//    }
//    return entry
//  }
//
//  func update(widget: Widget) {
//    if case let .widget(w) = widget.storage {
//      w.withMemoryRebound(to: GtkEntry.self, capacity: 1) {
//        gtk_entry_set_text($0, _TextFieldProxy(self).textBinding.wrappedValue)
//      }
//    }
//  }

//  func css(for style: TextFieldStyle) -> String {
//    if style is PlainTextFieldStyle {
//      return """
//      background: transparent;
//      border: none;
//      """
//    } else {
//      return ""
//    }
//  }
//
//  func className(for style: TextFieldStyle) -> String {
//    switch style {
//    case is DefaultTextFieldStyle, is RoundedBorderTextFieldStyle:
//      return "_tokamak-formcontrol"
//    default:
//      return ""
//    }
//  }

//  public var deferredBody: AnyView {
//    let proxy = _TextFieldProxy(self)
//
//    return AnyView(DynamicHTML("input", [
//      "type": proxy.textFieldStyle is RoundedBorderTextFieldStyle ? "search" : "text",
//      .value: proxy.textBinding.wrappedValue,
//      "placeholder": proxy.label.rawText,
//      "style": css(for: proxy.textFieldStyle),
//      "class": className(for: proxy.textFieldStyle),
//    ], listeners: [
//      "focus": { _ in proxy.onEditingChanged(true) },
//      "blur": { _ in proxy.onEditingChanged(false) },
//      "keypress": { event in if event.key == "Enter" { proxy.onCommit() } },
//      "input": { event in
//        if let newValue = event.target.object?.value.string {
//          proxy.textBinding.wrappedValue = newValue
//        }
//      },
//    ]))
//  }
}
