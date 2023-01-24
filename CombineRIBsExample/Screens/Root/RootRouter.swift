//
//  RootRouter.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import UIKit

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable, RootRoute> {
  private let mainNavigationBuilder: any MainNavigationBuildable
  
  init(interactor: any RootInteractable,
       viewController: any RootViewControllable,
       mainBuilder: any MainNavigationBuildable) {
    self.mainNavigationBuilder = mainBuilder
    
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func didLoad() {
    super.didLoad()
    
    trigger(.main)
  }
  
  override func prepareTransition(for route: RootRoute) -> LaunchTransition {
    switch route {
    case .main: return .setAsRoot(mainNavigationBuilder.build())
    }
  }
}

// MARK: - RootRouting

extension RootRouter: RootRouting {}
