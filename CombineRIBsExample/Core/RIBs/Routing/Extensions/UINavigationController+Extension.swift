import UIKit

/**
 workaround для установки completion в стандартные транзишены UINavigationController
 https://stackoverflow.com/questions/12904410/completion-block-for-popviewcontroller
 */

extension UINavigationController {
  func push(_ viewController: UIViewController,
            animated: Bool,
            completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      pushViewController(viewController, animated: animated)
    }
    
    CATransaction.commit()
  }
  
  func pop(toRoot: Bool,
           animated: Bool,
           completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      if toRoot {
        popToRootViewController(animated: animated)
      } else {
        popViewController(animated: animated)
      }
    }
    
    CATransaction.commit()
  }
  
  func pop(to viewController: UIViewController,
           animated: Bool,
           completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      _ = popToViewController(viewController, animated: animated)
    }
    
    CATransaction.commit()
  }
  
  func set(_ viewControllers: [UIViewController],
           animated: Bool,
           completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      setViewControllers(viewControllers, animated: animated)
    }
    
    CATransaction.commit()
  }
}
