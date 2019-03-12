//
//  AppDelegate.swift
//  TokamakDemoMac
//
//  Created by Max Desiatov on 09/03/2019.
//  Copyright © 2019 Tokamak. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Cocoa
import Tokamak
import TokamakAppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet var window: NSWindow!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    window.contentViewController = ViewController()
    window.makeKeyAndOrderFront(self)
    window.setFrameOrigin(CGPoint(x: 100, y: 1000))
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
}
