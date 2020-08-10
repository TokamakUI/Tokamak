import JavaScriptKit
import TokamakDOM

struct Inspector: App {
  @ObservedObject var tree = Tree()

  var body: some Scene {
    WindowGroup("Inspector") {
      ContentView()
        .environmentObject(tree)
    }
  }
}

Inspector.main()
