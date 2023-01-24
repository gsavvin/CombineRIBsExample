//
//  Catalog3Router.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//

final class Catalog3Router: NavigationRouter<any Catalog3Interactable, any Catalog3ViewControllable, Catalog3Route> {
  override func prepareTransition(for route: Catalog3Route) -> NavigationTransition {}
}

// MARK: - Catalog3Routing

extension Catalog3Router: Catalog3Routing {}
