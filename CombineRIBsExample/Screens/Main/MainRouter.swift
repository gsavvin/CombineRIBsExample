//
//  MainRouter.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

final class MainRouter: NavigationRouter<MainInteractable, MainViewControllable, MainRoute> {
  private let catalog3Builder: any Catalog3Buildable
  private let catalog2Builder: any Catalog2Buildable
  
  init(interactor: any MainInteractable,
       viewController: any MainViewControllable,
       catalog3Builder: any Catalog3Buildable,
       catalog2Builder: any Catalog2Buildable) {
    self.catalog3Builder = catalog3Builder
    self.catalog2Builder = catalog2Builder
    
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func prepareTransition(for route: MainRoute) -> NavigationTransition {
    switch route {
    case .catalog3: return .push(catalog3Builder.build())
    case .catalog2(let categories): return .push(catalog2Builder.build(categories: categories))
    }
  }
}

// MARK: - MainRouting


extension MainRouter: MainRouting {}
