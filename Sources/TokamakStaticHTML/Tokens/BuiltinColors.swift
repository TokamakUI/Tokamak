//
//  File.swift
//
//
//  Created by Carson Katri on 8/4/20.
//

import TokamakCore

// MARK: List Colors

extension Color {
  static var listSectionHeader: Self {
    Color._withScheme {
      switch $0 {
      case .light: return Color(0xDDDDDD)
      case .dark: return Color(0x323234)
      }
    }
  }

  static var groupedListBackground: Self {
    Color._withScheme {
      switch $0 {
      case .light: return Color(0xEEEEEE)
      case .dark: return .clear
      }
    }
  }

  static var listGroupBackground: Self {
    Color._withScheme {
      switch $0 {
      case .light: return .white
      case .dark: return Color(0x444444)
      }
    }
  }

  static var sidebarBackground: Self {
    Color._withScheme {
      switch $0 {
      case .light: return Color(0xF2F2F7)
      case .dark: return Color(0x2D2B30)
      }
    }
  }
}
