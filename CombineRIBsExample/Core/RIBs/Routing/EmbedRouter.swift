import UIKit

/// Встраиваемые переиспользуемые экраны
public protocol EmbedRouting: ViewableRouting {}

open class EmbedRouter<InteractorType, ViewControllerType, RouteType: RouteProtocol>: ViewableRouter
<InteractorType, ViewControllerType, EmbedTransition, RouteType>, EmbedRouting {
  // MARK: - Overridden
  
  override func perform(transition: TransitionType, completion: RouteCompletion?) {
    switch transition {
    case let .embed(router, container):
      embed(router, in: container, completion: completion)
      
    case let .unembed(router):
      unembed(router, completion: completion)
      
    case let .present(router, animated):
      present(router, animated: animated, completion: completion)
      
    case let .dismiss(toRoot, animated):
      dismiss(toRoot: toRoot, animated: animated, completion: completion)
      
    case .none:
      break
    }
  }
}

/// При необходимости запушить экран в NavigationStack нужно попросить об этом родителя
public enum EmbedTransition: RouterTransition {
  
  case embed(EmbedRouting, in: Container)
  case unembed(EmbedRouting)
  
  case present(ModalRouting, animated: Bool = true)
  case dismiss(toRoot: Bool = false, animated: Bool = true)
  
  case none
}
