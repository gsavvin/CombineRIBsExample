//
//  RootBuilder.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

final class RootBuilder: Builder<EmptyDependency>, RootBuildable {
  func build() -> RootRouting {
    let viewController = RootViewController()
    let interactor = RootInteractor()
    let router = RootRouter(interactor: interactor, viewController: viewController)

    interactor.router = router

    return router
  }
}
