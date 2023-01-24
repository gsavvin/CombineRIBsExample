//
//  MainNavigationBuilder.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

final class MainNavigationBuilder: Builder<EmptyDependency>, MainNavigationBuildable {
  func build() -> MainNavigationRouting {
    let viewController = MainNavigationViewController()
    let interactor = MainNavigationInteractor()
    let router = MainNavigationRouter(interactor: interactor,
                                      viewController: viewController,
                                      mainBuilder: MainBuilder(dependency: EmptyComponent()))

    interactor.router = router

    return router
  }
}
