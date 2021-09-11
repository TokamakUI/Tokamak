import SnapshotTesting

extension Snapshotting where Value == String, Format == String {
  public static let html = Snapshotting(pathExtension: "html", diffing: .lines)
}
