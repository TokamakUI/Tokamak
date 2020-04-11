//
//  Created by Max Desiatov on 11/04/2020.
//

import Tokamak

public struct HTML<Content>: View where Content: View {
  let tag: String
  let attributes: [String: String]
  let content: Content

  public init(
    tag: String,
    attributes: [String: String] = [:],
    @ViewBuilder content: () -> Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.content = content()
  }
}

public struct EmptyHTML: View {
  let tag: String
  let attributes: [String: String]

  public init(
    tag: String,
    attributes: [String: String] = [:]
  ) {
    self.tag = tag
    self.attributes = attributes
  }
}
