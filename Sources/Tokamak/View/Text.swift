//
//  Created by Max Desiatov on 08/04/2020.
//

public struct Text: View {
  // FIXME: should be internal
  public let content: String

  public init(verbatim content: String) {
    self.content = content
  }

  public init<S>(_ content: S) where S: StringProtocol {
    self.content = String(content)
  }
}
