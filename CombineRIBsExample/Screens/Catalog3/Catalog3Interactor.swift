//
//  Catalog3Interactor.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//

import Combine
import Foundation

final class Catalog3Interactor: PresentableInteractor<any Catalog3Presentable>, Catalog3Interactable {
  // MARK: Dependencies
  
  weak var router: Catalog3Routing?

  // MARK: Internal Usage

  private let _state = CurrentValueRelay<Catalog3InteractorState>(.isLoading)
  private let responses = Responses()
  private var cancelBag = CancelBag()

  override func didBecomeActive() {
    super.didBecomeActive()
    loadData()
  }
}

// MARK: - Private methods

extension Catalog3Interactor {
  private func loadData() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      var items: [String] = []
      for item in 0...20 {
        items.append("Продукт № \(item)")
      }
      self?.responses.$dataLoaded.send(items)
    }
  }
  
  private func loadNextData() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
      var items: [String] = []
      for item in 21...40 {
        items.append("Продукт № \(item)")
      }
      self?.responses.$fetchedDataLoaded.send(items)
    }
  }
}

// MARK: - IOTransformer

extension Catalog3Interactor: IOTransformer {
  func transform(input viewOutput: any Catalog3ViewOutput) -> Catalog3InteractorOutput {
    
    viewOutput.viewDidDissappear.sink { [weak self] in
      self?.router?.detach()
    }.store(in: &cancelBag)
    
    StateTransform.transform(_state: _state, viewOutput: viewOutput, responses: responses, cancelBag: &cancelBag)
    
    /*
    StateTransform.transitions {
      // loading => dataLoaded
      // Переход из загрузки данных в данные загружены
      responses.dataLoaded.filteredByState(trait.readOnlyState, filter: StateTransform.isLoadingState)
        .map { items in State.dataLoaded(items) }
      
      // loading => loadingError
      // Переход из загрузки данных в ошибку загрузки
      responses.loadingError.filteredByState(trait.readOnlyState, filter: StateTransform.isLoadingState)
        .map { error in State.loadingError(error) }
      
      // loadingError => loading
      // Переход из ошибки загрузки данных в повторную загрузку
     viewOutput.retryButtonTap.filteredByState(trait.readOnlyState, filter: { $0.isLoadingErrorState })
        .do(afterNext: <#loadData#>)
        .map { State.isLoading }
    }
    .bindToAndDisposedBy(trait: trait)
    */

    return Catalog3InteractorOutput(state: _state.eraseToAnyPublisher())
  }
}

extension Catalog3Interactor {
  private typealias State = Catalog3InteractorState
  
  /// [Диаграмма](<#Link#>)
  private enum StateTransform: StateTransformer {
    private static let isLoadingState: (State) -> Bool = { state in
      guard case .isLoading = state else { return false } ; return true
    }
    
    private static let dataLoadedState: (State) -> Bool = { state in
      guard case .dataLoaded = state else { return false } ; return true
    }
    
    private static let loadingErrorState: (State) -> Bool = { state in
      guard case .loadingError = state else { return false } ; return true
    }
    
    static func transform(_state: CurrentValueRelay<Catalog3InteractorState>,
                          viewOutput: any Catalog3ViewOutput,
                          responses: Responses,
                          cancelBag: inout CancelBag) {
      transitions {
        responses.dataLoaded.map { items in State.dataLoaded(items) }.eraseToAnyPublisher()
      }
      .sink { state in
        _state.send(state)
      }
      .store(in: &cancelBag)
    }
  }
}

// MARK: - Nested Types

extension Catalog3Interactor {
  private struct Responses {
    @SendablePublisher var dataLoaded: AnyPublisher<[String], Never>
    @SendablePublisher var fetchedDataLoaded: AnyPublisher<[String], Never>
    @SendablePublisher var loadingError: AnyPublisher<Void, Never>
  }
}
