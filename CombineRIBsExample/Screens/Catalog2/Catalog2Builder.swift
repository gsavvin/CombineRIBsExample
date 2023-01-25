//
//  Catalog2Builder.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 25.01.2023.
//

final class Catalog2Builder: Builder<any EmptyDependency>, Catalog2Buildable {
  func build(categories: [CatalogCategory]) -> any Catalog2Routing {
    let viewController = Catalog2ViewController()
    let interactor = Catalog2Interactor(categories: categories)
    let router = Catalog2Router(interactor: interactor,
                                viewController: viewController,
                                catalog3Builder: Catalog3Builder(dependency: dependency))

    interactor.router = router
    
    VIPBinder.bind(view: viewController, interactor: interactor)

    return router
  }
}
