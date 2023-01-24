//
//  MainViewController.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import UIKit
import Combine

final class MainViewController: UIViewController, MainViewControllable {
  // MARK: Private properties
  
  private var presenterOutput: MainPresenterOutput?
  private let viewOutput = ViewOutput()
  
  private var cancelBag = CancelBag()
  
  let textlabel = UILabel()
  
  // MARK: Overriden
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initialSetup()
    bindIfNeeded()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    // вызвать у роутера метод detach
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    textlabel.frame = view.bounds
  }
  
  private func initialSetup() {
    view.backgroundColor = .white
    
    view.addSubview(textlabel)
    textlabel.textAlignment = .center
    textlabel.numberOfLines = 0
  }
}

// MARK: - BindableView

extension MainViewController: BindableView {
  func getOutput() -> any MainViewOutput { viewOutput }
  
  func bindWith(input: MainPresenterOutput) {
    presenterOutput = input
    bindIfNeeded()
  }
  
  private func bindIfNeeded() {
    guard let input = presenterOutput, isViewLoaded else { return }
    
    cancelBag.collect {
      input.viewModel.sink { [weak self] vm in
        self?.textlabel.text = "Data loaded 🫡\n\n\(vm.title)"
      }
      
      input.isLoadingIndicatorVisible.sink { [weak self]  _ in
        self?.textlabel.text = "Loading... 👀"
      }
    }
  }
}

// MARK: - ViewOutput

extension MainViewController {
  private struct ViewOutput: MainViewOutput {
    @SendablePublisher var bannerTap: AnyPublisher<Void, Never>
    @SendablePublisher var categoryTap: AnyPublisher<Void, Never>
  }
}
