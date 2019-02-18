//
//  ListView.swift
//  Tokamak
//
//  Created by Max Desiatov on 21/01/2019.
//

public struct CellPath {
  public let section: Int
  public let item: Int

  public init(section: Int, item: Int) {
    self.section = section
    self.item = item
  }
}

/** A collection of sections with random access to its elements and
 an ability to create a new `SectionedModel` with a single section. The most
 basic `SectionedModel` is an array of arrays `[[T]]`, where every element
 in the top level array is a section `[T]` and every element `T` is a row/item
 in this section.
 */
public protocol SectionedModel: RandomAccessCollection
  where Element: RandomAccessCollection, Index == Int, Element.Index == Int {
  static func single(section: Element) -> Self
}

extension Array: SectionedModel
  where Element: RandomAccessCollection, Element.Index == Int {
  public static func single(section: Element) -> [Element] {
    return [section]
  }
}

public protocol CellProvider {
  associatedtype Props: Equatable
  associatedtype Identifier: RawRepresentable
    where Identifier.RawValue == String
  associatedtype Model: SectionedModel & Equatable

  static func cell(
    props: Props,
    item: Model.Element.Element,
    path: CellPath
  ) -> (Identifier, AnyNode)
}

public enum SingleIdentifier: String {
  case single
}

public protocol SimpleCellProvider: CellProvider
  where Identifier == SingleIdentifier {
  static func cell(
    props: Props,
    item: Model.Element.Element,
    path: CellPath
  ) -> AnyNode
}

extension SimpleCellProvider {
  public static func cell(
    props: Props,
    item: Model.Element.Element,
    path: CellPath
  ) -> (Identifier, AnyNode) {
    return (.single, cell(props: props, item: item, path: path))
  }
}

public struct ListView<T: CellProvider>: HostComponent {
  public struct Props: Equatable, StyleProps {
    public let cellProps: T.Props
    public let model: T.Model
    public let onSelect: Handler<CellPath>?
    public let style: Style?

    public init(
      cellProps: T.Props,
      onSelect: Handler<CellPath>? = nil,
      singleSection: T.Model.Element,
      _ style: Style? = nil
    ) {
      self.cellProps = cellProps
      model = T.Model.single(section: singleSection)
      self.onSelect = onSelect
      self.style = style
    }

    public init(
      cellProps: T.Props,
      onSelect: Handler<CellPath>? = nil,
      model: T.Model,
      _ style: Style? = nil
    ) {
      self.cellProps = cellProps
      self.model = model
      self.onSelect = onSelect
      self.style = style
    }
  }

  public typealias Children = Null
}

extension ListView.Props where T.Props == Null {
  public init(
    model: T.Model,
    onSelect: Handler<CellPath>? = nil,
    _ style: Style? = nil
  ) {
    cellProps = Null()
    self.model = model
    self.onSelect = onSelect
    self.style = style
  }

  public init(
    onSelect: Handler<CellPath>? = nil,
    singleSection: T.Model.Element,
    _ style: Style? = nil
  ) {
    cellProps = Null()
    model = T.Model.single(section: singleSection)
    self.onSelect = onSelect
    self.style = style
  }
}
