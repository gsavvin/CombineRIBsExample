//
//  Publisher+Extensions.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import Combine

public typealias PassthroughRelay<Output> = PassthroughSubject<Output, Never>
public typealias CurrentValueRelay<Output> = CurrentValueSubject<Output, Never>
public typealias AnyDriver<Output> = AnyPublisher<Output, Never>
public typealias VoidRelay = PassthroughRelay<Void>
