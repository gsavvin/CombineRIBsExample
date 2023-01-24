//
//  MainNavigationRouter.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import UIKit

final class MainNavigationRouter: NavigationRouter<MainNavigationInteractable, MainNavigationViewControllable, MainNavigationRoute> {
  private let mainBuilder: any MainBuildable
  
  init(interactor: any MainNavigationInteractable,
       viewController: any MainNavigationViewControllable,
       mainBuilder: any MainBuildable) {
    self.mainBuilder = mainBuilder
    
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func didLoad() {
    super.didLoad()
    
    trigger(.main)
  }
  
  override func prepareTransition(for route: MainNavigationRoute) -> NavigationTransition {
    switch route {
    case .main: return .push(mainBuilder.build())
    }
  }
}

// MARK: - MainNavigationRouting

extension MainNavigationRouter: MainNavigationRouting {}
