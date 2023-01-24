//
//  Statistics.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import Foundation

public enum StatisticsScreenName: String {
  case main = "catalogMain"
  case catalog = "catalog3"
  case search = "catalogSearch"
}


public protocol StatisticsSender: AnyObject {
  func sendEvent(_ event: StatisticsEvent)
}

public struct StatisticsEvent {
  let eventName: String
  var params: [StatisticEventParam]
}

public enum StatisticEventParam {
  case screenName(String)
  case eventAction(StatisticsEventActionKind)
  case eventLabel(StatisticsEventLabelKind)
  case eventContent(String)
}

public enum StatisticsEventActionKind: String {
  case error = "error"
  case tap = "tap"
}

public enum StatisticsEventLabelKind: String {
  case banner = "banner"
  case category = "category"
  case networking = "networking"
}

public typealias ScreenAbstractStatSender = ScreenStatSenderRootClass & StatisticsScreenIdentityProvider

open class ScreenStatSenderRootClass {
  public let sender: any StatisticsSender
    
  public init(sender: any StatisticsSender) {
    self.sender = sender
  }
}

public protocol StatisticsScreenIdentityProvider {
  var screenName: StatisticsScreenName { get }
}

extension StatisticsScreenIdentityProvider where Self: ScreenStatSenderRootClass {
  public func sendScreenEvent(_ event: StatisticsEvent) {
    var event = event
    event.params.append(.screenName(screenName.rawValue))
    sender.sendEvent(event)
  }
}

final class StatisticsSenderImp: StatisticsSender {
  func sendEvent(_ event: StatisticsEvent) {
    print("STATISTICS: Send event with name \(event.eventName)")
  }
}
