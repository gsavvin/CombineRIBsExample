//
//  AppDelegate.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 23.01.2023.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  private var launchRouter: Routing?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    
    let rootRouter = RootBuilder(dependency: EmptyComponent()).build()
    rootRouter.launch(from: window)
    
    launchRouter = rootRouter
    
    return true
  }
}

