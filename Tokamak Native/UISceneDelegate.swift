//
//  SceneDelegate.swift
//  SwiftWebUI Compat Test
//
//  Created by Jed Fox on 6/27/20.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: TokamakDemoView())
      self.window = window
      window.makeKeyAndVisible()
    }
  }
}
