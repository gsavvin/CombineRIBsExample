//
//  StateTransformBuilder.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import Combine

@resultBuilder
public enum StateTransformBuilder {
  public static func buildBlock<State>(_ transitions: AnyPublisher<State, Never>...) -> AnyPublisher<State, Never> {
    Publishers.MergeMany(transitions).eraseToAnyPublisher()
  }
}

public protocol StateTransformer {}

extension StateTransformer {
  public static func transitions<State>(@StateTransformBuilder builder: () -> AnyPublisher<State, Never>) -> AnyPublisher<State, Never> {
    builder()
  }

  public static func transition<T>(_ expression: () -> T) -> T {
    expression()
  }
}

extension AnyPublisher {
  public static func merge<State>(@StateTransformBuilder builder: () -> AnyPublisher<State, Never>) -> AnyPublisher<State, Never> {
    builder()
  }
}
