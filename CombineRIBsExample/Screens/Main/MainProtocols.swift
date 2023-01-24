//
//  MainProtocols.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import UIKit

// MARK: - Builder

protocol MainBuildable: Buildable {
  func build() -> MainRouting
}

// MARK: - Router

protocol MainViewControllable: ViewControllable {}

protocol MainInteractable: Interactable {
  var router: MainRouting? { get set }
}

// MARK: - Interactor

protocol MainRouting: NavigationRouting {
  func trigger(_ route: MainRoute)
}

enum MainRoute: RouteProtocol {}

protocol MainPresentable: Presentable {}
