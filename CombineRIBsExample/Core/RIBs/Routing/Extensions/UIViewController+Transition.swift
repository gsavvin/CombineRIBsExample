//
//  UIViewController+Transition.swift
//  CombineRIBsExample
//
//  Created by Andrey Stopin on 24.01.2023.
//

import UIKit

extension UIViewController {
  /// Самый верхний в стеке презентованных контроллер
  var topPresentedViewController: UIViewController {
    presentedViewController?.topPresentedViewController ?? self
  }
  
  func present(onRoot: Bool,
               _ viewController: UIViewController,
               animated: Bool,
               completion: RouteCompletion?) {
    let presentingViewController = onRoot ? self : topPresentedViewController
    presentingViewController.present(viewController, animated: animated, completion: completion)
  }
  
  func dismiss(toRoot: Bool,
               animated: Bool,
               completion: RouteCompletion?) {
    let dismissalViewController = toRoot ? self : topPresentedViewController
    dismissalViewController.dismiss(animated: animated, completion: completion)
  }
}

extension UIViewController {
  /// Метод чтобы родитель умел embed'ить дочерний экран.
  public func embed(childViewController: UIViewController,
                    in container: Container,
                    completion: RouteCompletion?) {
    container.viewController.addChild(childViewController)
    
    childViewController.view.translatesAutoresizingMaskIntoConstraints = false
    
    guard let containerView = container.view else {
      return assertionFailure()
    }
    
    containerView.addStretchedToBounds(subview: childViewController.view)
    
    childViewController.didMove(toParent: container.viewController)
    
    completion?()
  }
  
  /// Метод, чтобы дочерний экран умел удаляться из родительского
  public func unembedFromParent(completion: RouteCompletion?) {
    guard parent != nil else {
      return assertionFailure()
    }
    
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
    completion?()
  }
}

extension UIView {
  /// Привязывает 4 стороны subview к self.
  /// left / right являются константами для leading / trailing constraint'ов.
  internal func addStretchedToBounds(subview: UIView, insets: UIEdgeInsets = .zero) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    addSubview(subview)

    let constraints: [NSLayoutConstraint] = [
      subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
      subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
      trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: insets.right),
      bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: insets.bottom),
    ]

    NSLayoutConstraint.activate(constraints)
  }
}
