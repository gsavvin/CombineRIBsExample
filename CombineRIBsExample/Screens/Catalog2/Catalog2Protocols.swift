//
//  Catalog2Protocols.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 25.01.2023.
//

import Combine
import UIKit

// MARK: - Builder

protocol Catalog2Buildable: Buildable {
  /// Каталог второго уровня
  func build(categories: [CatalogCategory]) -> any Catalog2Routing
}

// MARK: - Router

protocol Catalog2ViewControllable: ViewControllable {}

protocol Catalog2Interactable: Interactable {
  var router: Catalog2Routing? { get set }
}

// MARK: - Interactor

protocol Catalog2Routing: NavigationRouting {
  func trigger(_ route: Catalog2Route)
}

enum Catalog2Route: RouteProtocol {
  case catalog3
}

// MARK: - Outputs

struct Catalog2InteractorOutput {
  let categories: [CatalogCategory]
}

protocol Catalog2ViewOutput {
  var viewDidDissappear: AnyDriver<Void> { get }
  var categoryTap: AnyDriver<Void> { get }
}
