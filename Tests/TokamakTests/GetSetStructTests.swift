// MIT License
//
// Copyright (c) 2017-2021 Wesley Wickwire and Tokamak contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@testable import TokamakCore
import XCTest

class GetSetStructTests: XCTestCase {
  // swiftlint:disable force_cast
  func testGet() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let firstname = try XCTUnwrap(info.property(named: "firstname"))
    let person = Person()
    let name = try XCTUnwrap(firstname.get(from: person) as? String)
    XCTAssert(name == "Wes")
  }

  func testGetSimple() throws {
    struct Test { let a: Int = 2 }
    let info = try XCTUnwrap(typeInfo(of: Test.self))
    let a = try XCTUnwrap(info.property(named: "a"))
    let value = Test()
    let result = try XCTUnwrap(a.get(from: value) as? Int)
    XCTAssert(result == 2)
  }

  func testGetUntypedValue() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let firstname = try XCTUnwrap(info.property(named: "firstname"))
    let person = Person()
    let name: Any = firstname.get(from: person)
    XCTAssert((name as! String) == "Wes")
  }

  func testGetUntypedObject() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let firstname = try XCTUnwrap(info.property(named: "firstname"))
    let person: Any = Person()
    let name = try XCTUnwrap(firstname.get(from: person) as? String)
    XCTAssert(name == "Wes")
  }

  func testGetUntyped() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let firstname = try XCTUnwrap(info.property(named: "firstname"))
    let person: Any = Person()
    let name: Any = firstname.get(from: person)
    XCTAssert((name as! String) == "Wes")
  }

  func testGetStruct() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let pet = try XCTUnwrap(info.property(named: "pet"))
    let person = Person()
    let value = try XCTUnwrap(pet.get(from: person) as? Pet)
    XCTAssert(value.name == "Marley")
  }

  func testGetStructUntypedValue() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let pet = try XCTUnwrap(info.property(named: "pet"))
    let person = Person()
    let value: Any = pet.get(from: person)
    XCTAssert((value as! Pet).name == "Marley")
  }

  func testGetStructUntypedObject() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let pet = try XCTUnwrap(info.property(named: "pet"))
    let person: Any = Person()
    let value = try XCTUnwrap(pet.get(from: person) as? Pet)
    XCTAssert(value.name == "Marley")
  }

  func testGetStructUntyped() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let pet = try XCTUnwrap(info.property(named: "pet"))
    let person: Any = Person()
    let value: Any = pet.get(from: person)
    XCTAssert((value as! Pet).name == "Marley")
  }

  func testGetArray() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let favoriteNumbers = try XCTUnwrap(info.property(named: "favoriteNumbers"))
    let person = Person()
    let value = try XCTUnwrap(favoriteNumbers.get(from: person) as? [Int])
    XCTAssert(value == [1, 2, 3, 4, 5])
  }

  func testGetArrayUntypedValue() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let favoriteNumbers = try XCTUnwrap(info.property(named: "favoriteNumbers"))
    let person = Person()
    let value: Any = favoriteNumbers.get(from: person)
    XCTAssert(value as! [Int] == [1, 2, 3, 4, 5])
  }

  func testGetArrayUntypedObject() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let favoriteNumbers = try XCTUnwrap(info.property(named: "favoriteNumbers"))
    let person: Any = Person()
    let value = try XCTUnwrap(favoriteNumbers.get(from: person) as? [Int])
    XCTAssert(value == [1, 2, 3, 4, 5])
  }

  func testGetArrayUntyped() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let favoriteNumbers = try XCTUnwrap(info.property(named: "favoriteNumbers"))
    let person: Any = Person()
    let value: Any = favoriteNumbers.get(from: person)
    XCTAssert(value as! [Int] == [1, 2, 3, 4, 5])
  }

  func testSet() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let firstname = try XCTUnwrap(info.property(named: "firstname"))
    var person = Person()
    firstname.set(value: "John", on: &person)
    XCTAssert(person.firstname == "John")
  }

  func testSetUntypedValue() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let firstname = try XCTUnwrap(info.property(named: "firstname"))
    var person = Person()
    let new: Any = "John"
    firstname.set(value: new, on: &person)
    XCTAssert(person.firstname == "John")
  }

  func testSetUntypedObject() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let firstname = try XCTUnwrap(info.property(named: "firstname"))
    var person: Any = Person()
    firstname.set(value: "John", on: &person)
    XCTAssert((person as! Person).firstname == "John")
  }

  func testSetUntyped() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let firstname = try XCTUnwrap(info.property(named: "firstname"))
    var person: Any = Person()
    let new: Any = "John"
    firstname.set(value: new, on: &person)
    XCTAssert((person as! Person).firstname == "John")
  }

  func testSetArray() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let favoriteNumbers = try XCTUnwrap(info.property(named: "favoriteNumbers"))
    var person = Person()
    let new = [5, 4, 3, 2, 1]
    favoriteNumbers.set(value: new, on: &person)
    XCTAssert(person.favoriteNumbers == [5, 4, 3, 2, 1])
  }

  func testSetArrayUntypedValue() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let favoriteNumbers = try XCTUnwrap(info.property(named: "favoriteNumbers"))
    var person = Person()
    let new = [5, 4, 3, 2, 1]
    favoriteNumbers.set(value: new, on: &person)
    XCTAssert(person.favoriteNumbers == [5, 4, 3, 2, 1])
  }

  func testSetArrayUntypedObject() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let favoriteNumbers = try XCTUnwrap(info.property(named: "favoriteNumbers"))
    var person: Any = Person()
    let new = [5, 4, 3, 2, 1]
    favoriteNumbers.set(value: new, on: &person)
    XCTAssert((person as! Person).favoriteNumbers == [5, 4, 3, 2, 1])
  }

  func testSetArrayUntyped() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let favoriteNumbers = try XCTUnwrap(info.property(named: "favoriteNumbers"))
    var person: Any = Person()
    let new = [5, 4, 3, 2, 1]
    favoriteNumbers.set(value: new, on: &person)
    XCTAssert((person as! Person).favoriteNumbers == [5, 4, 3, 2, 1])
  }

  func testSetStruct() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let pet = try XCTUnwrap(info.property(named: "pet"))
    var person = Person()
    let new = Pet(name: "Rex", age: 9)
    pet.set(value: new, on: &person)
    XCTAssert(person.pet.name == "Rex")
  }

  func testSetStructUntypedValue() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let pet = try XCTUnwrap(info.property(named: "pet"))
    var person = Person()
    let new = Pet(name: "Rex", age: 9)
    pet.set(value: new, on: &person)
    XCTAssert(person.pet.name == "Rex")
  }

  func testSetStructUntypedObject() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let pet = try XCTUnwrap(info.property(named: "pet"))
    var person: Any = Person()
    let new = Pet(name: "Rex", age: 9)
    pet.set(value: new, on: &person)
    XCTAssert((person as! Person).pet.name == "Rex")
  }

  func testSetStructUntyped() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let pet = try XCTUnwrap(info.property(named: "pet"))
    var person: Any = Person()
    let new = Pet(name: "Rex", age: 9)
    pet.set(value: new, on: &person)
    XCTAssert((person as! Person).pet.name == "Rex")
  }

  func testSetCastingFailure() throws {
    let info = try XCTUnwrap(typeInfo(of: Person.self))
    let age = try XCTUnwrap(XCTUnwrap(info.property(named: "age")))
    var person = Person()
    let newValue = "this will not work"
    age.set(value: newValue, on: &person)
    XCTAssert(person.age == 25)
  }

  // swiftlint:enable force_cast
}

private struct Person {
  var firstname = "Wes"
  var lastname = "Wickwire"
  var age = 25
  var pet = Pet()
  var favoriteNumbers = [1, 2, 3, 4, 5]
}

private struct Pet {
  var name = "Marley"
  var age = 12
  init() {}
  init(name: String, age: Int) {
    self.name = name
    self.age = age
  }
}

// swiftlint:enable type_body_length
