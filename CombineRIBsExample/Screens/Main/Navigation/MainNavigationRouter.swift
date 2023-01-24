//
//  MainNavigationRouter.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import UIKit

final class MainNavigationRouter: ViewableRouter<MainNavigationInteractable, MainNavigationViewControllable> {
  private let mainBuilder: any MainBuildable
  
  init(interactor: any MainNavigationInteractable,
       viewController: any MainNavigationViewControllable,
       mainBuilder: any MainBuildable) {
    self.mainBuilder = mainBuilder
    
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func didLoad() {
    super.didLoad()
    
    routeToMain()
  }
  
  private func routeToMain() {
    let mainRouter = mainBuilder.build()
    attachChild(mainRouter)
    
    let mainVC = mainRouter.viewControllable.uiviewController
    
    if let navVC = self.viewController.uiviewController as? UINavigationController {
      navVC.pushViewController(mainVC, animated: false)
    }
  }
}

// MARK: - MainNavigationRouting

extension MainNavigationRouter: MainNavigationRouting {}
