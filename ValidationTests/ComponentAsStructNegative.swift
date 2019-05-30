class BeatlesComponents: CompositeComponent {
  let willThereBeAnAnswer = true
  let itBe = "Whisper words of wisdom"
}

class LedZeppelinLeaf: PureLeafComponent {
  let doIhaveToGo = false
  enum whatMakeMe: String {
    case mad = "the letter you wrote me"
    case sad = "the news that letters told me"
  }
}
