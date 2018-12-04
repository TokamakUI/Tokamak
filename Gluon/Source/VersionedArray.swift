//
//  VersionedCollection.swift
//  Gluon
//
//  Created by Max Desiatov on 04/12/2018.
//

struct ArrayVersion: Equatable {
  private let uniqueReference: UniqueReference

  init() {
    uniqueReference = UniqueReference()
  }
}

enum ArrayChange<T> {
  case insert(T, Int)
  case update(T, Int)
  case remove(Int)
  case batchInsert([T], Int)
  case batchUpdate([T], Range<Int>)
  case batchRemove(Range<Int>)
}

struct ArrayChanges {

}

struct VersionedArray<T> {
  let startIndex = 0

  var endIndex: Int {
    return storage.count
  }

  private(set) var currentVersion: ArrayVersion
  private var storage: [T]

  subscript(_ index: Int) -> T {
    return storage[index]
  }

  func index(after i: Int) -> Int {
    return storage.index(after: i)
  }

  init(_ array: [T] = []) {
    storage = array
    currentVersion = ArrayVersion()
  }

  func changes(since: ArrayVersion) -> ArrayChanges? {
    return nil
  }

  mutating func apply(_ changes: ArrayChanges) {

  }

  mutating func flush(_ version: ArrayVersion) {

  }

  mutating func flushAllVersions() {
  }
}
