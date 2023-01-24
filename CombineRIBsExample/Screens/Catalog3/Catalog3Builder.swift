//
//  Catalog3Builder.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//


final class Catalog3Builder: Builder<any EmptyDependency>, Catalog3Buildable {
  func build() -> any Catalog3Routing {
    let viewController = Catalog3ViewController()
    let presenter = Catalog3Presenter()
    let interactor = Catalog3Interactor(presenter: presenter)
    let router = Catalog3Router(interactor: interactor, viewController: viewController)

    interactor.router = router
    
    VIPBinder.bind(viewController: viewController, interactor: interactor, presenter: presenter)

    return router
  }
}
