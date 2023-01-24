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
    let router = MainRouter(interactor: interactor,
                            viewController: viewController,
                            catalog3Builder: Catalog3Builder(dependency: dependency))

    interactor.router = router
    
    let vipOutput = VIPBinder.bind(viewController: viewController, interactor: interactor, presenter: presenter)
    
    do {
      /// Нужно доставать из зависимостей.
      /// Сендер, задача которого отправить готовый ивент куда нужно (в нашем случае вероятно лишь наружу из библиотеки)
      let globalSender = StatisticsSenderImp()
      
      let mainStatSender = MainStatSender(sender: globalSender,
                                          viewOutput: vipOutput.viewOutput,
                                          interactorOutput: vipOutput.interactorOutput)
      
      interactor.retainBag.add(object: mainStatSender)
    }

    return router
  }
}
