import TokamakShim

struct ShadowDemo: View {
  var body: some View {
    Color.red.frame(width: 60, height: 60, alignment: .center)
      .shadow(color: .black, radius: 5, x: 10, y: 10)
  }
}
