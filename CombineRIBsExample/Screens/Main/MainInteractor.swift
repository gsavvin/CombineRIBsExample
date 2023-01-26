//
//  MainInteractor.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import Foundation
import Combine

final class MainInteractor: PresentableInteractor<MainPresentable>, MainInteractable {
  // MARK: Dependencies
  
  weak var router: MainRouting?

  // MARK: Private properties
  
  private let _state = CurrentValueRelay<MainInteractorState>(.isLoading)
  private let responses = Responses()
  private var cancelBag = CancelBag()
  
  override func didBecomeActive() {
    super.didBecomeActive()
    
    loadData()
  }
}

// MARK: - Private methods

extension MainInteractor {
  private func loadData() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      self?.responses.$dataLoaded.send(MainScreenData())
    }
  }
}

// MARK: - IOTransformer

extension MainInteractor: IOTransformer {
  func transform(input viewOutput: MainViewOutput) -> MainInteractorOutput {
    let actions = makeActions()
    
    // Если переходов мало то можно и не создавать метод transform(_:), а сразу вызвать StateTransform.transitions { }
    
    StateTransform.transform(_state: _state,
                             viewOutput: viewOutput,
                             actions: actions,
                             responses: responses,
                             cancelBag: &cancelBag)
    
    Self.anyStateRouting(viewOutput: viewOutput, actions: actions, cancelBag: &cancelBag)
    
    return MainInteractorOutput(state: _state.eraseToAnyPublisher())
  }
  
  private static func anyStateRouting(viewOutput: MainViewOutput, actions: Actions, cancelBag: inout CancelBag) {
    cancelBag.collect {
      viewOutput.categoryTap
        .sink { category in
          guard let childCategories = category.childCategories else { return }
          actions.routeTo(.catalog2(childCategories))
        }
      
      viewOutput.bannerTap
        .sink { banner in
          actions.routeTo(.catalog3)
        }
    }
  }
}

extension MainInteractor {
  private typealias State = MainInteractorState
  
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
    
    static func transform(_state: CurrentValueRelay<MainInteractorState>,
                          viewOutput: any MainViewOutput,
                          actions: Actions,
                          responses: Responses,
                          cancelBag: inout CancelBag) {
      let state = _state.eraseToAnyPublisher()
      
      transitions {
        // isLoading => dataLoaded
        responses.dataLoaded
          .filteredByState(state, filter: isLoadingState)
          .map { screenData in State.dataLoaded(screenData) }
          .eraseToAnyPublisher()
        
        // isLoading => loadingError
        responses.loadingError
          .filteredByState(state, filter: isLoadingState)
          .map { State.loadingError }
          .eraseToAnyPublisher()
        
        // Примеры других возможных переходов состояний:
        
//        // dataLoaded => loading
//        viewOutput.pullToRefresh
//          .filteredByState(state, filter: dataLoadedState)
//          .do(onNext: actions.loadData)
//          .map { State.isLoading }
//
//        // loadingError => loading
//        viewOutput.retryButtonTap
//          .filteredByState(state, filter: loadingErrorState)
//          .do(onNext: actions.loadData)
//          .map { State.isLoading }
      }
      .sink { state in
        _state.send(state)
      }
      .store(in: &cancelBag)
    }
  }
}

// MARK: - Nested Types

extension MainInteractor {
  private struct Actions {
    let loadData: () -> Void
    let routeTo: (MainRoute) -> Void
  }
  
  private func makeActions() -> Actions {
    Actions(loadData: { [weak self] in self?.loadData() },
            routeTo: { [weak router] in router?.trigger($0) })
  }
  
  private struct Responses {
    @SendablePublisher var dataLoaded: AnyPublisher<MainScreenData, Never>
    @SendablePublisher var loadingError: AnyPublisher<Void, Never>
  }
}
