import TokamakDOM
import Foundation

@main
struct TokamakApp: App {
  static let _configuration: _AppConfiguration = .init(reconciler: .fiber(useDynamicLayout: false))
  var body: some Scene { WindowGroup("Tokamak App") { ContentView() } }
}

enum State {
  case a
  case b([String])
  case c(String, [Int])
  case d(String, [Int], String)
}

final class StateManager: ObservableObject {
  private init() { }
  static let shared = StateManager()

  @Published var state = State.a //b(["eins", "2", "III"])
}

struct ContentView: View {
  @ObservedObject var sm = StateManager.shared

  var body: some View {
    switch sm.state {
    case .a:
      Button("go to b") {
        sm.state = .b(["eins", "zwei", "drei"])
      }
    case .b(let arr):
      VStack {
        Text("b:")
        ForEach(arr, id: \.self) { s in
          Button(s) {
            sm.state = .c(s, s == "zwei" ? [1, 2] : [1])
          }
        }
      }
    case .c(let str, let ints):
      VStack {
        Text("c \(str)")
          .font(.headline)
        Text("hello there")
        ForEach(ints, id: \.self) { i in
          let d = "i = \(i)"
          Button(d) {
            sm.state = .d(str, ints, d)
          }
        }
      }
    case .d(_, let ints, let other):
      VStack {
        Text("d \(other)")
        Text("count \(ints.count)")
        Button("back") {
          sm.state = .a
        }
      }
    }
  }
}
