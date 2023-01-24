//
//  MainRouter.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

final class MainRouter: NavigationRouter<MainInteractable, MainViewControllable, MainRoute> {
  private let catalog3Builder: any Catalog3Buildable
  
  init(interactor: any MainInteractable, viewController: any MainViewControllable, catalog3Builder: any Catalog3Buildable) {
    self.catalog3Builder = catalog3Builder
    
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func prepareTransition(for route: MainRoute) -> NavigationTransition {
    switch route {
    case .catalog3(let id): return .push(catalog3Builder.build())
    }
  }
}

// MARK: - MainRouting


extension MainRouter: MainRouting {}
