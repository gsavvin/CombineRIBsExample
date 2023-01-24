//
//  MainBuilder.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import UIKit

final class MainBuilder: Builder<EmptyDependency>, MainBuildable {
  func build() -> MainRouting {
    let viewController = MainViewController()
    let presenter = MainPresenter()
    let interactor = MainInteractor(presenter: presenter)
    let router = MainRouter(interactor: interactor, viewController: viewController)

    interactor.router = router
    
    VIPBinder.bind(viewController: viewController, interactor: interactor, presenter: presenter)

    return router
  }
}
