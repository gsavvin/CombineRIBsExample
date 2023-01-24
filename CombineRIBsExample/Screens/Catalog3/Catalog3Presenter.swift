//
//  Catalog3Presenter.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//

import Combine

final class Catalog3Presenter: Catalog3Presentable {}

// MARK: - IOTransformer

extension Catalog3Presenter: IOTransformer {
  func transform(input: Catalog3InteractorOutput) -> Catalog3PresenterOutput {
    let isLoadingIndicatorVisible = input.state.map { state -> Bool in
      guard case .isLoading = state else { return false }
      return true
    }
    
    let viewModel = input.state.map { state -> [String] in
      guard case .dataLoaded(let items) = state else { return [] }
      return items
    }
    
    return Catalog3PresenterOutput(isLoadingIndicatorVisible: isLoadingIndicatorVisible.eraseToAnyPublisher(),
                                   showNetworkError: Empty(completeImmediately: false).eraseToAnyPublisher(),
                                   viewModel: viewModel.eraseToAnyPublisher())
  }
}
