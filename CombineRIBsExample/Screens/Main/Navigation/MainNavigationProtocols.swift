//
//  MainNavigationProtocols.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

// MARK: - Builder

protocol MainNavigationBuildable: Buildable {
  func build() -> MainNavigationRouting
}

// MARK: - Router

protocol MainNavigationViewControllable: ViewControllable {}

protocol MainNavigationInteractable: Interactable {
  var router: MainNavigationRouting? { get set }
}

// MARK: - Interactor

protocol MainNavigationRouting: ViewableRouting {
  func trigger(_ route: MainNavigationRoute)
}

enum MainNavigationRoute: RouteProtocol {
  case main
}
