import SafariServices
import UIKit

public typealias RouteCompletion = () -> Void

/// The base protocol for all routers that own their own view controllers.
public protocol ViewableRouting: Routing {
  // The following methods must be declared in the base protocol, since `Router` internally invokes these methods.
  // In order to unit test router with a mock child router, the mocked child router first needs to conform to the
  // custom subclass routing protocol, and also this base protocol to allow the `Router` implementation to execute
  // base class logic without error.
  
  /// The base view controllable associated with this `Router`.
  var viewControllable: ViewControllable { get }
  
  func close()
  
  func close(animated: Bool, completion: RouteCompletion?)
  
  func detach()
}

extension ViewableRouting {
  public func close() {
    close(animated: true, completion: nil)
  }
}

// MARK: - RouterTransition

public protocol RouterTransition {}

// MARK: - TransitionPerformer

protocol TransitionPerformer: AnyObject {
  associatedtype TransitionType: RouterTransition
  
  func perform(transition: TransitionType, completion: RouteCompletion?)
}

// MARK: - RouteProtocol

public protocol RouteProtocol {}

// MARK: - Routable

public protocol Routable: AnyObject {
  associatedtype RouteType: RouteProtocol
  
  func trigger(_ route: RouteType, completion: @escaping RouteCompletion)
  
  func trigger(_ route: RouteType)
}

/// The base class of all routers that owns view controllers, representing application states.
///
/// A `Router` acts on inputs from its corresponding interactor, to manipulate application state and view state,
/// forming a tree of routers that drives the tree of view controllers. Router drives the lifecycle of its owned
/// interactor. `Router`s should always use helper builders to instantiate children `Router`s.
open class ViewableRouter<InteractorType, ViewControllerType, TransitionType: RouterTransition, RouteType: RouteProtocol>: Router
<InteractorType>, ViewableRouting, TransitionPerformer, Routable {
  // MARK: - Public
  
  /// The corresponding `ViewController` owned by this `Router`.
  public let viewController: ViewControllerType
  
  /// The base `ViewControllable` associated with this `Router`.
  public let viewControllable: ViewControllable
  
  /// Initializer.
  ///
  /// - parameter interactor: The corresponding `Interactor` of this `Router`.
  /// - parameter viewController: The corresponding `ViewController` of this `Router`.
  public init(interactor: InteractorType, viewController: ViewControllerType) {
    self.viewController = viewController
    
    guard let viewControllable = viewController as? ViewControllable else {
      fatalError("\(viewController) should conform to \(ViewControllable.self)")
    }
    self.viewControllable = viewControllable
    
    super.init(interactor: interactor)
  }
  
  open func prepareTransition(for route: RouteType) -> TransitionType {
    fatalError("Please override the \(#function) method.")
  }
  
  public func close(animated: Bool, completion: RouteCompletion? = nil) {}
  
  public func detach() {
    parent?.detachChild(self)
  }
  
  // MARK: - Routable
  
  public func trigger(_ route: RouteType, completion: @escaping RouteCompletion) {
    DispatchQueue.main.async {
      let transition = self.prepareTransition(for: route)
      self.perform(transition: transition, completion: completion)
    }
  }
  
  public func trigger(_ route: RouteType) {
    trigger(route) {}
  }
  
  // MARK: - Overriden
  
  override func internalDidLoad() {
    super.internalDidLoad()
  }
  
  // MARK: - Internal
  
  func perform(transition: TransitionType, completion: RouteCompletion?) {
    fatalError("Please override the \(#function) method.")
  }
  
  func present(_ router: ViewableRouting, animated: Bool, completion: RouteCompletion?) {
    attachChild(router)
    
    viewControllable.uiviewController.present(onRoot: false,
                                              router.viewControllable.uiviewController,
                                              animated: animated,
                                              completion: completion)
  }
  
  func dismiss(toRoot: Bool, animated: Bool, completion: RouteCompletion?) {
    /// контроллеры, которые будут удалены из стека, в зависимости от того, до какой глубины происходит dismiss
    let dismissingViewControllers: [UIViewController] = toRoot
      ? getPresentedControllersStack(for: viewControllable.uiviewController)
      : [viewControllable.uiviewController.topPresentedViewController]
    
    /// связанные с контроллерами для удаления роутеры
    let routersForDetach: [Routing] = findRouters(for: dismissingViewControllers)
    
    viewControllable.uiviewController.dismiss(toRoot: toRoot, animated: animated) {
      routersForDetach.forEach { $0.detachFromParent() }
      completion?()
    }
  }
  
  func attachFlow(_ router: FlowRouting) {
    attachChild(router)
  }
}

// MARK: - Embed (композиция экранов)

extension ViewableRouter {
  public func embed(_ router: ViewableRouting, in container: Container, completion: RouteCompletion?) {
    attachChild(router)
    
    viewControllable.uiviewController.embed(childViewController: router.viewControllable.uiviewController,
                                            in: container,
                                            completion: completion)
  }
  
  public func unembed(_ router: EmbedRouting, completion: RouteCompletion?) {
    router.viewControllable.uiviewController.unembedFromParent(completion: completion)
  }
}
