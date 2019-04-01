//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import SwiftSyntax

//public struct XcodeReporter: CustomStringConvertible {
//    public var description: String
//
//    public static let identifier = "xcode"
//    public static let isRealtime = true
//
//    public static func generateReport(_ path: String) -> String {
//        let fileManager = FileManager.default
//        let currentDirectoryPath = fileManager.currentDirectoryPath
//
//        do {
//            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
//            //            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            let baseurl: URL = URL(fileURLWithPath: currentDirectoryPath)
//            print()
//            print(baseurl)
//            print()
//            let enumerator = FileManager
//                .default
//                .enumerator(at: baseurl,
//                            includingPropertiesForKeys: resourceKeys,
//                            options: [.skipsHiddenFiles],
//                            errorHandler: { (url, error) -> Bool in
//                                print("directoryEnumerator error at \(url): ", error)
//                                return true
//                })!
//
//            for case let fileURL as URL in enumerator {
//                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
//                print(fileURL.path, resourceValues.creationDate!, resourceValues.isDirectory!)
//            }
//        } catch {
//            print(error)
//        }
//        return "\(path):45:42: warning: \(currentDirectoryPath)"
//    }
//}

public final class CommandLineTool {
    private let arguments: [String]

    public init() {
        self.arguments = ["a","b"]
    }

//    public func testFile(_ path: String) {
//        let fileManager = FileManager.default
//        let currentDirectoryPath = fileManager.currentDirectoryPath

//        do {
//            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
//            //            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            let baseurl: URL = URL(fileURLWithPath: path)
//            print()
//            print(baseurl)
//            print()
//            let enumerator = FileManager
//                .default
//                .enumerator(at: baseurl,
//                            includingPropertiesForKeys: resourceKeys,
//                            options: [.skipsHiddenFiles],
//                            errorHandler: { (url, error) -> Bool in
//                                print("directoryEnumerator error at \(url): ", error)
//                                return true
//                })!
//
//            for case let fileURL as URL in enumerator {
//                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
//                print(fileURL.path, resourceValues.creationDate!, resourceValues.isDirectory!)
//            }
//        } catch {
//            print(error)
//        }
//    }

//    public func run() throws {
////        print(CommandLine.arguments)
////        if let filePath = CommandLine.arguments[1] {
////                let file = CommandLine.arguments[1]
////        print(XcodeReporter.generateReport(file))
////        } else {
////
////        }
////        let file = CommandLine.arguments[1]
////        print(file)
////        let url = URL(fileURLWithPath: file)
//
////        let fileURL = "/Users/hmi/Documents/maxDesiatov/Tokamak/"
////        let fileManager = try FileManager.default
//
//////
//////        // Get current directory path
//////
////        let path = fileManager.currentDirectoryPath
////        print(path)
////        let cwd = FileManager.default.currentDirectoryPath
////        print("script run from:\n" + cwd)
//
//    }
}
//
//let tool = CommandLineTool()
//let run = try tool.run()
