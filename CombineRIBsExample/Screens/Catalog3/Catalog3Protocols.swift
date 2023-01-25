//
//  Catalog3Protocols.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//

import Combine

// MARK: - Builder

protocol Catalog3Buildable: Buildable {
  /// Каталог 3-го уровня
  func build() -> any Catalog3Routing
}

// MARK: - Router

protocol Catalog3ViewControllable: ViewControllable {}

protocol Catalog3Interactable: Interactable {
  var router: Catalog3Routing? { get set }
}

// MARK: - Interactor

protocol Catalog3Routing: NavigationRouting {
  func trigger(_ route: Catalog3Route)
}

enum Catalog3Route: RouteProtocol {
  
}

protocol Catalog3Presentable: Presentable {}

// MARK: - Outputs

enum Catalog3InteractorState {
  case isLoading
  case dataLoaded([String])
  case loadingError
  case nextPageLoading
  case nextPageLoadingError
  case nextPageDataLoaded([String])
}

struct Catalog3InteractorOutput {
  let state: AnyPublisher<Catalog3InteractorState, Never>
}

struct Catalog3PresenterOutput {
  let isLoadingIndicatorVisible: AnyDriver<Bool>
  let viewModel: AnyDriver<[String]>
}

protocol Catalog3ViewOutput {
  var retryButtonTap: AnyDriver<Void> { get }
  var viewDidDissappear: AnyDriver<Void> { get }
}
