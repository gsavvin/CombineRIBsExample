//
//  SendablePublisher.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import Combine

// Добавить описание
@propertyWrapper
public final class SendablePublisher<Value> {
  public let wrappedValue: AnyPublisher<Value, Never>
  
  public let projectedValue = PassthroughSubject<Value, Never>()
  
  public init() {
    wrappedValue = projectedValue.eraseToAnyPublisher()
  }
}
