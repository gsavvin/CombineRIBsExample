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
  func transform(input: MainViewOutput) -> MainInteractorOutput {
    let actions = makeActions()
    
    StateTransform.transform(_state: _state,
                             viewOutput: input,
                             actions: actions,
                             responses: responses,
                             cancelBag: &cancelBag)
    
    cancelBag.collect {
          input.categoryTap
            .sink { category in
              guard let childCategories = category.childCategories else { return }
              actions.routeTo(.catalog2(childCategories))
            }
          
          input.bannerTap
            .sink { banner in
              actions.routeTo(.catalog3)
            }
        }
      
      return MainInteractorOutput(state: _state.eraseToAnyPublisher())
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
      transitions {
        responses.dataLoaded
          .map { screenData in State.dataLoaded(screenData) }
          .eraseToAnyPublisher()
        
        responses.loadingError
          .map { State.loadingError }
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
