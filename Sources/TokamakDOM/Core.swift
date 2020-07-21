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
//  Created by Jed Fox on 7/18/20.
//

import TokamakCore

// MARK: Environment & State

public typealias Environment = TokamakCore.Environment
public typealias EnvironmentObject = TokamakCore.EnvironmentObject

public typealias Binding = TokamakCore.Binding
public typealias ObservableObject = TokamakCore.ObservableObject
public typealias ObservedObject = TokamakCore.ObservedObject
public typealias Published = TokamakCore.Published
public typealias State = TokamakCore.State

// MARK: Modifiers & Styles

public typealias ViewModifier = TokamakCore.ViewModifier
public typealias ModifiedContent = TokamakCore.ModifiedContent

public typealias DefaultTextFieldStyle = TokamakCore.DefaultTextFieldStyle
public typealias PlainTextFieldStyle = TokamakCore.PlainTextFieldStyle
public typealias RoundedBorderTextFieldStyle = TokamakCore.RoundedBorderTextFieldStyle
public typealias SquareBorderTextFieldStyle = TokamakCore.SquareBorderTextFieldStyle

public typealias DefaultListStyle = TokamakCore.DefaultListStyle
public typealias PlainListStyle = TokamakCore.PlainListStyle
public typealias InsetListStyle = TokamakCore.InsetListStyle
public typealias GroupedListStyle = TokamakCore.GroupedListStyle
public typealias InsetGroupedListStyle = TokamakCore.InsetGroupedListStyle

public typealias DefaultPickerStyle = TokamakCore.DefaultPickerStyle
public typealias PopUpButtonPickerStyle = TokamakCore.PopUpButtonPickerStyle
public typealias RadioGroupPickerStyle = TokamakCore.RadioGroupPickerStyle
public typealias SegmentedPickerStyle = TokamakCore.SegmentedPickerStyle
public typealias WheelPickerStyle = TokamakCore.WheelPickerStyle

// MARK: Shapes

public typealias Shape = TokamakCore.Shape

public typealias Capsule = TokamakCore.Capsule
public typealias Circle = TokamakCore.Circle
public typealias Ellipse = TokamakCore.Ellipse
public typealias Path = TokamakCore.Path
public typealias Rectangle = TokamakCore.Rectangle
public typealias RoundedRectangle = TokamakCore.RoundedRectangle

// MARK: Primitive values

public typealias Color = TokamakCore.Color
public typealias Font = TokamakCore.Font

public typealias CGAffineTransform = TokamakCore.CGAffineTransform
public typealias CGPoint = TokamakCore.CGPoint
public typealias CGRect = TokamakCore.CGRect
public typealias CGSize = TokamakCore.CGSize

// MARK: Views

public typealias Button = TokamakCore.Button
public typealias DisclosureGroup = TokamakCore.DisclosureGroup
public typealias Divider = TokamakCore.Divider
public typealias ForEach = TokamakCore.ForEach
public typealias GridItem = TokamakCore.GridItem
public typealias Group = TokamakCore.Group
public typealias HStack = TokamakCore.HStack
public typealias LazyHGrid = TokamakCore.LazyHGrid
public typealias LazyVGrid = TokamakCore.LazyVGrid
public typealias List = TokamakCore.List
public typealias OutlineGroup = TokamakCore.OutlineGroup
public typealias Picker = TokamakCore.Picker
public typealias ScrollView = TokamakCore.ScrollView
public typealias Section = TokamakCore.Section
public typealias SecureField = TokamakCore.SecureField
public typealias Spacer = TokamakCore.Spacer
public typealias Text = TokamakCore.Text
public typealias TextField = TokamakCore.TextField
public typealias Toggle = TokamakCore.Toggle
public typealias VStack = TokamakCore.VStack
public typealias ZStack = TokamakCore.ZStack

// MARK: Special Views

public typealias View = TokamakCore.View
public typealias AnyView = TokamakCore.AnyView
public typealias EmptyView = TokamakCore.EmptyView

// MARK: Misc

// FIXME: I would put this inside TokamakCore, but for
// some reason it doesn't get exported with the typealias
extension Text {
  public static func + (lhs: Self, rhs: Self) -> Self {
    _concatenating(lhs: lhs, rhs: rhs)
  }
}
