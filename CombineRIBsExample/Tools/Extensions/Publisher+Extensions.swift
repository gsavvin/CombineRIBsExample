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
  /// Оператор для случаев, когда в интеракторе необходимо фильтровать событие текущим состоянием. Например когда нажатие
  /// кнопки допустимо только в состоянии dataLoaded.
  /// Заменяет собой комбинацию операторов withLatestFrom + filter + map.
  public func filteredByState<State>(_ state: AnyPublisher<State, Failure>,
                                     filter predicate: @escaping (State) -> Bool) -> AnyPublisher<Output, Failure> {
    let predicateAdapter: (Output, State) -> Bool = { _, state -> Bool in
      predicate(state)
    }
    
    return withLatestFrom(state)
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
    
    return withLatestFrom(state)
      .compactMap(compactMapAdapter)
      .eraseToAnyPublisher()
  }
}

public extension Publisher where Self.Failure == Never {
  /// Invokes sink function on main thread
  func drive(_ onReceive: @escaping (Output) -> Void) -> AnyCancellable {
    receive(on: DispatchQueue.main)
      .sink(receiveValue: onReceive)
  }
}


/// Аналог оператора withLatestFrom в RxSwift
/// Эмитит только на основании эмита в source publisher, при наличии значения в other
/// https://gist.github.com/SergeBouts/59d1c674c53f8a23d2ac773490410940
extension Publishers {
    public struct WithLatestFrom<Upstream: Publisher, Other: Publisher>: Publisher where Upstream.Failure == Other.Failure {
        
        // MARK: - Types
        public typealias Output = (Upstream.Output, Other.Output)
        public typealias Failure = Upstream.Failure

        // MARK: - Properties
        private let upstream: Upstream
        private let other: Other

        // MARK: - Initialization
        init(upstream: Upstream, other: Other) {
            self.upstream = upstream
            self.other = other
        }

        // MARK: - Publisher Lifecycle
        public func receive<S: Subscriber>(subscriber: S)
            where S.Failure == Failure, S.Input == Output {
            let merged = mergedStream(upstream, other)
            let result = resultStream(from: merged)
            result.subscribe(subscriber)
        }
    }
}

// MARK: - Helpers
private extension Publishers.WithLatestFrom {
    // MARK: - Types
    enum MergedElement {
        case upstream1(Upstream.Output)
        case upstream2(Other.Output)
    }

    typealias ScanResult =
        (value1: Upstream.Output?,
         value2: Other.Output?, shouldEmit: Bool)

    // MARK: - Pipelines
    func mergedStream(_ upstream1: Upstream,
                      _ upstream2: Other) -> AnyPublisher<MergedElement, Failure> {
        let mergedElementUpstream1 = upstream1
            .map { MergedElement.upstream1($0) }
        let mergedElementUpstream2 = upstream2
            .map { MergedElement.upstream2($0) }
        return mergedElementUpstream1
            .merge(with: mergedElementUpstream2)
            .eraseToAnyPublisher()
    }

    func resultStream(from mergedStream: AnyPublisher<MergedElement, Failure>) -> AnyPublisher<Output, Failure> {
        mergedStream
            .scan(nil) {
                (prevResult: ScanResult?,
                mergedElement: MergedElement) -> ScanResult? in

                var newValue1: Upstream.Output?
                var newValue2: Other.Output?
                let shouldEmit: Bool

                switch mergedElement {
                case .upstream1(let v):
                    newValue1 = v
                    shouldEmit = prevResult?.value2 != nil
                case .upstream2(let v):
                    newValue2 = v
                    shouldEmit = false
                }

                return ScanResult(value1: newValue1 ?? prevResult?.value1,
                                  value2: newValue2 ?? prevResult?.value2,
                                  shouldEmit: shouldEmit)
        }
        .compactMap { $0 }
        .filter { $0.shouldEmit }
        .map { Output($0.value1!, $0.value2!) }
        .eraseToAnyPublisher()
    }
}

public extension Publisher {
    func withLatestFrom<Other: Publisher>(_ other: Other)
        -> Publishers.WithLatestFrom<Self, Other> {
        .init(upstream: self, other: other)
    }
}
