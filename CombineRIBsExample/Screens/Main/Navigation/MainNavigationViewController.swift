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
    
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundEffect = nil
    appearance.backgroundColor = .white
  
    appearance.shadowColor = .clear
    appearance.shadowImage = nil
  
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
  }
}
