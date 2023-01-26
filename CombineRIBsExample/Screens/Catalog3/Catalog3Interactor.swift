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
    loadNextData()
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
  
  /// Подгрузка данных для следующей страницы при пагинации
  private func loadNextData() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
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
    StateTransform.transform(_state: _state,
                             viewOutput: viewOutput,
                             responses: responses,
                             cancelBag: &cancelBag)
    
    // Нужно реализовать на Combine события жизненного цикла View controller и детачить роутер не придётся,
    // это будет делаться в дефолтной реализации автоматически
    // (сейчас не реализовали в силу ограниченного времени)
    viewOutput.viewDidDissappear.sink { [weak self] in
      self?.router?.detach()
    }.store(in: &cancelBag)

    return Catalog3InteractorOutput(state: _state.eraseToAnyPublisher())
  }
}

extension Catalog3Interactor {
  private typealias State = Catalog3InteractorState
  
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
        // isLoading -> dataLoaded
        responses.dataLoaded
          .filteredByState(_state.eraseToAnyPublisher(), filter: isLoadingState)
          .map { items in State.dataLoaded(items) }
          .eraseToAnyPublisher()
        
        // dataLoaded/nextPageDataLoaded -> nextPageDataLoaded
        responses.fetchedDataLoaded
          .filteredByState(_state.eraseToAnyPublisher()) { state -> [String]? in
          switch state {
          case .nextPageDataLoaded(let items), .dataLoaded(let items): return items
          default: return nil
          }
        }
        .map { newItems, items -> State in
          let totalItems = items + newItems
          return State.nextPageDataLoaded(totalItems)
        }
        .eraseToAnyPublisher()
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
