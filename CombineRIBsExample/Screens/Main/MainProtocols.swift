//
//  MainProtocols.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import Combine
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

protocol MainRouting: ViewableRouting {
//  func trigger(_ route: MainRoute)
}

protocol MainPresentable: Presentable {}

// MARK: - Outputs

enum MainInteractorState {
  case isLoading
  case dataLoaded(MainScreenData)
  case loadingError
}

struct MainInteractorOutput {
  let state: AnyPublisher<MainInteractorState, Never>
}

struct MainPresenterOutput {
  let viewModel: AnyDriver<MainScreenData>
  let isLoadingIndicatorVisible: AnyDriver<Bool>
}

protocol MainViewOutput {
  var bannerTap: AnyDriver<Void> { get }
  var categoryTap: AnyDriver<Void> { get }
}

struct MainScreenData {
  let title = "MainScreenData"
}
