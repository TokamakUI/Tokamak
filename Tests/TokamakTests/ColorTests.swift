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

    XCTAssertEqual(
      color,
      Color(hex: "FF00FF"),
      "The '#' before a hex code produced a different output than without it"
    )

    guard let red = Color(hex: "#FF0000") else {
      XCTFail("Hexadecimal decoding failed")
      return
    }

    XCTAssertEqual(red.red, 1)
    XCTAssertEqual(red.green, 0)
    XCTAssertEqual(red.blue, 0)

    guard let green = Color(hex: "#00FF00") else {
      XCTFail("Hexadecimal decoding failed")
      return
    }

    XCTAssertEqual(green.red, 0)
    XCTAssertEqual(green.green, 1)
    XCTAssertEqual(green.blue, 0)

    guard let blue = Color(hex: "#0000FF") else {
      XCTFail("Hexadecimal decoding failed")
      return
    }

    XCTAssertEqual(blue.red, 0)
    XCTAssertEqual(blue.green, 0)
    XCTAssertEqual(blue.blue, 1)
  }
}
