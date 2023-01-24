//
//  Container.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//

import UIKit

/// Взято из XCoordinator

///
/// Container abstracts away from the difference of `UIView` and `UIViewController`
///
/// With the Container protocol, `UIView` and `UIViewController` objects can be used interchangeably,
/// e.g. when embedding containers into containers.
///
public protocol Container: AnyObject {
  ///
  /// The view of the Container.
  ///
  /// - Note:
  ///     It might not exist for a `UIViewController`.
  ///
  var view: UIView! { get }

  ///
  /// The viewController of the Container.
  ///
  /// - Note:
  ///     It might not exist for a `UIView`.
  ///
  var viewController: UIViewController! { get }
}

// MARK: - Extensions

extension UIViewController: Container {
  public var viewController: UIViewController! { self }
}

extension UIView: Container {
  public var viewController: UIViewController! { viewController(for: self) }

  public var view: UIView! { self }
}

extension UIView {
  private func viewController(for responder: UIResponder) -> UIViewController? {
    if let viewController = responder as? UIViewController {
      return viewController
    }

    if let nextResponser = responder.next {
      return viewController(for: nextResponser)
    }

    return nil
  }
}

