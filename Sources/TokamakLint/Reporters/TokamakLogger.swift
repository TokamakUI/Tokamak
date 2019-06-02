//
//  TokamakLogger.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/30/19.
//

import Foundation
import Logging

public struct Outputs: OptionSet {
  public init(rawValue: Outputs.RawValue) {
    self.rawValue = rawValue
  }

  public let rawValue: Int

  static let stdout = Outputs(rawValue: 1)
  static let file = Outputs(rawValue: 2)
}

public struct TokamakLogger: LogHandler {
  // metadata storage
  public var metadata: Logger.Metadata = [:]

  public init(label: String) {}

  public var outputs = [Outputs.file]

  public var _path: URL?

  public var path: URL {
    get {
      guard let _path = _path else {
        let fm = FileManager.default
        guard let url = fm.urls(
          for: FileManager.SearchPathDirectory.documentDirectory,
          in: FileManager.SearchPathDomainMask.userDomainMask
        )
        .last?.appendingPathComponent("log.txt") else {
          return URL(fileURLWithPath: "")
        }
        return url
      }
      return _path
    }

    set {
      _path = newValue
    }
  }

  public var logLevel: Logger.Level = .info

  public func log(
    level: Logger.Level,
    message: Logger.Message,
    metadata: Logger.Metadata?,
    file: String,
    function: String,
    line: UInt
  ) {
    if outputs.contains(Outputs.stdout) {
      print(message.description)
    }

    if outputs.contains(Outputs.file) {
      write(message.description)
    }
  }

  public func log(level: Logger.Level, message: Logger.Message) {
    log(
      level: level,
      message: message,
      metadata: .none,
      file: "",
      function: "",
      line: 0
    )
  }

  func write(_ string: String) {
    let data = string.data(using: String.Encoding.utf8)
    let fm = FileManager.default
    if !fm.fileExists(atPath: path.absoluteString) {
      fm.createFile(
        atPath: path.absoluteString,
        contents: data, attributes: nil
      )
    } else {
      var file = FileHandle(forReadingAtPath: path.absoluteString)
      _ = String(describing: file?.readDataToEndOfFile())
      file = FileHandle(forWritingAtPath: path.absoluteString)
      if file != nil {
        file?.seek(toFileOffset: 10)
        file?.write(data!)
        file?.closeFile()
      }
    }
  }

  public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
    get {
      return metadata[metadataKey]
    }
    set(newValue) {
      metadata[metadataKey] = newValue
    }
  }
}
