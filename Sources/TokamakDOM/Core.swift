// Copyright 2020-2021 Tokamak contributors
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

public typealias DynamicProperty = TokamakCore.DynamicProperty

public typealias Environment = TokamakCore.Environment
public typealias EnvironmentKey = TokamakCore.EnvironmentKey
public typealias EnvironmentObject = TokamakCore.EnvironmentObject
public typealias EnvironmentValues = TokamakCore.EnvironmentValues

public typealias PreferenceKey = TokamakCore.PreferenceKey

public typealias Binding = TokamakCore.Binding
public typealias ObservableObject = TokamakCore.ObservableObject
public typealias ObservedObject = TokamakCore.ObservedObject
public typealias Published = TokamakCore.Published
public typealias State = TokamakCore.State
public typealias StateObject = TokamakCore.StateObject

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
public typealias SidebarListStyle = TokamakCore.SidebarListStyle

public typealias DefaultPickerStyle = TokamakCore.DefaultPickerStyle
public typealias PopUpButtonPickerStyle = TokamakCore.PopUpButtonPickerStyle
public typealias RadioGroupPickerStyle = TokamakCore.RadioGroupPickerStyle
public typealias SegmentedPickerStyle = TokamakCore.SegmentedPickerStyle
public typealias WheelPickerStyle = TokamakCore.WheelPickerStyle

public typealias ToggleStyle = TokamakCore.ToggleStyle
public typealias ToggleStyleConfiguration = TokamakCore.ToggleStyleConfiguration

public typealias ButtonStyle = TokamakCore.ButtonStyle
public typealias ButtonStyleConfiguration = TokamakCore.ButtonStyleConfiguration
public typealias DefaultButtonStyle = TokamakCore.DefaultButtonStyle
public typealias PlainButtonStyle = TokamakCore.PlainButtonStyle
public typealias BorderedButtonStyle = TokamakCore.BorderedButtonStyle
public typealias BorderedProminentButtonStyle = TokamakCore.BorderedProminentButtonStyle
public typealias BorderlessButtonStyle = TokamakCore.BorderlessButtonStyle
public typealias LinkButtonStyle = TokamakCore.LinkButtonStyle

public typealias ControlGroupStyle = TokamakCore.ControlGroupStyle
public typealias AutomaticControlGroupStyle = TokamakCore.AutomaticControlGroupStyle
public typealias NavigationControlGroupStyle = TokamakCore.NavigationControlGroupStyle

public typealias TextFieldStyle = TokamakCore.TextFieldStyle

public typealias FillStyle = TokamakCore.FillStyle
public typealias ShapeStyle = TokamakCore.ShapeStyle
public typealias StrokeStyle = TokamakCore.StrokeStyle

public typealias ColorScheme = TokamakCore.ColorScheme

// MARK: Shapes

public typealias Shape = TokamakCore.Shape

public typealias Capsule = TokamakCore.Capsule
public typealias Circle = TokamakCore.Circle
public typealias Ellipse = TokamakCore.Ellipse
public typealias Path = TokamakCore.Path
public typealias Rectangle = TokamakCore.Rectangle
public typealias RoundedRectangle = TokamakCore.RoundedRectangle
public typealias ContainerRelativeShape = TokamakCore.ContainerRelativeShape

// MARK: Shape Styles

public typealias HierarchicalShapeStyle = TokamakCore.HierarchicalShapeStyle

public typealias ForegroundStyle = TokamakCore.ForegroundStyle
public typealias BackgroundStyle = TokamakCore.BackgroundStyle

public typealias Material = TokamakCore.Material

public typealias Gradient = TokamakCore.Gradient
public typealias LinearGradient = TokamakCore.LinearGradient
public typealias RadialGradient = TokamakCore.RadialGradient
public typealias EllipticalGradient = TokamakCore.EllipticalGradient
public typealias AngularGradient = TokamakCore.AngularGradient

// MARK: Primitive values

public typealias Color = TokamakCore.Color
public typealias Font = TokamakCore.Font

#if !canImport(CoreGraphics)
public typealias CGAffineTransform = TokamakCore.CGAffineTransform
#endif

public typealias Angle = TokamakCore.Angle
public typealias Axis = TokamakCore.Axis
public typealias UnitPoint = TokamakCore.UnitPoint

public typealias Edge = TokamakCore.Edge

public typealias Prominence = TokamakCore.Prominence

public typealias GraphicsContext = TokamakCore.GraphicsContext

public typealias TimelineSchedule = TokamakCore.TimelineSchedule
public typealias TimelineScheduleMode = TokamakCore.TimelineScheduleMode
public typealias AnimationTimelineSchedule = TokamakCore.AnimationTimelineSchedule
public typealias EveryMinuteTimelineSchedule = TokamakCore.EveryMinuteTimelineSchedule
public typealias ExplicitTimelineSchedule = TokamakCore.ExplicitTimelineSchedule
public typealias PeriodicTimelineSchedule = TokamakCore.PeriodicTimelineSchedule

public typealias HorizontalAlignment = TokamakCore.HorizontalAlignment
public typealias VerticalAlignment = TokamakCore.VerticalAlignment

// MARK: Views

public typealias Alignment = TokamakCore.Alignment
public typealias Button = TokamakCore.Button
public typealias Canvas = TokamakCore.Canvas
public typealias ControlGroup = TokamakCore.ControlGroup
public typealias ControlSize = TokamakCore.ControlSize
public typealias DatePicker = TokamakCore.DatePicker
public typealias DisclosureGroup = TokamakCore.DisclosureGroup
public typealias Divider = TokamakCore.Divider
public typealias ForEach = TokamakCore.ForEach
public typealias GeometryReader = TokamakCore.GeometryReader
public typealias GridItem = TokamakCore.GridItem
public typealias Group = TokamakCore.Group
public typealias HStack = TokamakCore.HStack
public typealias Image = TokamakCore.Image
public typealias LazyHGrid = TokamakCore.LazyHGrid
public typealias LazyVGrid = TokamakCore.LazyVGrid
public typealias Link = TokamakCore.Link
public typealias List = TokamakCore.List
public typealias NavigationLink = TokamakCore.NavigationLink
public typealias NavigationView = TokamakCore.NavigationView
public typealias OutlineGroup = TokamakCore.OutlineGroup
public typealias Picker = TokamakCore.Picker
public typealias ProgressView = TokamakCore.ProgressView
public typealias ScrollView = TokamakCore.ScrollView
public typealias Section = TokamakCore.Section
public typealias SecureField = TokamakCore.SecureField
public typealias Slider = TokamakCore.Slider
public typealias Spacer = TokamakCore.Spacer
public typealias Text = TokamakCore.Text
public typealias TextEditor = TokamakCore.TextEditor
public typealias TextField = TokamakCore.TextField
public typealias TimelineView = TokamakCore.TimelineView
public typealias Toggle = TokamakCore.Toggle
public typealias VStack = TokamakCore.VStack
public typealias ZStack = TokamakCore.ZStack

// MARK: Special Views

public typealias View = TokamakCore.View
public typealias AnyView = TokamakCore.AnyView
public typealias EmptyView = TokamakCore.EmptyView

// MARK: Layout

public typealias Layout = TokamakCore.Layout
public typealias AnyLayout = TokamakCore.AnyLayout
public typealias LayoutProperties = TokamakCore.LayoutProperties
public typealias LayoutSubviews = TokamakCore.LayoutSubviews
public typealias LayoutSubview = TokamakCore.LayoutSubview
public typealias LayoutValueKey = TokamakCore.LayoutValueKey
public typealias ProposedViewSize = TokamakCore.ProposedViewSize
public typealias ViewSpacing = TokamakCore.ViewSpacing

// MARK: Toolbars

public typealias ToolbarItem = TokamakCore.ToolbarItem
public typealias ToolbarItemGroup = TokamakCore.ToolbarItemGroup
public typealias ToolbarItemPlacement = TokamakCore.ToolbarItemPlacement
public typealias ToolbarContentBuilder = TokamakCore.ToolbarContentBuilder

// MARK: Text

public typealias TextAlignment = TokamakCore.TextAlignment

// MARK: App & Scene

public typealias App = TokamakCore.App
public typealias _AppConfiguration = TokamakCore._AppConfiguration
public typealias Scene = TokamakCore.Scene
public typealias WindowGroup = TokamakCore.WindowGroup
public typealias ScenePhase = TokamakCore.ScenePhase
public typealias AppStorage = TokamakCore.AppStorage
public typealias SceneStorage = TokamakCore.SceneStorage

// MARK: Misc

public typealias ViewBuilder = TokamakCore.ViewBuilder

// MARK: Animation

public typealias Animation = TokamakCore.Animation
public typealias Transaction = TokamakCore.Transaction

public typealias Animatable = TokamakCore.Animatable
public typealias AnimatablePair = TokamakCore.AnimatablePair
public typealias EmptyAnimatableData = TokamakCore.EmptyAnimatableData

public typealias AnimatableModifier = TokamakCore.AnimatableModifier

public typealias AnyTransition = TokamakCore.AnyTransition

public func withTransaction<Result>(
  _ transaction: Transaction,
  _ body: () throws -> Result
) rethrows -> Result {
  try TokamakCore.withTransaction(transaction, body)
}

public func withAnimation<Result>(
  _ animation: Animation? = .default,
  _ body: () throws -> Result
) rethrows -> Result {
  try TokamakCore.withAnimation(animation, body)
}

// FIXME: I would put this inside TokamakCore, but for
// some reason it doesn't get exported with the typealias
public extension Text {
  static func + (lhs: Self, rhs: Self) -> Self {
    _concatenating(lhs: lhs, rhs: rhs)
  }
}

public typealias PreviewProvider = TokamakCore.PreviewProvider
