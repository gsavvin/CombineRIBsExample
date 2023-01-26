//
//  Catalog2Interactor.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 25.01.2023.
//

import Combine

final class Catalog2Interactor: Interactor, Catalog2Interactable {
  // MARK: Dependencies
  
  weak var router: Catalog2Routing?
  
  private let categories: [CatalogCategory]

  // MARK: Internal Usage
  
  private var cancelBag = CancelBag()
  
  init(categories: [CatalogCategory]) {
    self.categories = categories
    
    super.init()
  }
}

// MARK: - IOTransformer

extension Catalog2Interactor: IOTransformer {
  func transform(input viewOutput: any Catalog2ViewOutput) -> Catalog2InteractorOutput {
    cancelBag.collect {
      viewOutput.categoryTap.sink { [weak self] in
        self?.router?.trigger(.catalog3)
      }
      
      // Нужно реализовать на Combine события жизненного цикла View controller и детачить роутер не придётся,
      // это будет делаться в дефолтной реализации автоматически
      // (сейчас не реализовали в силу ограниченного времени)
      viewOutput.viewDidDissappear.sink { [weak self] in
        self?.router?.detach()
      }
    }

    return Catalog2InteractorOutput(categories: categories)
  }
}
