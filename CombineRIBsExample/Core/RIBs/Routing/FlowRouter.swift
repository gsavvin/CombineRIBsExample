import UIKit

open class FlowRouter<InteractorType, ViewControllerType, RouteType: RouteProtocol>: ViewableRouter
<InteractorType, ViewControllerType, FlowTransition, RouteType>, FlowRouting {
  // MARK: - Overriden

  open override func prepareTransition(for route: RouteType) -> FlowTransition {
    fatalError("Please override the \(#function) method.")
  }

  public override init(interactor: InteractorType, viewController: ViewControllerType) {
    super.init(interactor: interactor, viewController: viewController)
  }

  public override func close(animated: Bool = true, completion: RouteCompletion? = nil) {
    DispatchQueue.main.async { [weak self] in
      self?.detachFromParent()
    }
  }

  override func perform(transition: TransitionType, completion: RouteCompletion?) {
    switch transition {
    case let .present(router, animated):
      super.present(router, animated: animated, completion: completion)
    case let .dismiss(toRoot, animated):
      super.dismiss(toRoot: toRoot, animated: animated, completion: completion)
    case let .attachFlow(router):
      super.attachFlow(router)
    case .none:
      break
    }
  }
}

// MARK: - FlowTransition

public enum FlowTransition: RouterTransition {
  case present(ModalRouting, animated: Bool = true)
  case dismiss(toRoot: Bool = false, animated: Bool = true)
  case attachFlow(FlowRouting)
  case none
}

// MARK: - FlowRouting

public protocol FlowRouting: ViewableRouting {}
