//
//  MainNavigationViewController.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 24.01.2023.
//

import UIKit

final class MainNavigationViewController: UINavigationController, MainNavigationViewControllable {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemYellow
    
    delegate = self
    
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundEffect = nil
    appearance.backgroundColor = .white
  
    appearance.shadowColor = .clear
    appearance.shadowImage = nil
  
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    
    navigationBar.tintColor = .black
  }
}

extension MainNavigationViewController: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController,
                                   willShow viewController: UIViewController,
                                   animated: Bool) {
    // Убираем текст из кнопки назад
    viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
}
