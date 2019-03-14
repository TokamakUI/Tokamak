//
//  CollectionView.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/6/19.
//

public struct CollectionView<T: CellProvider>: HostComponent {
  public struct Props: Equatable, StyleProps {
    public let cellProps: T.Props
    public let sections: T.Sections
    public let onSelect: Handler<CellPath>?
    public let style: Style?

    public init(
      _ style: Style? = nil,
      cellProps: T.Props,
      onSelect: Handler<CellPath>? = nil,
      singleSection: T.Sections.Element
    ) {
      self.cellProps = cellProps
      sections = T.Sections.single(section: singleSection)
      self.onSelect = onSelect
      self.style = style
    }

    public init(
      _ style: Style? = nil,
      cellProps: T.Props,
      sections: T.Sections,
      onSelect: Handler<CellPath>? = nil
    ) {
      self.cellProps = cellProps
      self.sections = sections
      self.onSelect = onSelect
      self.style = style
    }
  }

  public typealias Children = Null
}

extension CollectionView.Props where T.Props == Null {
  public init(
    _ style: Style? = nil,
    sections: T.Sections,
    onSelect: Handler<CellPath>? = nil
  ) {
    cellProps = Null()
    self.sections = sections
    self.onSelect = onSelect
    self.style = style
  }

  public init(
    _ style: Style? = nil,
    onSelect: Handler<CellPath>? = nil,
    singleSection: T.Sections.Element
  ) {
    cellProps = Null()
    sections = T.Sections.single(section: singleSection)
    self.onSelect = onSelect
    self.style = style
  }
}
