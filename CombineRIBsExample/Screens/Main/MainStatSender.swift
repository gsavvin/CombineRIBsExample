//
//  MainStatSender.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import Combine

final class MainStatSender: ScreenAbstractStatSender  {
  var screenName: StatisticsScreenName { .main }
  
  private let viewOutput: any MainViewOutput
  private let interactorOutput: MainInteractorOutput
  
  private var cancelBag = CancelBag()
  
  init(sender: any StatisticsSender,
       viewOutput: any MainViewOutput,
       interactorOutput: MainInteractorOutput) {
    self.viewOutput = viewOutput
    self.interactorOutput = interactorOutput
    
    super.init(sender: sender)
    
    initialSetup()
  }
  
  private func initialSetup() {
    bindTapEvents()
    bindErrorEvents()
  }
  
  private func bindTapEvents() {
    cancelBag.collect {
      viewOutput.bannerTap
        .sink { [weak self] _ in
          let event = StatisticsEvent(eventName: "main_banner_tap", params: [.eventAction(.tap), .eventLabel(.banner)])
          self?.sendScreenEvent(event)
        }
      
      viewOutput.categoryTap
        .sink { [weak self] _ in
          let event = StatisticsEvent(eventName: "main_category_tap", params: [.eventAction(.tap), .eventLabel(.category)])
          self?.sendScreenEvent(event)
        }
    }
  }
  
  private func bindErrorEvents() {
    cancelBag.collect {
      interactorOutput.state
        .compactMap { state -> Void? in
          guard case .loadingError = state else { return nil }
          return Void()
        }
        .sink { [weak self] in
          let event = StatisticsEvent(eventName: "main_networking_error", params: [.eventAction(.error), .eventLabel(.networking)])
          self?.sendScreenEvent(event)
        }
    }
  }
}
