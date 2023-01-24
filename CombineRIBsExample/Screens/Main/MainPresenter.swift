//
//  MainPresenter.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

final class MainPresenter: MainPresentable {}

// MARK: - IOTransformer

extension MainPresenter: IOTransformer {
  func transform(input: MainInteractorOutput) -> MainPresenterOutput {
    let viewModel = input.state.compactMap { state -> MainScreenData? in
      switch state {
      case .dataLoaded(let data): return data
      case .isLoading, .loadingError: return nil
      }
    }
    
    let isLoadingIndicatorVisible = input.state.map { state in
      guard case .isLoading = state else { return false }
      return true
    }
    
    return MainPresenterOutput(viewModel: viewModel.eraseToAnyPublisher(),
                               isLoadingIndicatorVisible: isLoadingIndicatorVisible.eraseToAnyPublisher())
  }
}
