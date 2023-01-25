//
//  Publisher+Extensions.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import Combine
import Foundation

public typealias AnyDriver<Output> = AnyPublisher<Output, Never>

class Relay<SubjectType: Subject>: Publisher, CustomCombineIdentifierConvertible where SubjectType.Failure == Never {
    typealias Output = SubjectType.Output
    typealias Failure = SubjectType.Failure
  
    let subject: SubjectType
  
    init(subject: SubjectType) {
        self.subject = subject
    }
  
    func send(_ value: Output) {
        subject
            .send(value)
    }
  
    func receive<S: Subscriber>(subscriber: S)
        where Failure == S.Failure, Output == S.Input {
        subject
            .subscribe(on: DispatchQueue.main)
            .receive(subscriber: subscriber)
    }
}

typealias CurrentValueRelay<Output> = Relay<CurrentValueSubject<Output, Never>>
typealias PassthroughRelay<Output> = Relay<PassthroughSubject<Output, Never>>

extension Relay {
    convenience init<O>(_ value: O)
        where SubjectType == CurrentValueSubject<O, Never> {
        self.init(subject: CurrentValueSubject(value))
    }
  
    convenience init<O>()
        where SubjectType == PassthroughSubject<O, Never> {
        self.init(subject: PassthroughSubject())
    }
}

extension Publisher {
  /// Аналог оператора withLatestFrom в RxSwift
  /// Эмитит только на основании эмита в source publisher, при наличии значения в other
  public func withLatestFrom<Other: Publisher, Transformed>(_ other: Other, resultSelector: @escaping (Output, Other.Output) -> Transformed)
  -> AnyPublisher<Transformed, Other.Failure> where Failure == Other.Failure {
    other
      .map { second in map { first in resultSelector(first, second) } }
      .switchToLatest()
      .eraseToAnyPublisher()
  }
  
  /// Оператор для случаев, когда в интеракторе необходимо фильтровать событие текущим состоянием. Например когда нажатие
  /// кнопки допустимо только в состоянии dataLoaded.
  /// Заменяет собой комбинацию операторов withLatestFrom + filter + map.
  public func filteredByState<State>(_ state: AnyPublisher<State, Failure>,
                                     filter predicate: @escaping (State) -> Bool) -> AnyPublisher<Output, Failure> {
    let predicateAdapter: (Output, State) -> Bool = { _, state -> Bool in
      predicate(state)
    }
    
    return withLatestFrom(state, resultSelector: { ($0, $1) })
      .filter(predicateAdapter)
      .map { value, _ in value }
      .eraseToAnyPublisher()
  }
  
  /// Оператор для случаев, когда в интеракторе необходимо фильтровать событие текущим состоянием. Например когда нажатие
  /// кнопки допустимо только в состоянии dataLoaded.
  /// Заменяет собой комбинацию операторов withLatestFrom + filter + map.
  ///
  /// Вместо оператора filter используется оператор compactMap, который выполняет ту же самую роль.
  /// Это нужно в случаях, когда вместе с фильтрацией требуется также извлечь данные из конкретного состояния.
  /// Если проводить аналогию с работой filter(), то значение типа U эквивалентно true, а nil эквивалентен false
  public func filteredByState<State, U>(_ state: AnyPublisher<State, Failure>,
                                        filterMap: @escaping (_ state: State) -> U?) -> AnyPublisher<(Output, U), Failure> {
    let compactMapAdapter: (Output, State) -> (Output, U)? = { element, state -> (Output, U)? in
      let maybeOutput = filterMap(state)
      return maybeOutput.map { (element, $0) } // Элемент SO + результат функции compactMap
    }
    
    return withLatestFrom(state, resultSelector: { ($0, $1) })
      .compactMap(compactMapAdapter)
      .eraseToAnyPublisher()
  }
}
