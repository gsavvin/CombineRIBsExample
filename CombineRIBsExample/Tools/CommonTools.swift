//
//  CommonTools.swift
//  CombineRIBsExample
//
//  Created by Геннадий Саввин on 25.01.2023.
//

import Foundation
import UIKit

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(in: 0...1),
           green: .random(in: 0...1),
           blue:  .random(in: 0...1),
           alpha: 1.0
        )
    }
}

extension Array {
  public subscript(uncheckedIndex index: Index) -> Element? {
    guard indices.contains(index) else { return nil }
    return self[index]
  }
}

