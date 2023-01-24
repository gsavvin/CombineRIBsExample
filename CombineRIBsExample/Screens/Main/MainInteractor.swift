//
//  MainInteractor.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

final class MainInteractor: PresentableInteractor<MainPresentable>, MainInteractable {
  // MARK: Dependencies
  
  weak var router: MainRouting?

  // MARK: Internal Usage
  
  override func didBecomeActive() {
    super.didBecomeActive()
//    loadData()
  }
}

// MARK: - Private methods

//extension MainInteractor {
//  private func loadData() {
//    <#Implementation#>
//  }
//}
