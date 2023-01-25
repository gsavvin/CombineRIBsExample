//
//  Catalog2Router.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 25.01.2023.
//

final class Catalog2Router: NavigationRouter<any Catalog2Interactable, any Catalog2ViewControllable, Catalog2Route> {
  private let catalog3Builder: any Catalog3Buildable
  
  init(interactor: any Catalog2Interactable, viewController: any Catalog2ViewControllable, catalog3Builder: any Catalog3Buildable) {
    self.catalog3Builder = catalog3Builder
    
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func prepareTransition(for route: Catalog2Route) -> NavigationTransition {
    switch route {
    case .catalog3: return .push(catalog3Builder.build())
    }
  }
}

// MARK: - Catalog2Routing

extension Catalog2Router: Catalog2Routing {}
