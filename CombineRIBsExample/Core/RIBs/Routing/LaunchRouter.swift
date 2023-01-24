import UIKit

/// Тип роутера для старта приложения. Предполагается использование одного экземпляра такого типа на всё приложение
open class LaunchRouter<InteractorType, ViewControllerType, RouteType: RouteProtocol>: ViewableRouter
<InteractorType, ViewControllerType, LaunchTransition, RouteType> {
  private var window: UIWindow?
  
  // MARK: - Public
  
  public final func launch(from window: UIWindow) {
    self.window = window
    
    window.rootViewController = viewControllable.uiviewController
    window.makeKeyAndVisible()
    
    interactable.activate()
    load()
  }
  
  // MARK: - Overriden
  
  open override func prepareTransition(for route: RouteType) -> LaunchTransition {
    fatalError("Please override the \(#function) method.")
  }
  
  public override init(interactor: InteractorType, viewController: ViewControllerType) {
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func perform(transition: TransitionType, completion: RouteCompletion?) {
    switch transition {
    case .setAsRoot(let router):
      detachAllChildren()
      
      attachChild(router)
      
      window?.rootViewController = router.viewControllable.uiviewController
      window?.makeKeyAndVisible()
      
      completion?()
      interactable.routed(to: router)
    case .reset:
      detachAllChildren()
      window?.rootViewController = viewControllable.uiviewController
      window?.makeKeyAndVisible()
      completion?()
    case let .present(router, animated):
      super.present(router, animated: animated, completion: completion)
    case let .dismiss(toRoot, animated):
      super.dismiss(toRoot: toRoot, animated: animated, completion: completion)
    case let .embed(router, container):
      super.embed(router, in: container, completion: completion)
    case .unembed(let router):
      super.unembed(router, completion: completion)
    case .none:
      break
    }
  }
}

// MARK: - LaunchTransition

public enum LaunchTransition: RouterTransition {
  case setAsRoot(ViewableRouting)
  case reset
  
  // common
  case present(ModalRouting, animated: Bool = true)
  case dismiss(toRoot: Bool = false, animated: Bool = true)
  case embed(EmbedRouting, in: Container)
  case unembed(EmbedRouting)
  case none
}
