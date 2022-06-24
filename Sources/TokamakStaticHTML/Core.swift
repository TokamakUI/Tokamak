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
//  Created by Carson Katri on 7/20/20.
//

import TokamakCore

// MARK: Environment & State

public typealias Environment = TokamakCore.Environment

// MARK: Modifiers & Styles

public typealias ViewModifier = TokamakCore.ViewModifier
public typealias ModifiedContent = TokamakCore.ModifiedContent

public typealias DefaultListStyle = TokamakCore.DefaultListStyle
public typealias PlainListStyle = TokamakCore.PlainListStyle
public typealias InsetListStyle = TokamakCore.InsetListStyle
public typealias GroupedListStyle = TokamakCore.GroupedListStyle
public typealias InsetGroupedListStyle = TokamakCore.InsetGroupedListStyle

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

public typealias Axis = TokamakCore.Axis

public typealias Color = TokamakCore.Color
public typealias Font = TokamakCore.Font

public typealias Alignment = TokamakCore.Alignment
public typealias AlignmentID = TokamakCore.AlignmentID
public typealias HorizontalAlignment = TokamakCore.HorizontalAlignment
public typealias VerticalAlignment = TokamakCore.VerticalAlignment

#if !canImport(CoreGraphics)
public typealias CGAffineTransform = TokamakCore.CGAffineTransform
#endif

// MARK: Views

public typealias Divider = TokamakCore.Divider
public typealias ForEach = TokamakCore.ForEach
public typealias GridItem = TokamakCore.GridItem
public typealias Group = TokamakCore.Group
public typealias HStack = TokamakCore.HStack
public typealias LazyHGrid = TokamakCore.LazyHGrid
public typealias LazyVGrid = TokamakCore.LazyVGrid
public typealias List = TokamakCore.List
public typealias ProgressView = TokamakCore.ProgressView
public typealias ScrollView = TokamakCore.ScrollView
public typealias Section = TokamakCore.Section
public typealias Spacer = TokamakCore.Spacer
public typealias Text = TokamakCore.Text
public typealias VStack = TokamakCore.VStack
public typealias ZStack = TokamakCore.ZStack
public typealias Link = TokamakCore.Link

// MARK: Special Views

public typealias View = TokamakCore.View
public typealias AnyView = TokamakCore.AnyView
public typealias EmptyView = TokamakCore.EmptyView

public typealias Layout = TokamakCore.Layout
public typealias AnyLayout = TokamakCore.AnyLayout

// MARK: Toolbars

public typealias ToolbarItem = TokamakCore.ToolbarItem
public typealias ToolbarItemGroup = TokamakCore.ToolbarItemGroup
public typealias ToolbarItemPlacement = TokamakCore.ToolbarItemPlacement
public typealias ToolbarContentBuilder = TokamakCore.ToolbarContentBuilder

// MARK: App & Scene

public typealias App = TokamakCore.App
public typealias Scene = TokamakCore.Scene
public typealias WindowGroup = TokamakCore.WindowGroup
public typealias ScenePhase = TokamakCore.ScenePhase
public typealias AppStorage = TokamakCore.AppStorage
public typealias SceneStorage = TokamakCore.SceneStorage

// MARK: Misc

public typealias ViewBuilder = TokamakCore.ViewBuilder

// FIXME: I would put this inside TokamakCore, but for
// some reason it doesn't get exported with the typealias
public extension Text {
  static func + (lhs: Self, rhs: Self) -> Self {
    _concatenating(lhs: lhs, rhs: rhs)
  }
}

public typealias PreviewProvider = TokamakCore.PreviewProvider
