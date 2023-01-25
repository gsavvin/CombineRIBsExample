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

protocol MainRouting: NavigationRouting {
  func trigger(_ route: MainRoute)
}

enum MainRoute: RouteProtocol {
  case catalog3(Int)
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
  var bannerTap: AnyDriver<Banner> { get }
  var categoryTap: AnyDriver<CatalogCategory> { get }
}

struct MainScreenData {
  let title = "MainScreenData"
  
  let banner = Banner(title: "Готовимся к весне", backgroundColor: .systemPurple)
  
  let categories: [CatalogCategory] = CatalogCategory.stubCategories()
}

struct Banner: Hashable {
  let title: String
  let backgroundColor: UIColor
}

struct CatalogCategory: Hashable {
  let title: String
  let childCategories: [CatalogCategory]?
}

extension CatalogCategory {
  static func stubCategories() -> [CatalogCategory] {
    let categories: [CatalogCategory] = [
      CatalogCategory(title: "Мясо, птица, колбасы", childCategories: nil),
      CatalogCategory(title: "Молоко, сыр", childCategories: nil),
      CatalogCategory(title: "Овощи и фрукты", childCategories: nil),
      CatalogCategory(title: "Сладости, торты", childCategories: nil),
      CatalogCategory(title: "Хлеб и выпечка", childCategories: nil),
      CatalogCategory(title: "Напитки", childCategories: nil),
      CatalogCategory(title: "Орехи, снэки", childCategories: nil),
      CatalogCategory(title: "Десткие товары", childCategories: nil),
    ]
    
    return categories.map { CatalogCategory(title: $0.title, childCategories: categories)}
  }
}
