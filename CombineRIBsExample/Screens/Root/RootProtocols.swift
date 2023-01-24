//
//  RootProtocols.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import UIKit

// MARK: - Builder

protocol RootBuildable: Buildable {
  func build() -> RootRouting
}

// MARK: - Router

protocol RootViewControllable: ViewControllable {}

protocol RootInteractable: Interactable {
  var router: RootRouting? { get set }
}

// MARK: - Interactor

protocol RootRouting: ViewableRouting {
  func launch(from window: UIWindow)
}

enum RootRoute: RouteProtocol {
  case main
}
