import Tokamak
import XCTest

final class ColorTests: XCTestCase {
  func testHexColors() {
    guard let color = Color(hex: "#FF00FF") else {
      XCTFail("Hexadecimal decoding failed")
      return
    }
    
    XCTAssertEqual(color.red, 1)
    XCTAssertEqual(color.green, 0)
    XCTAssertEqual(color.blue, 1)
    
    XCTAssertEqual(color, Color(hex: "FF00FF"), "The '#' before a hex code produced a different output than without it")
  }
}
