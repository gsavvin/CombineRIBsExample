import UIKit

open class NavigationRouter<InteractorType, ViewControllerType, RouteType: RouteProtocol>: ViewableRouter
<InteractorType, ViewControllerType, NavigationTransition, RouteType>, NavigationRouting {
  // MARK: - Public
  
  public var navigationController: UINavigationController? {
    
    let navController: UINavigationController?
    if let navigationController = viewController as? UINavigationController {
      navController = navigationController
    } else if let uiViewController = viewController as? UIViewController {
      if let navigationController = uiViewController.navigationController {
        navController = navigationController
      } else {
        navController = nil
      }
    } else {
      navController = nil
    }
    return navController
  }
  
  // MARK: - Overriden
  
  open override func prepareTransition(for _: RouteType) -> NavigationTransition {
    let message = "Please override the \(#function) method. in \(self)."
    #if DEBUG
      fatalError(message)
    #else
      return .none
    #endif
  }
  
  public override init(interactor: InteractorType, viewController: ViewControllerType) {
    super.init(interactor: interactor, viewController: viewController)
  }
  
  public override func close(animated: Bool = true, completion: RouteCompletion? = nil) {
    DispatchQueue.main.async { [weak self] in
      self?.perform(transition: .pop(toRoot: false, animated: animated), completion: completion)
    }
  }
  
  override func perform(transition: TransitionType, completion: RouteCompletion?) {
    // временное решение с опционалом, логируется сверху
    // сделать guard let navigationController = navigationController нельзя тк пораждает утечку,
    // лучше давать ему закрывать иерархию роутеров.
    // вью может выгружаться раньше чем нужно, поэтому время жизни роутера увеличено не будет,
    // тк когда мы открываем диплинк, или программно говорим приложению "нужно перезагрузится" мы рубим стек рибов под корень.
    // когда будем переделывать роутинг этот момент нужно пересмотреть!
    switch transition {
    case let .push(router, animated):
      attachChild(router)
      
      navigationController?.push(router.viewControllable.uiviewController, animated: animated) { [weak self] in
        completion?()
        self?.interactable.routed(to: router)
      }
      
    case let .pop(toRoot, animated):
      /// контроллеры, которые будут удалены из стека, в зависимости от того, до какой глубины происходит pop
      let droppedControllers: [UIViewController]
      if toRoot {
        droppedControllers = navigationController.map { Array($0.viewControllers.dropFirst()) } ?? []
      } else {
        droppedControllers = navigationController?.viewControllers.last.map { [$0] } ?? []
      }
      
      /// связанные с контроллерами для удаления роутеры
      let routersForDetach = findRouters(for: droppedControllers)
      
      navigationController?.pop(toRoot: toRoot, animated: animated) {
        routersForDetach.forEach { $0.detachFromParent() }
        completion?()
      }
      
    case let .popTo(router, animated):
      /// целевой контроллер, до которого происходит pop
      let targetController = router.viewControllable.uiviewController
      
      /// все контроллеры в стеке
      let controllersStack = navigationController?.viewControllers ?? []
      
      /// индекс следующего за целевым контроллером
      guard let nextToTargetControllerIndex: Int = controllersStack
        .firstIndex(of: targetController)?
        .advanced(by: 1) else { break }
      
      /// контроллеры, которые будут удалены из стека
      let droppedControllers = Array(controllersStack[nextToTargetControllerIndex...])
      
      /// связанные с контроллерами для удаления роутеры
      let routersForDetach = findRouters(for: droppedControllers)
      
      navigationController?.pop(to: targetController, animated: animated) {
        routersForDetach.forEach { $0.detachFromParent() }
        completion?()
      }
      
    case let .present(router, animated):
      present(router, animated: animated, completion: completion)
      
    case let .dismiss(toRoot, animated):
      dismiss(toRoot: toRoot, animated: animated, completion: completion)
      
    case let .attachFlow(router):
      attachFlow(router)
      
    case let .embed(router, container):
      embed(router, in: container, completion: completion)
      
    case let .unembed(router):
      unembed(router, completion: completion)
      
    case .none:
      break
    }
  }
}

// MARK: - NavigationTransition

public enum NavigationTransition: RouterTransition {
  case push(NavigationRouting, animated: Bool = true)
  /// toRoot: false  - вернет на предыдущий экран, toRoot: true -  вернет к началу
  case pop(toRoot: Bool = false, animated: Bool = true)
  case popTo(NavigationRouting, animated: Bool = true)
  
  // common
  case present(ModalRouting, animated: Bool = true)
  case dismiss(toRoot: Bool = false, animated: Bool = true)
  case attachFlow(FlowRouting)
  
  // embed
  case embed(EmbedRouting, in: Container)
  case unembed(EmbedRouting)
  
  // none
  case none
}

// MARK: - NavigationRouting

public protocol NavigationRouting: ViewableRouting {
  var navigationController: UINavigationController? { get }
}
