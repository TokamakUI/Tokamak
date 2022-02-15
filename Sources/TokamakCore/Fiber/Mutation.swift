//
//  File.swift
//
//
//  Created by Carson Katri on 2/15/22.
//

public enum Mutation<Renderer: FiberRenderer> {
  case insert(
    element: Renderer.ElementType,
    parent: Renderer.ElementType,
    index: Int
  )
  case remove(element: Renderer.ElementType, parent: Renderer.ElementType?)
  case replace(
    parent: Renderer.ElementType,
    previous: Renderer.ElementType,
    replacement: Renderer.ElementType
  )
  case update(previous: Renderer.ElementType, newData: Renderer.ElementType.Data)
}
