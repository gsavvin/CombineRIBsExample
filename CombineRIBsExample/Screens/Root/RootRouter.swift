//
//  RootRouter.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import UIKit

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable> {
  private let mainNavigationBuilder: any MainNavigationBuildable
  
  init(interactor: any RootInteractable,
       viewController: any RootViewControllable,
       mainBuilder: any MainNavigationBuildable) {
    self.mainNavigationBuilder = mainBuilder
    
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func didLoad() {
    super.didLoad()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      self?.routeToMain()
    }
  }
  
  private func routeToMain() {
    let mainNavigationRouter = mainNavigationBuilder.build()
    attachChild(mainNavigationRouter)
    
    let mainVC = mainNavigationRouter.viewControllable.uiviewController
    mainVC.modalPresentationStyle = .overFullScreen
    self.viewController.uiviewController.present(mainVC, animated: false)
  }
}

// MARK: - RootRouting

extension RootRouter: RootRouting {}
